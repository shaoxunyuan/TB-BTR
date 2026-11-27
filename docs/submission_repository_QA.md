# Repository QA for manuscript submission

Scope of this round: documentation, environment specification, licence and citation metadata, and repository presentation. No data totals, analysis logic, or statistical code were changed. `scripts/validate_release.py` and `scripts/reproduce_fixed_case.R` were not modified.

Repository: https://github.com/shaoxunyuan/TB-BTR
Web platform: http://tbbtr.njucm-bioinfo.cn:9191/
Data snapshot: 27 November 2026

## A. Changes by file

| File | Status | Change |
| --- | --- | --- |
| `README.md` | Modified | Added the caveat that the default scope is not a strictly verified unstimulated cohort; restated licensing as three separate categories; alignment of the citation line with the manuscript author order; replaced the environment-verification paragraph with a record of both tested environments; `docs/submission_repository_QA.md` reference added to the tree listing |
| `environment.yml` | Modified | Replaced the unsolvable `r-metafor=5.2.1` pin with `r-metafor=5.0_1`, the highest version available on conda-forge, with an inline note on the verified CRAN version. Environment name remains `tb-btr` |
| `docs/data_dictionary.md` | Modified | Final diagnosis-relative window corrected from an open-ended lower bound to the closed interval `[-21,0]`, matching Table S1; added the statement that the diagnosis-relative scale is closed at day 0 while day zero is excluded from positive treatment intervals |
| `docs/data_use.md` | Modified | Licensing section restructured into project-authored source code, project-authored annotations, and third-party material, each with its own terms |
| `CITATION.cff` | Modified | Authors set to manuscript order (Zhu, Wang, Yuan, Gu); abstract and keywords updated. Top-level `license` field removed, because a bare `license: MIT` would describe the dataset deposit as MIT-licensed while the licence file scopes MIT to source code only |
| `LICENSE` | Modified | Added a scope notice before the MIT text, restricting the grant to project-authored source code and excluding third-party data, reference matrices, and publications |
| GitHub About | Manual action required | Description, website, and topics not set. No authenticated `gh` session was available |
| Release / tag | Manual action required | No tag or release created. No authenticated `gh` session was available |

Unchanged in this round: `scripts/validate_release.py`, `scripts/reproduce_fixed_case.R`, `reproducibility/fixed_case/methods/*.R`, all files under `data/`, all files under `reproducibility/fixed_case/` other than documentation, `.gitignore`, `.gitattributes`.

### Problem found and corrected during QA

`environment.yml` inherited `r-metafor=5.2.1` from the previous round. That version does not exist on conda-forge, so `conda env create -f environment.yml` failed with `PackagesNotFoundInChannelsError`. The pin was changed to `5.0_1`, which resolves. A clean environment was then created from the file and the full analysis was rerun in it; see section C.

## B. Consistency results

| Item | Value | Verified against |
| --- | --- | --- |
| Environment name | `tb-btr` in `environment.yml`, `conda activate tb-btr` in README | Created from `environment.yml` and activated under that name |
| Diagnosis-relative intervals | `(-Inf,-540)`, `[-540,-360)`, `[-360,-180)`, `[-180,-60)`, `[-60,-21)`, `[-21,0]` | Table S1 worksheet S1D, and 66 records in `data/metadata/time_provenance.tsv` that carry `[-21, 0]` |
| Treatment-relative intervals | `(0,7]`, `(7,28]`, `(28,60]`, `(60,120]`, `(120,180]`, `(180,240]`, `(240,360]`, `(360,Inf)` | Table S1 worksheet S1D |
| Day zero handling | Day zero excluded from positive treatment intervals; included in the final diagnosis-relative window | `docs/data_dictionary.md`, stated in both contexts |
| Licence scope | MIT for project-authored source code only; annotations reused with attribution; third-party material under original terms | `LICENSE` scope notice, `README.md`, `docs/data_use.md` |
| Citation authors | Zhu Shanshan, Wang Kai, Yuan Shaoxun, Gu Wanjun | `CITATION.cff`, parsed and checked for field validity |
| Catalogued study records | 98 | `validate_release.py`; Table S1 worksheet S1A |
| Datasets | 82 | `validate_release.py` output |
| Expression-profile records | 11,820 | `validate_release.py` output |
| Default-scope records | 10,785 across 79 datasets | `validate_release.py` output |
| Fixed-case records | 369 | `validate_release.py` output; `sample_manifest.tsv` |
| ATB / LTBI UC | 203 / 166 | `sample_manifest.tsv` group counts |
| Regional cohorts | 5 | `sample_manifest.tsv` cohort counts |
| Original studies | 3 | `sample_manifest.tsv` study assignment |

### Terminology search

| Term | Occurrences in public files | Assessment |
| --- | --- | --- |
| Internal server conda environment name | 0 | Removed everywhere; the only environment name in the documentation is `tb-btr` |
| Open-ended final diagnosis-relative bound | 0 | Replaced by the closed interval `[-21,0]` |
| `CIBERSORTx` | 2 | Both occurrences are explicit negations in `docs/analysis_methods.md` and `Figure4_deconvolution.R`, stating the implementation is not CIBERSORT/CIBERSORTx |
| `MetaIntegrator` | 0 | Not claimed anywhere |
| `ssGSEA` | 0 | Not claimed anywhere |
| `GSVA` | 0 | Not claimed anywhere |

Counts were taken across the repository excluding this report. This file names the search terms in order to record the check, so a grep run after it was added will also match the rows above.

