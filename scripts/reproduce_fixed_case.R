# Recompute the deposited case study from the public, source-selected gene matrices.
# Requires R and metafor. No platform service, private file, or original
# participant identifier is needed.
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: Rscript scripts/reproduce_fixed_case.R BUNDLE_DIRECTORY [OUTPUT_DIRECTORY]")
bundle <- normalizePath(args[[1]], mustWork = TRUE)
out <- if (length(args) > 1) args[[2]] else file.path(bundle, "recomputed")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
source(file.path(bundle, "methods/Figure4_readers.R"))
source(file.path(bundle, "methods/Figure4_deconvolution.R"))
suppressPackageStartupMessages(library(metafor))
manifest <- read.delim(file.path(bundle, "sample_manifest.tsv"), stringsAsFactors = FALSE)
write_tsv <- function(x, name) write.table(x, file.path(out, name), sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
rows <- list()
qc_rows <- list()
for (dataset in unique(manifest$dataset)) {
  samples <- manifest[manifest$dataset == dataset, ]
  gene <- .read_gene_matrix_full(file.path(bundle, "gene", paste0(dataset, ".txt")))
  gene <- gene[!duplicated(rownames(gene)) & nzchar(rownames(gene)), samples$sample, drop = FALSE]
  for (signature in c("lm22", "immunostates")) {
    label <- if (signature == "lm22") "LM22" else "ImmunoStates"
    reference <- .mc_read_sigmatrix(file.path(bundle, paste0("reference_", label, ".tsv")))
    fit <- reference_nnls(gene, reference, file.path(bundle, paste0("mapping_", label, ".tsv")))
    stopifnot(all(samples$sample %in% fit$matrix$SampleID))
    qc_rows[[length(qc_rows) + 1L]] <- cbind(data.frame(dataset = dataset, signature = signature), fit$qc)
    fractions <- fit$matrix[match(samples$sample, fit$matrix$SampleID), ]
    for (cell in setdiff(names(fractions), "SampleID")) rows[[length(rows) + 1L]] <- data.frame(
      samples, signature = signature, cell = cell, fraction = fractions[[cell]], check.names = FALSE)
  }
  message("Recomputed ", dataset)
}
d <- do.call(rbind, rows)
write_tsv(d, "recomputed_fractions.tsv")
write_tsv(do.call(rbind, qc_rows), "deconvolution_qc.tsv")
expected <- read.delim(file.path(bundle, "expected_fractions.tsv"), stringsAsFactors = FALSE)
key <- function(x) paste(x$dataset, x$sample, x$signature, x$cell, sep = "::")
stopifnot(!anyDuplicated(key(d)), setequal(key(d), key(expected)))
error <- max(abs(d$fraction - expected$fraction[match(key(d), key(expected))]))
stopifnot(error < 1e-8)
effects <- list()
for (signature in unique(d$signature)) for (cell in unique(d$cell[d$signature == signature])) {
  x <- d[d$signature == signature & d$cell == cell, ]
  for (dataset in unique(x$dataset)) for (cohort in unique(x$cohort[x$dataset == dataset])) {
    z <- x[x$dataset == dataset & x$cohort == cohort, ]
    a <- z$fraction[z$group == "ATB"]; b <- z$fraction[z$group == "LTBI UC"]
    e <- suppressWarnings(escalc(measure = "SMD", m1i = mean(a), sd1i = sd(a), n1i = length(a),
      m2i = mean(b), sd2i = sd(b), n2i = length(b)))
    effects[[length(effects) + 1L]] <- data.frame(signature, cell, dataset, cohort, study = z$study[[1]],
      g = e$yi, var = e$vi, n1 = length(a), n2 = length(b))
  }
}
effects <- do.call(rbind, effects)
combine <- function(x, fields) {
  x <- x[is.finite(x$g) & is.finite(x$var) & x$var > 0, ]
  do.call(rbind, lapply(split(x, interaction(x[, fields, drop = FALSE], drop = TRUE)), function(z) {
    v <- 1 / sum(1 / z$var); result <- z[1, fields, drop = FALSE]
    result$g <- sum(z$g / z$var) * v; result$var <- v
    result$n1 <- sum(z$n1); result$n2 <- sum(z$n2); result
  }))
}
cohort <- combine(effects, c("signature", "cell", "cohort", "study"))
study <- combine(cohort, c("signature", "cell", "study"))
pooled <- list()
for (signature in unique(study$signature)) for (cell in unique(study$cell[study$signature == signature])) {
  z <- study[study$signature == signature & study$cell == cell, ]
  if (nrow(z) < 2) next
  fit <- rma.uni(yi = z$g, vi = z$var, method = "DL", test = "z")
  hk <- rma.uni(yi = z$g, vi = z$var, method = "DL", test = "knha")
  pooled[[length(pooled) + 1L]] <- data.frame(signature, cell, k = nrow(z), g = as.numeric(fit$b),
    lower = fit$ci.lb, upper = fit$ci.ub, p = fit$pval, I2 = fit$I2, tau2 = fit$tau2,
    hk_lower = hk$ci.lb, hk_upper = hk$ci.ub, hk_p = hk$pval)
}
pooled <- do.call(rbind, pooled)
for (signature in unique(pooled$signature)) {
  ix <- pooled$signature == signature
  n <- if (signature == "lm22") 11L else 13L
  pooled$fdr[ix] <- p.adjust(pooled$p[ix], "BH", n = n)
  pooled$hk_fdr[ix] <- p.adjust(pooled$hk_p[ix], "BH", n = n)
}
expected <- read.delim(file.path(bundle, "expected_pooled.tsv"))
key <- function(x) paste(x$signature, x$cell, sep = "::")
expected <- expected[match(key(pooled), key(expected)), ]
stopifnot(all(is.finite(expected$g)), max(abs(pooled$g - expected$g)) < 1e-8,
  max(abs(pooled$fdr - expected$fdr)) < 1e-8, max(abs(pooled$hk_fdr - expected$hk_fdr)) < 1e-8)
write_tsv(effects, "dataset_effects.tsv"); write_tsv(study, "study_effects.tsv"); write_tsv(pooled, "pooled_effects.tsv")
writeLines(c(paste("Fraction maximum absolute difference:", format(error, digits = 16)),
  "PASS: fractions, pooled g and both BH families reproduce the fixed exploratory case."), file.path(out, "validation.txt"))
cat("PASS: public bundle reproduces fixed-case fractions and pooled estimates. Maximum fraction error:", error, "\n")
