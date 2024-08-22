message("Now loading required packages...")
library(plyr)
library(dplyr)
library(tibble)
library(minfi)
library(DMRcate)
library(DMRcatedata)

# file paths 
## input
rgsets_path = 'intermediate/RGSet.RDS'
dasen_betaset_path = 'intermediate/dasen_betaSet.RDS'
smk_probes_path = 'resources/NIHMS817273-supplement-001506_-_Supplemental_Tables.xlsx'

## Output
dasen_betaset_QC_path = 'intermediate/dasen_betaSet_probeQC.RDS'

# Load RGSet and betaSet Object (if created)
message("Now loading RGSet and betaSet object...")
RGSet <- readRDS(rgsets_path)
betaSet <- readRDS(dasen_betaset_path)

# Probe Filtering #####

# Compute detection p-values
## Remove those that are not signficant; could use 0.01 to be more rigours; ADNI use 0.05
## for every genomic position, there is a pvalue, significant is a good position 
message("Now computing detection p-values from RGSet...")
detP <- detectionP(RGSet, type = "m+u")
failed_05 <- detP > 0.05
passed_probes <- rownames(failed_05)[rowMeans(failed_05) == 0]
#sum(rowMeans(failed_05) == 0)

message("Total number of probes...")
print(nrow(betaSet))

# Apply inital QC steps
## Keep those with cg; ch, chromsome, location, fwd/rev
betaSet <- betaSet[rownames(betaSet) %in% passed_probes, ]
message("Probes with p<0.05...")
print(nrow(betaSet))
#print(nrow(rownames(betaSet)[!grepl("^cg", rownames(betaSet))])) #how many non-cpg methylation sites
betaSet <- betaSet[grep("cg",rownames(betaSet)),]
message("Probes that start with cg...")
print(nrow(betaSet))

# Filter probes
## Requires the following three datasets from ExperimentHub. 
## May need to download into cache
# eh <- ExperimentHub()
# snpsall <- eh[["EH3130"]]
# crosshyb <- eh[["EH3129"]]
# XY.probes <- eh[["EH3131"]]

message("Now filtering probes...")
betaSet <- rmSNPandCH(
  object = betaSet,
  dist = 5,
  mafcut = 0.01,
  and = TRUE,
  rmcrosshyb = TRUE,
  rmXY = TRUE
)
message("Probes after filtering...")
print(nrow(betaSet))

# Remove probes associated with cigarette smoking
# ADNI paper didnt do this; did this becuase this maybe a good thing to do
# message("Now removing smoking probes...")
# smoking <- readxl::read_xlsx(smk_probes_path,
#   sheet = "02",
#   skip = 2, 
#   guess_max = 20000
# )

# smoking_sig_probes <- smoking %>%
#   dplyr::filter(`P-value` < 1*10^(-7)) %>%
#   dplyr::pull("Probe ID")

# betaSet <- betaSet[!rownames(betaSet) %in% smoking_sig_probes,]

# message("Probes after excluding smoking-related...")
# print(nrow(betaSet))

message("Now saving Probe QC betaSet...")
saveRDS(betaSet, dasen_betaset_QC_path)
