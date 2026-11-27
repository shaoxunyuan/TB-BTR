# TB-BTR: Tuberculosis Blood Transcriptome Resource

TB-BTR is a curated resource of human blood transcriptome studies for tuberculosis research. Publicly deposited microarray and RNA-seq studies are assembled into a single catalogue in which study provenance, specimen type, clinical phenotype, treatment timing, and participant linkage are recorded under harmonised definitions.

**Web platform:** http://tbbtr.njucm-bioinfo.cn:9191/

| | |
| --- | --- |
| Catalogued study records | 98 |
| Datasets | 82 |
| Expression-profile records | 11,820 |
| Records within the default analysis scope | 10,785 across 79 datasets |
| Data snapshot | 27 November 2026 |

Detailed breakdowns by repository, assay, specimen, phenotype, and metadata completeness are given in Table 1, which is the authoritative statement of these totals.

## Overview

Blood transcriptional signatures distinguish active tuberculosis from latent infection and from other respiratory disease, but the underlying studies differ in cohort definition, specimen handling, assay platform, and the clinical vocabulary used to describe participants. TB-BTR addresses this by curating published studies against one set of field definitions and phenotype rules, so that records from different sources can be retrieved and compared on a common footing.

The resource supports retrieval of studies and datasets together with their curated annotations; gene-, module-, and cell-level expression queries across studies; and comparative analyses within and across cohorts. It is intended for researchers assembling analysis sets for signature evaluation, immune-cell deconvolution, and pathway-level interpretation, and for readers who need to trace how a published cohort was annotated.

## Web resource

The platform at http://tbbtr.njucm-bioinfo.cn:9191/ provides interactive access to the collection:

- Browsing and searching of catalogued studies and datasets, with sample-level metadata and provenance for each record.
- Expression queries at gene, gene-module (BTM and BloodGen3), and immune-cell level.
- Comparative analyses, including differential gene expression, gene-module group comparison, cell-type fraction comparison against the LM22 and ImmunoStates references, Reactome pathway enrichment, and protein–protein interaction networks.
- Forest plots for summarising effects across datasets, and download of expression and analysis tables.
- A private workspace for analysing user-supplied cohorts alongside the public collection.

This repository is the data and analysis companion to the platform. It distributes the inventories, harmonised annotations, supplementary tables, and the materials needed to reproduce one comparative analysis. It does not contain the platform source code, the complete processed expression matrices for all 82 datasets, or the upstream preprocessing pipeline.

## Data resources

Records derive from NCBI GEO (76 datasets, 10,696 records) and EMBL-EBI ArrayExpress (6 datasets, 1,124 records). Fifty datasets (5,977 records) used microarray platforms and 32 (5,843 records) used RNA-seq. Peripheral whole blood accounts for 10,609 records across 67 datasets and PBMC preparations for 1,211 records across 16 datasets; one dataset contributes records of both specimen types, so these dataset counts overlap.

Clinical annotation follows a harmonised phenotype scheme covering uninfected individuals (UI), latent infection without a supported progressor subdivision (LTBI UC), latent infection with documented non-progression (LTBI NP), incipient TB (ITB), subclinical TB (STB), active TB (ATB), and sampling during active-TB treatment. Healthy and source-defined non-TB disease groups are reported as comparators, and records whose evidence does not support one of these categories remain explicitly unresolved.

Treatment timing is recorded as one of eight intervals from `(0,7]` to `(360,Inf)` days after treatment initiation, with the earlier source interval preserved alongside the final assignment. Progression-associated sampling is recorded separately, in diagnosis-relative windows, so that timing is not conflated with cross-sectional phenotype.

Participant linkage is available for 8,272 records across 46 datasets, contributing 4,048 source-scoped identifiers. Two annotation exclusions are applied by default: 552 records from ex vivo stimulation experiments and 483 cultured controls. The resulting default scope of 10,785 records across 79 datasets is the set the platform treats as eligible before further user selection.

## Repository structure

```text
TB-BTR/
├── README.md
├── CITATION.cff
├── environment.yml
├── data/
│   ├── tables/            Table 1, Supplementary Tables S1 and S2
│   └── metadata/          treatment-interval provenance, matrix inventory, estimability
├── docs/
│   ├── analysis_methods.md
│   ├── data_dictionary.md
│   └── data_use.md
├── reproducibility/
│   └── fixed_case/        expression inputs, reference signatures, manifest, outputs
└── scripts/
    ├── validate_release.py
    └── reproduce_fixed_case.R
```

`data/tables/` holds the published tables. `data/metadata/` holds machine-readable tables that support them: per-record treatment-interval provenance, a matrix inventory recording accessions and dimensions with dataset research classifications, and the estimability of each cell category in the case study. `docs/` defines the fields and phenotype rules, documents the analysis, and states the terms attached to third-party material.

## Reproducible case study

