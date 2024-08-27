message("Now loading required packages...")
library(plyr)
library(dplyr)
library(tibble)
library(wateRmelon)
library(EpiDISH)

message("Proceeding with sample QC...")
# file paths 
## input
rgsets_path = 'intermediate/RGSet.RDS'
dasen_betaset_QC_path = 'intermediate/dasen_betaSet_probeQC.RDS'
targets_path <- "intermediate/master_sheet.csv"

## Output
dasen_betaset_sampleQC_path = 'intermediate/dasen_betaSet_sampleQC.RDS'
master_sheet_cell_types_path = 'intermediate/master_sheet_cell_types.csv'
master_sheet_85bs_path = 'intermediate/master_sheet_cell-types_85bsc.csv'

# import 
RGSet = readRDS(rgsets_path)
targets <- read.csv(targets_path, stringsAsFactor = FALSE)
betaSet = readRDS(dasen_betaset_QC_path)

# Sample  Filtering #####
message("Total number of samples...")
print(length(unique(targets$RID)))

## Remove technical duplicates 
## 200 duplicates in datasets; over 99% similar replicates, keep the first appearance; could also average or use batch numbers or scan dates
## Code was removing timepoints
# message("identifying any technical replicates...")
# targets$RID_VISCODE <- paste0(targets$RID,"_",targets$VISCODE)
# targets$is_replicate <- duplicated(targets$RID_VISCODE)

# message("Removing replicates...")
# targets <- targets %>% filter(is_replicate == FALSE)
# message("Number of samples after removing duplicates...")
# print(length(unique(targets$RID)))

# keep_samples <- targets %>% pull(barcodes)
# betaSet <- betaSet[, keep_samples]
# message("Samples with no replicates...")
# print(ncol(betaSet))

## Remove samples with bisulfite < 85%
## Bisulfate converation rate is the sample quality or purity, if a cpg is unmetheated, sulfate 
## Can use other cut-offs; most other ADNI papers didnt do this; only remove a handful 
message("identifying bisulfite conversion < 85%...")
bsc <- data.frame(bisulfiteConversion = bscon(RGSet))
passed_bsc <- rownames(bsc)[bsc$bisulfiteConversion >= 85]

betaSet <- betaSet[, colnames(betaSet) %in% passed_bsc]
message("Samples with bsc >= 85...")
print(ncol(betaSet))

## export
message("Now saving Sample QC betaSet...")
saveRDS(betaSet, dasen_betaset_sampleQC_path)

# Compute Cell-type proportions
## With downstream anlaysis maybe adjust for some of these 
message("Now computing cell-type proportions...")
data(centDHSbloodDMC.m)
BloodFrac.m <- epidish(beta.m = betaSet, ref.m = centDHSbloodDMC.m, method = "RPC")$estF
cell_types <- as.data.frame(BloodFrac.m)
cell_types <- tibble::rownames_to_column(cell_types, "barcodes")

## Merge master w/cell-types
message("Now adding cell-types to master sheet...")
clinical <- merge(targets, cell_types, by = "barcodes", all.x = TRUE, sort = FALSE)
write.csv(clinical, master_sheet_cell_types_path, row.names = F)

message("Now restricting samples with >= 85% bisulfite conversion...")
clinical <- clinical[clinical$barcodes %in% passed_bsc, ]

message("Number of samples with >=85% bisulfite conversion...")
print(length(unique(clinical$RID)))
write.csv(clinical, master_sheet_85bs_path, row.names = F)
