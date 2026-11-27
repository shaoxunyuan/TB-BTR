# Data organization and definitions

## Supplementary tables

`data/tables/Table1.xlsx` summarizes resource coverage, specimen types, clinical annotation, participant linkage and derived profiles. Percentages use the denominators stated in the workbook.

`TableS1.xlsx` contains:

| Worksheet | Meaning |
| --- | --- |
| S1A | Catalogued study records and their associated datasets |
| S1B | Accession/platform-specific datasets, research classifications, availability and matrix dimensions |
| S1C | Metadata definitions and controlled values |
| S1D | Operational phenotype definitions and assignment rules |
| S1E | Public sample records, clinical annotations, final intervals, preserved earlier intervals and supporting provenance |

`TableS2.xlsx` contains selection context (S2A), regional/study/pooled effects (S2B), selected records with pseudonymous linkage keys (S2C), exclusion of the childhood study (S2D), leave-one-study-out analysis (S2E), estimability (S2F), cell mappings (S2G) and methods (S2H). The descriptive worksheet suffixes are retained in the file.

## Identifiers and missing information

The dataset identifier represents an accession/platform combination. The pair **Dataset ID + Public sample record ID** identifies a record in Supplementary Table S1E. GEO records generally use GSM identifiers. ArrayExpress dataset identifiers use `E-MTAB-...` in the tables and `EMTAB...` in some platform files; replace the prefix `E-MTAB-` with `EMTAB` when matching these forms.

Participant pseudonyms are source-specific linkage keys. Their uniqueness within the selected set does not establish global participant independence. Original participant codes and complete internal linkage records are not included.

`Unknown` denotes unresolved clinical or experimental-condition annotations. `NA` denotes unavailable or inapplicable information. Neither should be converted to zero or assumed negative. Table S1 includes explanatory notes below its inventory rows; use identifiers to distinguish data rows from notes.

## Time intervals

`data/metadata/time_provenance.tsv` records the public dataset/sample identifiers, longitudinal annotation, preserved earlier interval, final interval, final interval/type leaf, an explicit numeric ATT day where available, and the supporting curated field. Detailed treatment subtypes remain separate from the canonical interval/type leaf.

Final treatment intervals are `(0,7]`, `(7,28]`, `(28,60]`, `(60,120]`, `(120,180]`, `(180,240]`, `(240,360]` and `(360,Inf)`, expressed in days. Day zero is not assigned to a positive treatment interval. Final intervals can be reported when an explicit numeric day remains unresolved; the provenance fields preserve that distinction. No midpoint of a broad interval was imputed for this release.

## Matrix inventory and research classifications

`matrix_inventory.tsv` provides paths relative to the original platform root and stored matrix row/column counts. Paths document provenance; they are not paths expected to exist in this repository. Gene and module matrices have features in rows and samples in columns; cell matrices have samples in rows and cell categories in columns. Zero dimensions accompany unavailable files.

Dataset research classifications are recorded independently of linked study classifications. Propagating every study label to its datasets produces a different quantity. Gene-identifier annotation versions remain unresolved where this is stated in the inventory.

## Estimability

`estimability.tsv` reports planned test-family sizes, estimable dataset-site subsets and estimable original studies. Separate Berry UK training/test datasets give six dataset-site subsets but five regional cohorts. A category may have one estimable original study and no pooled estimate; this is not a zero effect.
