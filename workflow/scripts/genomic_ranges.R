message("Now loading required packages...")
library(plyr)
library(dplyr)
library(tibble)
library(minfi)
library(IlluminaHumanMethylationEPICanno.ilm10b4.hg19)
library(IlluminaHumanMethylationEPICmanifest)

message("Proceeding with sample QC...")
# file paths 
## input
dasen_betaset_sampleQC_path = 'intermediate/dasen_betaSet_sampleQC.RDS'
master_sheet_85bs_path = 'intermediate/master_sheet_cell-types_85bsc.csv'

## Output
betaset_out_path = "intermediate/dasen_betaSet_filtered.RDS"
granges_out_path = "intermediate/betaSet_granges.RDS"

# import 
clinical <- read.csv(master_sheet_85bs_path, stringsAsFactor = FALSE)
betaSet = readRDS(dasen_betaset_sampleQC_path)

# Compute Cell-type proportions
# Add genomic ranges
message("Now adding genomic ranges...")
epic.hg19 <- getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b4.hg19)
epic.hg19.gr <- epic.hg19 %>% makeGRangesFromDataFrame(start.field = "pos", end.field = "pos", keep.extra.columns = T)

message("Now restricting CpGs to ones present in Illumina's hg19 genome...")
betaSet <- betaSet[rownames(betaSet) %in% names(epic.hg19.gr),]
message("Probes after restricting to those present in hg19 genome...")
print(nrow(betaSet))

rowData <- epic.hg19.gr[rownames(betaSet),]
data <- betaSet[,colnames(betaSet) %in% clinical$barcodes]

message("Now saving filtered betaSet...")
saveRDS(data, betaset_out_path)
saveRDS(rowData, granges_out_path)


