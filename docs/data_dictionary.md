# Data dictionary

Field-level definitions for the deposited tables. Controlled values and assignment rules follow the platform's curation scheme, under which each record carries a cross-sectional group, an optional longitudinal annotation, and a treatment-interval assignment.

## Supplementary tables

Table 1 summarises resource coverage, specimen types, harmonised clinical phenotype, longitudinal annotation, and metadata completeness. Percentages use the denominators stated in the workbook.

Supplementary Table S1 comprises five worksheets:

| Worksheet | Contents |
| --- | --- |
| S1A | Catalogued study records and their associated datasets |
| S1B | Accession- and platform-specific datasets, research classifications, availability, and matrix dimensions |
| S1C | Metadata definitions and controlled values |
| S1D | Operational phenotype definitions and assignment rules |
| S1E | Public sample records, clinical annotations, final intervals, preserved earlier intervals, and supporting provenance |

Supplementary Table S2 comprises eight worksheets, covering selection context (S2A), effect estimates (S2B), the selected-record listing (S2C), sensitivity analyses (S2D, S2E), estimability (S2F), cell mappings (S2G), and methods (S2H). Descriptive worksheet suffixes are retained in the filenames.

Tables S1 and S2 carry explanatory notes beneath their data rows. Data rows are the ones with populated identifiers, and notes should not be read as records.

## Identifiers

A dataset identifier combines an accession with a platform. The pair of **Dataset ID** and **Public sample record ID** identifies a record uniquely within Table S1E. GEO datasets use GSM sample identifiers. ArrayExpress datasets appear as `E-MTAB-...` in the tables and as `EMTAB...` in some platform-derived files; strip the `E-MTAB-` prefix when matching the two forms.

A study record is a curated platform record. It may correspond to a primary publication, a secondary analysis of the same cohort, or a re-deposition, so study records do not map one-to-one onto independent publications or onto datasets.

Participant pseudonyms are source-scoped linkage keys. They are unique within the selected set and should not be treated as globally unique participant identifiers. Original participant codes and the complete internal linkage tables are not part of this deposit.

## Missing-value conventions

`Unknown` marks a clinical or experimental annotation that curation did not resolve. `NA` marks information that is unavailable or not applicable to the record. Neither value carries a numeric meaning: they are not zeros, and they do not imply absence of the underlying condition. A record with `Unknown` experimental condition has unresolved status, not a confirmed untreated one, and is therefore not treated as eligible for analyses restricted to unstimulated samples.

The same convention governs phenotype. Records for which the available evidence does not support any of the operational TB categories remain unresolved rather than being assigned to a comparator group.

## Phenotype fields

Cross-sectional group values are `Uninfected` (UI), `LTBI UC`, `LTBI NP`, `ITB` (incipient TB), `STB` (subclinical TB), `ATB`, and comparators (`Healthy`, `OD`, `Sarcoid`, `Pneumonia`, `Lung Cancer`, `HIV`).

Longitudinal annotation values are `ATB Progressor` and the `ATB Treatment` family, the latter carrying qualified variants such as cured, long- or short-course ATT, treatment failure, drug resistance, or outbreak strain. Longitudinal annotation is recorded separately from the cross-sectional group and does not replace it.

The phenotype column in Table 1 is a display category that resolves the cross-sectional and longitudinal fields into one mutually exclusive value, with treatment priority: a record sampled during active-TB treatment is counted as `ATB Treatment` whatever its cross-sectional group, `Uninfected` displays as UI, and comparator groups are pooled as non-TB comparators. This is why Table 1 totals by display category cannot be read as cross-sectional group counts.

## Treatment intervals

`data/metadata/time_provenance.tsv` records the public dataset and sample identifiers, the source longitudinal annotation, the preserved earlier interval, the final interval and its interval/type leaf, an explicit numeric time-to-treatment day where available, and the curated field supporting the assignment. Detailed treatment subtypes are kept separate from the canonical interval and type leaf.

Final intervals are `(0,7]`, `(7,28]`, `(28,60]`, `(60,120]`, `(120,180]`, `(180,240]`, `(240,360]`, and `(360,Inf)` days. Day zero is not assigned to a positive treatment interval. An interval may be reported where an explicit numeric day remains unresolved, with the provenance fields preserving that distinction. No midpoints were imputed for this release.

Progression-associated sampling uses a separate set of diagnosis-relative windows: `(-Inf,-540)`, `[-540,-360)`, `[-360,-180)`, `[-180,-60)`, `[-60,-21)`, and `[-21,0]` days. These describe sampling before diagnosis and are not interchangeable with the post-initiation treatment intervals. The two scales are distinct: the diagnosis-relative windows are closed at day 0, whereas day zero is not assigned to any positive treatment interval.

## Matrix inventory and research classification

`data/metadata/matrix_inventory.tsv` lists stored matrix row and column counts together with paths recorded relative to the original platform root. Those paths document provenance and do not resolve inside this repository. Gene and module matrices hold features in rows and samples in columns; cell matrices hold samples in rows and cell categories in columns. The sample axis of every available matrix therefore equals that dataset's expression-profile record count, and `scripts/validate_release.py` enforces that equality for all five matrices. Zero dimensions accompany matrices that were unavailable at curation time.

Stored gene matrices use two header conventions: most are tab-separated, whereas a minority were written with a space separator and quoted sample identifiers. A reader must accept both, or the column count of the second group is misread as zero.

The inventory covers gene-level matrices and three derived representations: gene-module matrices for BTM and BloodGen3, and cell-level matrices for LM22 and ImmunoStates. Module scoring and cell-fraction estimation for the platform are performed server-side; the deposited code does not recompute them, and the cell-level matrices are distributed for provenance and comparison rather than as analysis inputs.

Dataset research classifications are recorded independently of the classifications attached to linked studies. Propagating each study label to its datasets yields a different quantity, so the two are reported separately. Gene-identifier annotation versions remain unresolved for datasets where the inventory says so.

## Estimability

`data/metadata/estimability.tsv` reports the planned test-family size, the number of estimable dataset–site subsets, the number of estimable original studies, and whether a pooled estimate exists, with the reason recorded for every category that lacks one.

Separate Berry UK training and test datasets give six dataset–site subsets but five regional cohorts. A category may have a single estimable original study and therefore no pooled estimate; that outcome reflects insufficient replication rather than a null effect, and the category is retained in the correction denominator of its test family.
