source('bin/CorticalClock/PredCorticalAge/CorticalClock.r')
library(readr)

dnam.raw <- read_tsv('resources/rosmap/ROSMAP_arrayMethylation_imputed.tsv.gz')
betas <- as.data.frame(dnam.raw)
rownames(betas) <- betas[[1]]
betas <- betas[ , -1]

meta <- read_csv('intermediate/rosmap_biolearn_metadata.csv')

CorticalClock(betas, meta, 'bin/CorticalClock/PredCorticalAge/',  'id', 'age')