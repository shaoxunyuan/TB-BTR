# Illustrative analysis

## Selection and analysis units

The fixed ATB–LTBI UC comparison uses selected HIV-negative whole-blood microarray records from GSE19439, GSE19444, GSE19442, GSE37250 and GSE39939. Selection excludes recorded longitudinal, treatment-related and recovery annotations and retains one record per source-specific participant key. The sample manifest provides the exact selected records, group, region and original-study association.

The five regional cohorts are Berry UK, Berry South Africa, Kaforou Malawi, Kaforou South Africa and Anderson Kenya. Berry UK training/test subsets are combined within region; regional effects are then combined within original studies. The final random-effects analysis uses three original studies.

## Relative immune-cell contributions

Expression and reference matrices are matched by gene identifier. Nonnegative input matrices with maximum value below 50 are transformed using `2^x - 1`; otherwise linear values are retained. This reproduces the fixed case's scale heuristic. It does not independently verify each matrix's original log transformation; ordinary log2 intensities and log2(x+1) have different inverses.

Reference columns and each sample are normalized over overlapping genes. Gene weights are the reciprocal of the reference-row RMS, bounded below at its 10th percentile. Weighted reference columns are normalized by their L2 norms before Lawson–Hanson active-set NNLS with QR. Coefficients are rescaled, normalized to sum to one and aggregated using the provided reference-specific mappings. LM22 is the primary reference and ImmunoStates is used for reference sensitivity.

## Effect estimation and inference

Hedges' g is computed with `metafor::escalc(measure="SMD")` for ATB minus LTBI UC within dataset-site subsets. Fixed-effect inverse-variance aggregation first combines subsets within region and then regions within original studies. DerSimonian–Laird random effects and Knapp–Hartung inference are computed across original studies. Benjamini–Hochberg correction retains all 11 LM22 or 13 ImmunoStates planned categories, including categories with unavailable pooled effects. Categories with fewer than two estimable original studies do not yield a pooled estimate.

The included expected fractions and pooled results are comparison targets, not substitutes for calculation. `reproduce_fixed_case.R` recomputes them from the selected expression inputs. The supplied sensitivity files report exclusion of the childhood study and omission of individual studies; the reproduction entry point checks the primary fractions and pooled effects, rather than claiming to regenerate every supplementary worksheet.

## Interpretation

Outputs are inferred relative reference contributions. Reference choice and study composition affect interpretation, particularly for monocytes. Selection of monocytes, neutrophils and CD4 T cells for detailed display was post hoc. Complete pretreatment status was verified for Berry sources; ascertainment in other sources and linkage across studies remain incomplete. Excluding Anderson is a study-composition sensitivity, not verification of adult numeric age for every remaining record.

This exploratory comparison does not establish within-person progression, absolute cell counts or diagnostic performance. It does not rerun upstream raw sequencing or microarray preprocessing. The general platform's online dataset-level pooling does not automatically perform the original-study aggregation or Knapp–Hartung sensitivity used here.