The fixed case study is described throughout as weighted active-set NNLS with LM22 as primary reference, ImmunoStates as sensitivity reference, within-region and within-study fixed-effect inverse-variance aggregation, DerSimonian–Laird random effects with Knapp–Hartung inference across three original studies, and BH correction within the 11 and 13 planned test families. This matches the deposited code.

## C. QA command results

Two environments were tested. Both runs are reported, since the point of the second was to check the environment file rather than the server environment.

### Environment 1: existing analysis environment

R 4.5.2, metafor 5.2.1, Python 3.11.17, openpyxl 3.1.5.

```text
$ python scripts/validate_release.py
Validated 82 datasets, 11820 records, 10785 default-scope records and 369 selected records.

$ Rscript scripts/reproduce_fixed_case.R reproducibility/fixed_case <outdir>
Recomputed GSE19439-GPL6947
Recomputed GSE19444-GPL6947
Recomputed GSE19442-GPL6947
Recomputed GSE37250-GPL10558
Recomputed GSE39939-GPL10558
PASS: public bundle reproduces fixed-case fractions and pooled estimates. Maximum fraction error: 4.996004e-16
```

### Environment 2: created from `environment.yml`

```text
$ conda env create -f environment.yml
$ conda activate tb-btr
R 4.5.2, metafor 5.0.1, Python 3.11.18, openpyxl 3.1.5

$ python scripts/validate_release.py
Validated 82 datasets, 11820 records, 10785 default-scope records and 369 selected records.

$ Rscript scripts/reproduce_fixed_case.R reproducibility/fixed_case <outdir>
Recomputed GSE19439-GPL6947
Recomputed GSE19444-GPL6947
Recomputed GSE19442-GPL6947
Recomputed GSE37250-GPL10558
Recomputed GSE39939-GPL10558
PASS: public bundle reproduces fixed-case fractions and pooled estimates. Maximum fraction error: 4.996004e-16
```

### Cross-environment comparison

All five generated tables were compared byte for byte between the two runs:

```text
recomputed_fractions.tsv   identical
dataset_effects.tsv        identical
study_effects.tsv          identical
pooled_effects.tsv         identical
deconvolution_qc.tsv       identical

pooled g max difference: 0
fdr max difference:      0
hk_fdr max difference:   0
```

Both runs were written to separate temporary directories. The deposited reference outputs were not modified, no tolerance was relaxed, and no check was removed.

## D. Git state

```text
$ git status
## main...origin/main [ahead 1]

$ git diff --check
(no output)

$ git show --stat HEAD
 CITATION.cff            | 25 ++++++++++++++-----------
 LICENSE                 | 15 +++++++++++++++-
 README.md               | 16 ++++++++++++----
 docs/data_dictionary.md |  2 +-
 docs/data_use.md        | 10 ++++++++--
 environment.yml         |  4 +++-
 6 files changed, 52 insertions(+), 20 deletions(-)
```

Commit: `c3b15be` — Prepare TB-BTR repository for manuscript submission.

No binary files, temporary files, caches, `.DS_Store`, Word lock files, or files above 3 MB were added. No absolute server paths, account names, tokens, or credentials appear in the public documents. `results/` remains ignored by `.gitignore` and was not committed.

## Manual actions outstanding

These require GitHub authentication, which was unavailable in this session. No part of them was performed or simulated.

### 1. Repository About

```bash
gh auth login

gh repo edit shaoxunyuan/TB-BTR \
  --description "TB-BTR: a curated and analysis-ready human blood transcriptome resource for tuberculosis research." \
  --homepage "http://tbbtr.njucm-bioinfo.cn:9191/" \
  --add-topic tuberculosis \
  --add-topic transcriptomics \
  --add-topic bioinformatics \
  --add-topic gene-expression \
  --add-topic blood-transcriptome \
  --add-topic meta-analysis \
  --add-topic immune-cell-deconvolution \
  --add-topic reproducible-research
```

Verify with `gh repo view shaoxunyuan/TB-BTR`.

### 2. Submission release

`CITATION.cff` remains at `version: 0.1.0`. It should only be changed to `1.0.0` in the same step that creates the release, with `date-released` set to the actual release date.

```bash
git tag -a v1.0.0 -m "TB-BTR manuscript submission release"
git push origin v1.0.0

gh release create v1.0.0 \
  --title "TB-BTR manuscript submission release" \
  --notes "Data snapshot: 27 November 2026

- 98 catalogued study records
- 82 datasets
- 11,820 expression-profile records

This release accompanies the TB-BTR manuscript submission and contains the
public resource inventories, harmonized annotations, supplementary tables, and
reproducibility materials for the fixed ATB versus LTBI UC immune-cell analysis."
```

Then update `CITATION.cff` to `version: 1.0.0` with the release date and commit. The data snapshot date of 27 November 2026 is the data freeze date and should not be changed to match the release date.

### 3. Outstanding scientific question

The expression-scale rule in `reproducibility/fixed_case/methods/Figure4_deconvolution.R` back-transforms matrices whose maximum is below 50 using `2^x - 1`. All five deposited matrices fall in that range. For log2 intensities the conventional inverse is `2^x`; the two differ by roughly 6% at the low end before column normalisation. This was documented in `docs/analysis_methods.md` but not changed, since it affects the reported scientific result and is a decision for the project lead.

The alternative inverse was recomputed on 27 November 2026 for GSE19439-GPL6947: replacing `2^x - 1` with `2^x` changed the eleven mapped LM22 fractions by at most 0.0039 and by 0.0007 on average, well below the pooled effect sizes and confidence intervals reported for Figure 4. The rule is therefore retained as documented rather than corrected in the deposited code.