The case study addresses whether inferred blood immune-cell composition differs between active tuberculosis and untreated latent infection. It uses 369 HIV-negative whole-blood microarray records, 203 ATB and 166 LTBI UC, drawn from five datasets in three original studies and grouped into five regional cohorts: Berry UK, Berry South Africa, Kaforou Malawi, Kaforou South Africa, and Anderson Kenya. The selection criteria, the record-level manifest, and the study assignments are all deposited, so the analysis set can be rebuilt and checked line by line.

Relative contributions are estimated separately against the LM22 reference, as the primary analysis, and against ImmunoStates, as a reference-sensitivity analysis, using weighted active-set non-negative least squares on reference and sample matrices normalised over shared genes. Standardised effects for ATB minus LTBI UC are computed as Hedges' g within dataset–site strata and combined by fixed-effect inverse-variance weighting across subsets within region and then across regions within original study. The across-study estimates use DerSimonian–Laird random effects with Knapp–Hartung inference, with Benjamini–Hochberg correction applied within the 11 LM22 and 13 ImmunoStates planned test families. Categories supported by fewer than two estimable original studies yield no pooled estimate.

Sensitivity analyses exclude the paediatric cohort and omit individual studies in turn. [`docs/analysis_methods.md`](docs/analysis_methods.md) gives the full specification.

### Inputs

`reproducibility/fixed_case/` contains the source-selected gene matrices for the five datasets, restricted to the selected records and to the genes required by the two reference signatures; the LM22 and ImmunoStates reference matrices with their cell mappings; the sample manifest; the reference outputs for cell fractions and pooled effects; and the sensitivity tables.

### Running

```bash
conda env create -f environment.yml
conda activate tb-btr

python scripts/validate_release.py
Rscript scripts/reproduce_fixed_case.R reproducibility/fixed_case results/fixed_case
```

`scripts/validate_release.py` checks the internal consistency of the deposit: dataset and record totals, uniqueness of dataset–sample identifiers, default-scope counts, coverage of the treatment-interval table, and agreement between Table S1, Table S2, and the analysis manifest.

`scripts/reproduce_fixed_case.R` recomputes cell fractions, dataset- and study-level effects, and pooled estimates from the deposited expression inputs, then compares them with the reference outputs. Agreement is required to within `1e-8`, and the run aborts if any comparison fails. Outputs are written to the directory given as the second argument, which the command above sets to `results/fixed_case`; `results/` is excluded from version control:

| File | Contents |
| --- | --- |
| `recomputed_fractions.tsv` | Per-sample, per-cell fractions for both references |
| `deconvolution_qc.tsv` | Per-sample fit diagnostics: shared genes, KKT residual, weighted residual, fit correlation |
| `dataset_effects.tsv` | Hedges' g and variance for each dataset–site stratum |
| `study_effects.tsv` | Effects aggregated within original study |
| `pooled_effects.tsv` | Random-effects estimates with both correction families |
| `validation.txt` | Maximum absolute deviation from the reference outputs |

The deposited inputs and reference outputs were verified with R 4.5.2, metafor 5.2.1, Python 3.11.17, and openpyxl 3.1.5, and the case study reproduces to a maximum absolute deviation of 5e-16 in the cell fractions. The reported tolerances depend on those versions. `environment.yml` was not independently re-solved from a clean environment; the versions it pins are the ones the verification used.

## Data availability

Original expression data are available from GEO, BioProject/SRA, and ArrayExpress/BioStudies under the accessions listed in Supplementary Table S1; sample-level provenance and repository links are recorded per record in Table S1E. Complete processed matrices for all 82 datasets remain available through the platform and through the originating repositories. The deposited gene matrices cover only the case study, and `data/metadata/matrix_inventory.tsv` records the accession, dimensions, and stored path for every matrix in the collection.

## Citation

A manuscript describing TB-BTR is in preparation. Until it appears, please cite the resource as:

> Yuan S. TB-BTR: Tuberculosis Blood Transcriptome Resource. GitHub repository, 2026. https://github.com/shaoxunyuan/TB-BTR

A machine-readable record is provided in `CITATION.cff`. Studies contributing to the case study — Berry et al. (2010), Kaforou et al. (2013), and Anderson et al. (2014) — should be cited alongside this resource when their data are used, as should the sources of the LM22 and ImmunoStates signatures.

## Licensing and contact

The repository combines project-authored material with data and signatures obtained from other sources, and these are not governed by a single set of terms. The harmonised annotations, derived tables, and analysis scripts produced for TB-BTR may be reused with attribution to the resource. Public expression data, the LM22 and ImmunoStates reference signatures, and third-party software remain subject to the conditions set by their original providers; [`docs/data_use.md`](docs/data_use.md) records those sources and the terms attached to each.

Corrections, questions, and reproduction issues can be raised through the repository's Issues page.
