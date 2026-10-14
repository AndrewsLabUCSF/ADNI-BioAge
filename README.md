# ADNI-BioAge

## Biological aging and Alzheimer's disease endophenotypes in ADNI

This repository contains code examining the independent, joint, and interactive associations of three blood-derived biological aging markers with Alzheimer's disease endophenotypes in the Alzheimer's Disease Neuroimaging Initiative (ADNI):

- Epigenetic age estimated using the CausAge DNA methylation clock
- Telomere length measured using quantitative PCR
- Mitochondrial DNA copy number estimated from whole-genome sequencing

The study evaluates associations with cognitive performance and decline, CSF Alzheimer's disease biomarkers, and MRI measures of neurodegeneration.

## Study overview

The study includes up to 640 ADNI participants, with sample sizes varying by outcome and availability of model variables.

Outcomes include:

- Global cognition, memory, executive function, language, and visuospatial ability
- CSF Aβ42, total tau, and phosphorylated tau181
- AD-signature cortical thickness and gray matter volume

Analyses examine each aging marker separately, all three markers jointly, pairwise interactions, and the three-way interaction. Cognitive trajectories are analyzed using linear mixed-effects models. CSF biomarkers and MRI outcomes are analyzed using linear regression.

Primary models account for chronological age, sex, clinical severity, APOE genotype, blood cell composition, and outcome-specific covariates. Sensitivity analyses evaluate alternative clinical adjustment and additional adjustment for BMI and hypertension.

## Repository structure

- [`workflow/scripts/`](workflow/scripts/): methylation processing, aging-marker estimation, dataset preparation, statistical analyses, and figure generation
- [`workflow/envs/R.yaml`](workflow/envs/R.yaml): R environment specification for methylation processing
- [`workflow/Snakefile`](workflow/Snakefile): initial methylation-processing workflow rules
- `resources/`: local source-data files and references, excluded from version control
- `intermediate/`: derived datasets and analysis objects, excluded from version control
- [`results/`](results/): selected analysis outputs and figures
- [`docs/`](docs/): supporting tables and documents
- [`deprecated/`](deprecated/): earlier analysis scripts retained for reference

## Main analysis files

- [`BioAge_data.qmd`](workflow/scripts/BioAge_data.qmd): integrates ADNI data, defines baseline aging markers, constructs outcomes, and produces descriptive summaries
- [`BioAge_analysis.qmd`](workflow/scripts/BioAge_analysis.qmd): primary statistical analyses, figures, result tables, and cardiometabolic sensitivity analyses
- [`BioAge_analysi_noCDR.qmd`](workflow/scripts/BioAge_analysi_noCDR.qmd): analyses without CDR-SB adjustment
- [`BioAge_analysi_dxadj.qmd`](workflow/scripts/BioAge_analysi_dxadj.qmd): analyses using clinical diagnosis adjustment
- [`epi_clocks.py`](workflow/scripts/epi_clocks.py): Biolearn epigenetic clocks and blood-cell deconvolution

The methylation-processing scripts prepare normalized, quality-controlled EPIC array data for aging-marker estimation. Telomere measurements and WGS-derived mitochondrial DNA copy number estimates are imported separately.

## Data and execution

ADNI source data are available through the [LONI Image and Data Archive](https://ida.loni.usc.edu/).

Source data and participant-level intermediate datasets are not distributed through this repository.

The broad analysis sequence is methylation processing and clock estimation, dataset preparation with `BioAge_data.qmd`, and statistical analysis with `BioAge_analysis.qmd`. Execution requires the source datasets, relevant R and Python packages, and adjustment of local paths and dated input filenames.

## Associated manuscript

The final manuscript citation and DOI will be added when available.

## License

Code is distributed under the MIT License. See [`LICENSE`](LICENSE).
