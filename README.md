# Biological Aging 

## Predictors
### DNAm 
A total of 649 ADNI participants hadmethylation data. Participants varied on the number of repeatDNA methylation measurements they had: 83 had only abaseline measurement; 121 had 2 measurements (baseline plus 1repeat), mean 14.5 months between measurements (SD = 7.06);407 had 3 measurements, mean 12.1 months between mea-surements (SD = 1.5); 29 had 4, mean 10.4 months betweenmeasurements (SD = 3.54); and 9 had 5, mean 12.5 monthsbetween measurements (SD = 2.25). [Sugden et al 2022](https://www.neurology.org/doi/10.1212/WNL.0000000000200898)


#### Epigenetic Clocks

-   [Biolearn](https://bio-learn.github.io/clocks.html)

##### First Generation

Primarily estimate biological age based on DNA methylation patterns, aiming to predict chronological age

-   [Horvath 1 2013](https://genomebiology.biomedcentral.com/articles/10.1186/gb-2013-14-10-r115): pan-tissue Horvath clock (353-CpG clock) using 8,000 samples encompassing 51 different tissueand cell types
-   [Horvath 2 2018](https://www.aging-us.com/article/101508/text): we developed a novel and highly robust DNAm age estimator (based on 391 CpGs) for human fibroblasts, keratinocytes, buccal cells, endothelial cells, lymphoblastoid cells, skin, blood, and saliva samples
-   [Hannum 2013](https://www.sciencedirect.com/science/article/pii/S1097276512008933): 71- CpG clock using 656 whole-blood samples
-   [PedBE](https://www.pnas.org/doi/10.1073/pnas.1820843116): 94 CpG clock using 1,721 pediatric (0-20y) buccal epithelial cell samples
-   [Lin 2016](https://www.aging-us.com/article/100908/text): 99 CpG clock predicting age using Lothian Birth Cohort

##### Second Generation

Second-generation clocks are designed to predict health outcomes, morbidity, and mortality more accurately, often incorporating additional clinical or phenotypic data alongside DNA methylation patterns.

-   [Zhang 2017](https://www.nature.com/articles/ncomms14617): 10 CpG clock for mortality risk
-   [PhenoAge 2018](https://pmc.ncbi.nlm.nih.gov/articles/PMC5940111/): uses standard methods but predicts a composite biological age score 31 based on a linear combination of chronological age and nine clinical parameters associated with mortality risk.
-   [GrimAge1 2019](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6366976/): Seven DNAm-based estimators of plasma proteins including those of plasminogen activator inhibitor 1 (PAI-1) and growth differentiation factor 15. The resulting predictor of lifespan, DNAm GrimAge (in units of years), is a composite biomarker based on the seven DNAm surrogates and a DNAm-based estimator of smoking pack-years. Adjusting DNAm **GrimAge** for chronological age generated novel measure of epigenetic age acceleration, **AgeAccelGrim**.
-   [GrimAge2 2022](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9792204/): Here we describe version 2 of GrimAge (trained on individuals aged between 40 and 92) which leverages two new DNAm based estimators of (log transformed) plasma proteins: high sensitivity C-reactive protein (logCRP) and hemoglobin A1C (logA1C). 13,399 blood samples across nine study cohorts.

##### Third Generation

-   [DunedinPoAm38 2022](https://elifesciences.org/articles/54870): Dunedin Study members for whom age-38 DNA methylation data were available (N = 810). We applied elastic-net regression (Zou and Hastie, 2005) using Pace of Aging between ages 26 to 38 years as the criterion.
-   [DunedinPACE 2022](https://elifesciences.org/articles/73420): Improved over PoAM38, longer follow-up, more time points.
-   [CausAge 2024](https://www.nature.com/articles/s43587-023-00557-0): epigenome-wide Mendelian randomization, we identified CpG sites potentially causal for aging-related traits. We established a new framework to introduce causal information into epigenetic clocks, resulting in **DamAge** and **AdaptAge**---clocks that track detrimental and adaptive methylation changes, respectively. DamAge correlates with adverse outcomes, including mortality, while AdaptAge is associated with beneficial adaptations.


### Telomere Length 
Telomere length was measured from DNA isolated from blood via qPCR. A linear mixed effects model was calculated for T/S ratio, including all visits, with plate, row, column, sample type (blood or buffy coat), and months of DNA storage between extraction and qPCR as independent variables. Repeated effects for replicates nested within participants across time used a compound symmetry covariance structure. Standardized residuals from this model were added to the T/S ratio to obtain an adjusted T/S ratio for each DNA sample. Replicates were averaged to obtain one adjusted T/S ratio foreach participant at each visit. This adjusted, averagedvalue (hereafter referred to as simply T/S ratio) wasused for all subsequent analyses. [Nudelman et al. JAD 71 (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7481955/)

The current analyses used T/S ratios adjusted for experimental variables, which were then converted into base pairs using the following calculation: telomere base pairs = 3274 + 2413 * (T/S ratio). [Mahoney et al. A&D 5 (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6926345/)


### mtDNAcn 

Mosdepth was used to count base coverage of both autosomal DNA and mtDNA, with mtDNA estiamted as 2 x mtDNA/nDNA [Tong et al. ART 16:234 (2024)](https://link.springer.com/article/10.1186/s13195-024-01601-w). 

## Outcomes 
### Cognitive function 

Co-calibrated cogntive domain scores [Mukherjee et al. Neuropsychology. 2023 May;37(4):409-423](https://pubmed.ncbi.nlm.nih.gov/35925737/)