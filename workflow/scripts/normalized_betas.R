message("Now loading required packages...")
library(plyr)
library(dplyr)
library(tibble)
library(minfi)
library(lumi)

rgsets_path = 'intermediate/RGSet.RDS'
beta_out_path = 'intermediate/raw_betaSet.RDS'
m_out_path = 'intermediate/raw_mSet.RDS'
dasen_set_path = 'intermediate/dasenSet.RDS'
dasen_betaset_path = 'intermediate/dasen_betaSet.RDS'

# Load RGSet Object (if created)
message("Now loading RGSet object...")
RGSet <- readRDS(rgsets_path)

# Obtain raw beta and m-value matrices, then save (if needed for comparisons)
message("Now computing beta set...")
beta <- getBeta(RGSet)
 
message("Now saving betaSet raw...")
saveRDS(beta, beta_out_path)

# can also us a log2 transform
message("Now converting betas to m-values...")
mval <- lumi::beta2m(beta)
 
message("Now saving mSet raw...")
saveRDS(mval, m_out_path)

# Normalize RGSet via dasen method
# returns beta matrix; ADNI paper used the dasen becuase they found it to be the best;
# can also use quantalie normalization 
# before and after normalization to see how it affects sex etc 
message("Now performing dasen normalization...")
dasenSet <- wateRmelon::dasen(RGSet) 

message("Now saving dasenSet...")
saveRDS(dasenSet, dasen_set_path)

# Access dasen-normalized betas 
message("Now computing dasen betaSet...")
betaSet <- getBeta(dasenSet)

message("Now saving dasen-normalized betaSet...")
saveRDS(betaSet, dasen_betaset_path)


