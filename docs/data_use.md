# Data use and attribution

The repository combines material of three kinds: public expression data obtained from community repositories, third-party reference signatures distributed with their authors' permission or terms, and annotations and code produced for TB-BTR. Each is subject to different conditions, summarised below.

## Source expression data

Original data are held by the repositories from which they were obtained. Accessions, repository links, and publication identifiers for every catalogued dataset are listed in Supplementary Table S1 and, for the case study, in `reproducibility/fixed_case/primary_sources.tsv`.

The case study draws on three original studies:

| Study | Citation | Identifier |
| --- | --- | --- |
| Berry et al., 2010 | An interferon-inducible neutrophil-driven blood transcriptional signature in human tuberculosis. *Nature* | PMID [20725040](https://pubmed.ncbi.nlm.nih.gov/20725040/) |
| Kaforou et al., 2013 | Detection of tuberculosis in HIV-infected and -uninfected African adults using whole blood RNA expression signatures. *PLoS Medicine* | PMID [24167453](https://pubmed.ncbi.nlm.nih.gov/24167453/) |
| Anderson et al., 2014 | Diagnosis of childhood tuberculosis and host RNA expression in Africa. *New England Journal of Medicine* | PMID [24785206](https://pubmed.ncbi.nlm.nih.gov/24785206/) |

These publications and their repositories remain the authoritative sources for the measurements. Annotation and phenotype assignment added here is project work and should be attributed to TB-BTR when reused.

## Reference signatures

Two third-party signature matrices are included so that the case study can be recomputed offline.

**LM22** is the 22-cell-type signature introduced with CIBERSORT (Newman et al., *Nature Methods*, 2015; doi:10.1038/nmeth.3337). **ImmunoStates** is the 20-cell-type signature of Vallania et al., *Nature Communications*, 2018 (doi:10.1038/s41467-018-07242-6).

Both matrices and the cell mappings derived from them are redistributed here to support reproduction of the deposited analysis. The terms under which each signature may be redistributed and reused are set by its authors and are not restated or extended by this repository; users should confirm those terms with the original providers before further redistribution or commercial use. The same applies to the gene-module definitions (BTM and BloodGen3) referenced in `data/metadata/matrix_inventory.tsv`.

Neither signature is bundled software. The case study uses an independent weighted NNLS implementation, described in [`analysis_methods.md`](analysis_methods.md), and its outputs are not CIBERSORT results.

## Identifiers and privacy

Records are identified by public repository accessions and public sample identifiers. Participant pseudonyms are source-scoped keys generated for this resource; they are not derived from, and cannot be resolved to, original participant codes. They are provided to make record selection traceable and should not be used to attempt re-identification.

Platform accounts, uploaded private cohorts, service credentials, original participant codes, and internal correspondence are not part of this deposit. The private workspace on the platform holds user-supplied cohorts and is not represented in this repository.

## Licensing

Rights differ across three categories of content in this repository.

**Project-authored source code.** The scripts in `scripts/` and `reproducibility/fixed_case/methods/` are released under the MIT License, reproduced in the root `LICENSE` file, whose scope notice limits that grant to project-authored source code.

**Project-authored annotations and derived tables.** The harmonised annotations, phenotype assignments, treatment-interval assignments, derived tables, and documentation produced for TB-BTR were not built from a third-party template and are made available for reuse with attribution to TB-BTR. They are not covered by the MIT code license, because that license is scoped to source code; requests for permissions beyond attribution should be directed to the maintainers.

**Third-party datasets, signature matrices, and external resources.** Public expression data from GEO and ArrayExpress, the LM22 and ImmunoStates reference signatures, and any third-party software remain subject to the licenses, terms of use, and citation requirements set by their providers. Nothing in this repository's license re-licenses that material, and no such terms are relaxed by its inclusion here.

Users are expected to cite the original studies for any data they reuse, in addition to citing TB-BTR for the curation layer. [`analysis_methods.md`](analysis_methods.md) describes the analysis; this file records attribution and terms only.

Requests concerning permissions, corrections, or additional material can be directed to the maintainers through the repository's Issues page.
