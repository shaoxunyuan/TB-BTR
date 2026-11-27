# Analysis methods

This document describes the analysis deposited in `reproducibility/fixed_case/` and implemented in `reproducibility/fixed_case/methods/` with entry point `scripts/reproduce_fixed_case.R`.

## Design

The case study asks whether inferred blood immune-cell composition differs between active tuberculosis (ATB) and latent infection without a supported progressor subdivision (LTBI UC). It uses five HIV-negative whole-blood microarray datasets for which pretreatment status and source-specific participant keys are documented: GSE19439, GSE19442, and GSE19444 (Berry et al., 2010), GSE37250 (Kaforou et al., 2013), and GSE39939 (Anderson et al., 2014).

Selection excludes records carrying longitudinal, treatment, or recovery annotations and retains one record per source-specific participant key. The resulting 369 records comprise 203 ATB and 166 LTBI UC observations. Berry UK training and test data are pooled within region, so the five datasets form six dataset–site strata and five regional cohorts: Berry UK, Berry South Africa, Kaforou Malawi, Kaforou South Africa, and Anderson Kenya. Regional estimates are combined within original studies, and the across-study model draws on three original studies.

The sample manifest records the dataset, sample identifier, group, region, and original-study assignment for every selected record.

## Expression scale

The deposited gene matrices are used as supplied. A single rule governs scale: where a matrix is non-negative and its maximum falls below 50, values are back-transformed as `2^x - 1`; otherwise they are treated as linear. All five deposited matrices have ranges between roughly 4 and 16 and therefore take the back-transformation, consistent with log2 microarray intensities.

The rule is a range heuristic and does not establish the transformation each source applied. Ordinary log2 intensities and log2(x+1) values require different inverses, and the two conventions are not distinguishable from the value range alone. Scores that enter the model are column-normalised afterwards, so a constant offset in the inversion changes relative rather than absolute values; its effect on the reported fractions is therefore not nil but is secondary to the choice of reference. Recomputing GSE19439-GPL6947 with `2^x` in place of `2^x - 1` changed the eleven mapped LM22 fractions by at most 0.0039 (mean 0.0007), which is small relative to the reported effect sizes and confidence intervals. Reference matrices are not transformed.

## Relative immune-cell contributions

Expression and reference matrices are matched by gene identifier, and the analysis requires at least 100 shared genes. Rows that are non-finite in either matrix, or that sum to zero in either, are dropped before fitting.

Reference columns and sample columns are scaled to unit column sum. Gene weights are the reciprocal of the reference-row root-mean-square, with the denominator bounded below at the 10th percentile of the row distribution, so that low-dispersion genes cannot dominate. Weighted reference columns are then normalised to unit L2 norm.

Each sample is fitted by Lawson–Hanson active-set non-negative least squares, with each active-set least-squares problem solved by QR decomposition at tolerance `1e-10`. Fitting aborts if the active-set iteration limit is exceeded or if the KKT residual exceeds `1e-4`. Coefficients are divided by the reference-column norm used in fitting and then normalised to sum to one, yielding relative contributions that are aggregated through the supplied reference-specific cell mappings.

LM22 is the primary reference and ImmunoStates the reference-sensitivity analysis. The two mappings are applied separately and their outputs are never combined. Per-sample fit quality — overlapping gene count, convergence, KKT residual, weighted residual, and the correlation between fitted and observed profiles — is returned with the results.

This is a weighted NNLS implementation written for this analysis. It is not CIBERSORT or CIBERSORTx, and results should not be described as CIBERSORT output.

## Effect estimation and inference

Hedges' g for ATB minus LTBI UC is computed with `metafor::escalc(measure = "SMD")` within each dataset–site stratum, using group means, standard deviations, and group sizes. Strata with non-finite effects or non-positive variances are excluded.

Fixed-effect inverse-variance aggregation proceeds in two stages: subsets within region, then regions within original study. Each stage weights by the reciprocal of the sampling variance and reports the combined group sizes.

Across-study models are fitted with `metafor::rma.uni` using DerSimonian–Laird variance estimation. The primary estimate and confidence interval come from the normal-approximation test; a second fit with Knapp–Hartung adjustment provides `hk_lower`, `hk_upper`, and `hk_p`, which serve as a small-*k* sensitivity analysis. Cochran's Q, its p-value, I², and τ² are reported with the primary fit.

Benjamini–Hochberg correction is applied separately to the normal-approximation and Knapp–Hartung p-values within each planned test family of 11 LM22 and 13 ImmunoStates categories. The full family size is retained as the correction denominator, including categories that yield no pooled estimate, so the correction is not adapted to the number of categories that happened to be estimable.

A category is modelled across original studies only when at least two estimable studies are available. Categories failing that condition appear in `cell_estimability.tsv` with the reason recorded, and are left out of the pooled table rather than assigned an effect of zero.

## Sensitivity analyses

`sensitivity_adult_only.tsv` repeats the pooled analysis after excluding the paediatric Kenyan cohort, leaving two original studies. `sensitivity_leave_one_study_out.tsv` reports the pooled estimate obtained when each original study is omitted in turn. Both are two-study models, so Knapp–Hartung intervals are substantially wider than the primary intervals and should be read with that in mind. These tables are deposited as outputs; the reproduction entry point recomputes the primary analysis.

## Interpretation

Reported values are inferred contributions relative to a chosen reference signature, not measured cell abundances. Both reference choice and study composition influence the estimates. Across the five categories estimated under both references, the effect directions agree except for monocytes, which change sign between LM22 and ImmunoStates; the magnitude is also substantially larger under LM22 for CD4 T cells, neutrophils, and macrophages.

The three categories presented in detail — monocytes, neutrophils, and CD4 T cells — were selected after inspection of the results and are illustrative rather than a prespecified primary set.

Pretreatment status was verified for the Berry sources. Ascertainment for the other sources and linkage across studies remain incomplete, and pseudonymous linkage keys are unique within the selected set only. Excluding the paediatric cohort is a study-composition sensitivity analysis; it does not establish adult age for every retained record.

The comparison does not support inference on within-person progression, absolute cell counts, or diagnostic performance, and it does not reprocess upstream sequencing or microarray data. The online platform pools at dataset level, whereas this analysis aggregates within original studies and applies Knapp–Hartung inference; the two sets of estimates are not directly comparable.
