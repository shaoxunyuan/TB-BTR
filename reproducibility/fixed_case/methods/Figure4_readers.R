.read_gene_matrix_full <-
function (matrix_path)
{
    if (!file.exists(matrix_path))
        return(NULL)
    first <- tryCatch(readLines(matrix_path, n = 1L), error = function(e) "")
    if (!nzchar(first))
        return(NULL)
    df <- NULL
    if (requireNamespace("data.table", quietly = TRUE)) {
        sep <- if (grepl("\t", first, fixed = TRUE))
            "\t"
        else " "
        df <- tryCatch(data.table::fread(matrix_path, header = TRUE,
            sep = sep, quote = "\"", data.table = FALSE, check.names = FALSE,
            nThread = 1L, showProgress = FALSE, na.strings = "NA"),
            error = function(e) NULL)
        n_header <- tryCatch(local({
            con <- textConnection(first)
            on.exit(close(con))
            utils::count.fields(con, sep = sep, quote = "\"")
        }), error = function(e) NA_integer_)
        if (!is.null(df) && length(n_header) == 1L && !is.na(n_header) &&
            ncol(df) != n_header)
            df <- NULL
    }
    if (is.null(df) && grepl("\t", first, fixed = TRUE)) {
        df <- utils::read.delim(matrix_path, header = TRUE, sep = "\t",
            quote = "\"", check.names = FALSE, stringsAsFactors = FALSE)
    }
    else if (is.null(df)) {
        df <- utils::read.table(matrix_path, header = TRUE, quote = "\"",
            check.names = FALSE, stringsAsFactors = FALSE)
    }
    if (is.null(df) || ncol(df) < 2)
        return(NULL)
    if (!is.numeric(df[[1]])) {
        genes <- as.character(df[[1]])
        mat <- as.matrix(df[, -1, drop = FALSE])
        rownames(mat) <- genes
    }
    else {
        mat <- as.matrix(df)
    }
    storage.mode(mat) <- "double"
    colnames(mat) <- gsub("^\"|\"$", "", colnames(mat))
    rownames(mat) <- gsub("^\"|\"$", "", rownames(mat))
    mat
}
.mc_read_sigmatrix <-
function (path)
{
    df <- utils::read.table(path, header = TRUE, sep = "\t",
        check.names = FALSE, stringsAsFactors = FALSE)
    if (!is.numeric(df[[1]])) {
        genes <- as.character(df[[1]])
        mat <- as.matrix(df[, -1, drop = FALSE])
        rownames(mat) <- genes
    }
    else {
        mat <- as.matrix(df)
    }
    storage.mode(mat) <- "double"
    mat
}
.mc_apply_mapping <-
function (frac_row, mapping_path)
{
    map <- utils::read.table(mapping_path, header = FALSE, sep = "\t",
        stringsAsFactors = FALSE)
    map$V1n <- make.names(map$V1)
    map$V2n <- make.names(map$V2)
    names(frac_row) <- make.names(names(frac_row))
    map <- map[map$V1n %in% names(frac_row), , drop = FALSE]
    if (!nrow(map))
        return(frac_row)
    groups <- split(map$V1n, map$V2n)
    vapply(groups, function(cols) sum(frac_row[cols], na.rm = TRUE),
        numeric(1))
}
