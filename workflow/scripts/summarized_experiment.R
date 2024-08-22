message("Now loading required packages...")
library(plyr)
library(dplyr)
library(readr)
library(tidyr)
library(tibble)
library(SummarizedExperiment)

message("Proceeding with Summarized Experiment...")
# file paths 
## input
data_path = "intermediate/dasen_betaSet_filtered.RDS"
granges_path = "intermediate/betaSet_granges.RDS"
master_sheet_85bs_path = 'intermediate/master_sheet_cell-types_85bsc.csv'
DNAm_calc_probes_path = 'resources/datMiniAnnotation4_fixed.csv'
adni_path = "resources/adni/data/phenotypes/ADNIMERGE_25Sep2023.csv"

## Output
out_path = "intermediate/dasen_se.RDS"

# import 
adni_merge <- readr::read_csv(adni_path)
clinical <- read.csv(master_sheet_85bs_path, stringsAsFactor = FALSE)
data = readRDS(data_path)
rowData = readRDS(granges_path)
DNAm_calc_probes = readr::read_csv(DNAm_calc_probes_path)

# Create Summarized Experiment
message("Now creating SummarizedExperiment...")
adni_se <- SummarizedExperiment::SummarizedExperiment(
  assays = SimpleList("DNAm" = data),
  rowData = rowData,
  metadata = list("genome" = "hg19"),
  colData = clinical
)

beta <- as.matrix(assays(adni_se)$DNAm)
beta_df <- as_tibble(beta, rownames = "ProbeID")

mSet <- log2(beta/(1-beta))
mSet_df <- as_tibble(mSet, rownames = "ProbeID")

pheno <- as_tibble(colData(adni_se))

message("Now saving SummarizedExperiment...")
saveRDS(adni_se, out_path)
readr::write_tsv(beta_df, 'adni_betaSet.tsv.gz')
readr::write_tsv(mSet_df, 'adni_mvalues.tsv.gz')

## Export files for DNA Methylation Age Calculator
message("Now exporting DNA Methylation Age Calculator files...")

DNAm_calc_betas <- beta_df %>%
    semi_join(DNAm_calc_probes, by = c('ProbeID' = 'Name')) 

DNAm_calc_samples <- tibble(
    Sample_Name = colnames(beta_df), 
    Tissue = "Whole Blood"
    ) %>%
    filter(Sample_Name != 'ProbeID') %>%
    left_join(pheno, by = c('Sample_Name' = 'barcodes')) %>%
    left_join(adni_merge %>% filter(VISCODE == "bl"), by = c('RID' = 'RID')) %>%
    select(Sample_Name, Tissue, Age = AGE, Sex = PTGENDER, Group = DX_bl) %>%
    mutate(
        Sex = ifelse(Sex == "Male", 0, 1), 
        Group = case_when(
            Group == 'CN' ~ 'Control', 
            Group == 'SMC' ~ 'Control',      
            Group == 'EMCI' ~ 'Diseased',      
            Group == 'LMCI' ~ 'Diseased',      
            Group == 'AD' ~ 'Diseased',       
        )
    )

readr::write_csv(DNAm_calc_betas, 'intermediate/adni_DNAm_calc.csv')
readr::write_csv(DNAm_calc_samples, 'intermediate/adni_DNAm_samples.csv')

# To access elements in the SummarizedExperiment...
# adni_se <- readRDS(file.path(proc_dir, "dasen_se.RDS"))
# beta <- as.matrix(assays(adni_se)$DNAm)
# mSet <- log2(beta/(1-beta)) # convert beta values to m-values
# pheno <- as.data.frame(colData(adni_se)) # sample sheet/demographic/covariates
