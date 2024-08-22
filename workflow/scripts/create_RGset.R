message("Now loading required packages...")
library(plyr)
library(dplyr)
library(readr)
library(tibble)
library(minfi)

# Snakemake
# targets_path = snakemake@input[['samples']]
# idat_dir = snakemake@input[['idat']]
# out_path = snakemake@output

# Bash Script
targets_path = 'intermediate/master_sheet.csv'
idat_dir = 'resources/adni/data/DNAm/'
out_path = 'intermediate/RGSet.RDS'

# Create RGSet Object
message("Now creating RGSet object...")
targets <- read.csv(targets_path, stringsAsFactor = FALSE)
RGSet <- read.metharray.exp(idat_dir, recursive = TRUE, verbose = TRUE, targets = targets)

message("Now saving RGSet as RDS...")
saveRDS(RGSet, out_path)
