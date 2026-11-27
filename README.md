# TB-BTR: data and reproducible analyses

TB-BTR (Tuberculosis Blood Transcriptome Resource) links curated clinical annotations to human blood transcriptomic datasets for tuberculosis research.

- **Web platform:** http://tbbtr.njucm-bioinfo.cn:9191/
- **Data snapshot:** 27 November 2026
- **Scope:** 98 catalogued study records, 82 datasets and 11,820 expression-profile records.

This repository provides the public resource inventories, harmonized annotations, supplementary tables and reproducible inputs and code for the illustrative ATB–LTBI UC comparison. It is a data and analysis companion to the platform, rather than a complete web-server distribution.

## Contents

| Path | Contents |
| --- | --- |
| `data/tables/` | Table 1 and Supplementary Tables S1 and S2, including their worksheet definitions and notes |
| `data/metadata/` | Final sampling intervals and provenance, dataset research classifications and matrix dimensions, and cell-category estimability |
| `reproducibility/fixed_case/` | Selected expression inputs, reference signatures, mappings, sample manifest, expected results and sensitivity analyses |
| `scripts/reproduce_fixed_case.R` | Recompute the illustrative case from the included expression inputs |
| `scripts/validate_release.py` | Check inventory totals, sample identifiers, selection links and agreement between tables and public metadata |
| `docs/` | Data definitions, analysis methods and third-party attribution |
| `environment.yml` | Dependencies for validation and reproduction |

## Reproduce the analysis

The analysis requires R and `metafor`; Python with `openpyxl` is used for metadata validation. The supplied inputs have been tested with R 4.5.2 and metafor 5.2.1. Run from the repository root:

On a new machine, an environment can be prepared with `conda env create -f environment.yml`, followed by `conda activate YSXconda_iRABIT`. Skip environment creation when using an existing suitable environment. The environment file describes dependencies; the validation below was performed in the existing server environment.

```bash
python scripts/validate_release.py
Rscript scripts/reproduce_fixed_case.R reproducibility/fixed_case results/fixed_case
```

For the original server environment:

```bash
/home/yuanshaoxun/configurations/miniconda3/envs/YSXconda_iRABIT/bin/python scripts/validate_release.py
/home/yuanshaoxun/configurations/miniconda3/envs/YSXconda_iRABIT/bin/Rscript scripts/reproduce_fixed_case.R reproducibility/fixed_case results/fixed_case
```

The R script estimates LM22 and ImmunoStates relative contributions using weighted active-set NNLS, computes standardized effects, combines regional estimates within original studies, and performs DerSimonian–Laird and Knapp–Hartung analyses. It compares the recomputed sample-level contributions and pooled estimates with the included reference outputs and stops if differences exceed `1e-8`. Generated files are written to `results/`, which is excluded from version control.

## Interpret the data

The 11,820 records describe the full collection. They include repeated visits, technical or assay replicates, condition-specific aliquots and pooled material. They are not a globally deduplicated participant count. The 98 study records include original and secondary publications.

Known ex vivo stimulated samples (552 records) and cultured controls (483 records) are excluded from default platform analyses, leaving 10,785 records across 79 datasets before additional selection. Experimental conditions for the remaining records are Unknown; this does not establish that every retained specimen was unstimulated.

The fixed exploratory case contains 369 selected HIV-negative whole-blood microarray records (203 ATB and 166 LTBI UC), five datasets and five regional cohorts from three original studies. Its original-study pooling differs from the general online dataset-level pooling workflow. Inferred cellular contributions depend on the reference and input scale. The input transformation assumptions, incomplete pretreatment ascertainment and source-specific participant linkage are described in [analysis methods](docs/analysis_methods.md).

The included gene-expression inputs contain only the selected records and the union of genes needed by the two reference matrices. Complete processed expression matrices for all 82 datasets are **not** included here. Matrix dimensions and accessions are provided for provenance and retrieval; they do not constitute independent validation of all upstream preprocessing.

## Data sources and attribution

Original data are available through GEO, BioProject/SRA and ArrayExpress/BioStudies. Supplementary Table S1 supplies accession and publication links. The illustrative case draws on Berry et al. (2010), Kaforou et al. (2013) and Anderson et al. (2014); source links are also included in `reproducibility/fixed_case/primary_sources.tsv`.

Please cite the original datasets, studies and methods when reusing these materials. Third-party data and reference signatures retain their original attribution and terms; see [data use and attribution](docs/data_use.md). This repository does not assign a new blanket license to third-party materials.

Questions and reproducibility issues can be reported through this repository's Issues page.
