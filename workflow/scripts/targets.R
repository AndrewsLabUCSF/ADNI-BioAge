# Load in required packages
# use install.packages() or BiocManager::install()
message("Now loading required packages...")
# sessionInfo()
# installed.packages()[, 1:2]

library(plyr)
library(dplyr)
library(tibble)
library(readr)
# library(minfi)
# library(lumi)
# library(limma)
# library(wateRmelon)
# library(DMRcate)
# library(DMRcatedata)
# library(IlluminaHumanMethylationEPICanno.ilm10b4.hg19)
# library(IlluminaHumanMethylationEPICmanifest)
# library(SummarizedExperiment)
# library(EpiDISH)
library(meffil)
# library(S4Vectors)
# library(sm) 


# Define paths
message("Now defining paths...")
## sge 
idat_dir = 'resources/adni/data/DNAm/'
ss_path = 'resources/adni/data/DNAm/ADNI_DNA_Methylation_SampleAnnotation_20170530.xlsx'
out_path = 'intermediate/master_sheet.csv'

## Snakemake
# idat_dir = snakemake@params[['idat']]
# ss_path = snakemake@input[['samples']]
# out_path = snakemake@output

# Load in sample sheet and create "barcodes" column
message("Now updating sample sheet...")
df <- readxl::read_xlsx(ss_path)
Basename <- meffil.basenames(idat_dir, recursive = FALSE)
basenames <- data.frame(Basename)
basenames$split <- sub("^.*/", "", basenames$Basename)
colnames(basenames)[2] <- "barcodes"
targets <- merge(df, basenames, by = "barcodes", all.y = T) # can merge with ADNIMERGE to get desired covariates

write_csv(targets, out_path)
