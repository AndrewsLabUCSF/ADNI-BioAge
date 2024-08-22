# Load in required packages
# use install.packages() or BiocManager::install()
message("Now loading required packages...")
library(plyr)
library(dplyr)
library(tibble)
library(minfi)
library(lumi)
library(limma)
library(wateRmelon)
library(DMRcate)
library(DMRcatedata)
library(IlluminaHumanMethylationEPICanno.ilm10b4.hg19)
library(IlluminaHumanMethylationEPICmanifest)
library(SummarizedExperiment)
library(EpiDISH)
library(meffil)
library(S4Vectors)
library(sm) 

# Define paths
message("Now defining paths...")
base_dir <- "intermediate/"
ss_path <- "resources/adni/data/DNAm/ADNI_DNA_Methylation_SampleAnnotation_20170530.xlsx"
idat_dir <- "resources/adni/data/DNAm/"
proc_dir <- "intermediate/"
smoke_dir <- "path to directory with smoking-associated probes"
#download smoke probes from "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5267325/bin/NIHMS817273-supplement-001506_-_Supplemental_Tables.xlsx"

# Load in sample sheet and create "barcodes" column
message("Now updating sample sheet...")
df <- readxl::read_xlsx(ss_path)
Basename <- meffil.basenames(idat_dir, recursive = FALSE)
basenames <- data.frame(Basename)
basenames$split <- sub("^.*/", "", basenames$Basename)
colnames(basenames)[2] <- "barcodes"
targets <- merge(df, basenames, by = "barcodes", all.y = T) # can merge with ADNIMERGE to get desired covariates

write.csv(targets, file.path(base_dir, "master_sheet.csv"), row.names = F)


# Create RGSet Object
message("Now creating RGSet object...")
#targets <- read.csv(file.path(base_dir, "master_sheet.csv"), stringsAsFactor = FALSE)
RGSet <- read.metharray.exp(idat_dir, recursive = TRUE, verbose = TRUE, targets = targets)

message("Now saving RGSet as RDS...")
saveRDS(RGSet, file.path(proc_dir, "RGSet.RDS"))
# rm(RGSet)

# Load RGSet Object (if created)
# message("Now loading RGSet object...")
# RGSet <- readRDS(file.path(proc_dir, "RGSet.RDS"))

# Obtain raw beta and m-value matrices, then save (if needed for comparisons)
# message("Now computing beta set...")
# beta <- getBeta(RGSet)
# 
# message("Now saving betaSet raw...")
# saveRDS(beta, file.path(proc_dir, "raw_betaSet.RDS"))
# 
# message("Now converting betas to m-values...")
# mval <- lumi::beta2m(beta)
# 
# message("Now saving mSet raw...")
# saveRDS(mval, file.path(proc_dir, "raw_mSet.RDS"))
# 
# rm(beta, mval, pheno)

# Normalize RGSet via dasen method
message("Now performing dasen normalization...")
dasenSet <- wateRmelon::dasen(RGSet) #returns beta matrix

message("Now saving dasenSet...")
saveRDS(dasenSet, file.path(proc_dir, "dasenSet.RDS"))

# Load dasen normalized dataset
# message("Now loading dasenSet object...")
# dasenSet <- readRDS(file.path(proc_dir, "dasenSet.RDS"))

# Access dasen-normalized betas 
message("Now computing dasen betaSet...")
betaSet <- getBeta(dasenSet)
message("Now saving dasen-normalized betaSet...")
saveRDS(betaSet, file.path(proc_dir, "dasen_betaSet.RDS"))
#betaSet <- readRDS(file.path(proc_dir, "dasen_betaSet.RDS"))
rm(dasenSet)

# Probe Filtering #####

# Compute detection p-values
message("Now computing detection p-values from RGSet...")
detP <- detectionP(RGSet, type = "m+u")
failed_05 <- detP > 0.05
passed_probes <- rownames(failed_05)[rowMeans(failed_05) == 0]
#sum(rowMeans(failed_05) == 0)

message("Total number of probes...")
print(nrow(betaSet))

# Apply inital QC steps
betaSet <- betaSet[rownames(betaSet) %in% passed_probes, ]
message("Probes with p<0.05...")
print(nrow(betaSet))
#print(nrow(rownames(betaSet)[!grepl("^cg", rownames(betaSet))])) #how many non-cpg methylation sites
betaSet <- betaSet[grep("cg",rownames(betaSet)),]
message("Probes that start with cg...")
print(nrow(betaSet))

# Filter probes
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
message("Now removing smoking probes...")
smoking <- readxl::read_xlsx(
  file.path(smoke_dir, "NIHMS817273-supplement-001506_-_Supplemental_Tables.xlsx"),
  sheet = "02",
  skip = 2
)

smoking_sig_probes <- smoking %>%
  dplyr::filter(`P-value` < 1*10^(-7)) %>%
  dplyr::pull("Probe ID")
betaSet <- betaSet[!rownames(betaSet) %in% smoking_sig_probes,]
message("Probes after excluding smoking-related...")
print(nrow(betaSet))

# Sample  Filtering #####
message("Total number of samples...")
print(length(unique(targets$RID)))

# Remove technical duplicates and samples with bisulfite < 85%
message("identifying any technical replicates...")
targets$RID_VISCODE <- paste0(targets$RID,"_",targets$VISCODE)
targets$is_replicate <- duplicated(targets$RID_VISCODE)

message("Removing replicates...")
targets <- targets %>% filter(is_replicate == FALSE)
message("Number of samples after removing duplicates...")
print(length(unique(targets$RID)))

keep_samples <- targets %>% pull(barcodes)
betaSet <- betaSet[, keep_samples]
message("Samples with no replicates...")
print(ncol(betaSet))

message("identifying bisulfite conversion < 85%...")
bsc <- data.frame(bisulfiteConversion = bscon(RGSet))
passed_bsc <- rownames(bsc)[bsc$bisulfiteConversion >= 85]

betaSet <- betaSet[, colnames(betaSet) %in% passed_bsc]
message("Samples with bsc >= 85...")
print(ncol(betaSet))

rm(RGSet)

# Compute Cell-type proportions
message("Now computing cell-type proportions...")
data(centDHSbloodDMC.m)
BloodFrac.m <- epidish(beta.m = betaSet, ref.m = centDHSbloodDMC.m, method = "RPC")$estF
cell_types <- as.data.frame(BloodFrac.m)
cell_types <- tibble::rownames_to_column(cell_types, "barcodes")

# Merge master w/cell-types
message("Now adding cell-types to master sheet...")
clinical <- merge(targets, cell_types, by = "barcodes", all.x = TRUE, sort = FALSE)
write.csv(clinical, file.path(base_dir, "master_sheet_cell-types.csv"), row.names = F)

message("Now restricting samples with >= 85% bisulfite conversion...")
clinical <- clinical[clinical$barcodes %in% passed_bsc, ]
message("Number of samples with >=85% bisulfite conversion...")
print(length(unique(clinical$RID)))
write.csv(clinical, file.path(base_dir, "master_sheet_cell-types_85bsc.csv"), row.names = F)

rm(BloodFrac.m, cell_types, targets)

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
saveRDS(data, file.path(proc_dir, "dasen_betaSet_filtered.RDS"))

rm(mSet, betaSet)

# Create Summarized Experiment
message("Now creating SummarizedExperiment...")
adni_se <- SummarizedExperiment::SummarizedExperiment(
  assays = SimpleList("DNAm" = data),
  rowData = rowData,
  metadata = list("genome" = "hg19"),
  colData = clinical
)

message("Now saving SummarizedExperiment...")
saveRDS(adni_se, file.path(proc_dir, "dasen_se.RDS"))

message("Now clearing workspace...")
rm(list = ls())

# To access elements in the SummarizedExperiment...
# adni_se <- readRDS(file.path(proc_dir, "dasen_se.RDS"))
# beta <- as.matrix(assays(adni_se)$DNAm)
# mSet <- log2(beta/(1-beta)) # convert beta values to m-values
# pheno <- as.data.frame(colData(adni_se)) # sample sheet/demographic/covariates
