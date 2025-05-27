#check readme

#process data .

library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"
HP_dat <- read.csv( paste0(PATH_wk, "HP/results/4_1_process.csv"))

HP_dat <- HP_dat %>% 
  rename(IID = X)
#add features:
#* added imputed C-peptide
#* added SNP-level genotype data
#* added BMI quantile and BMI z-score according to CDC growth chart
#* duration of diabetes (months)
#* total daily insulin dose are scaled in units/kilogram/day.
#* added model validation using 10-fold cross-validation
#* Note that Insulin pump therapy (yes/no) data is missing from the dataset. We will not be able to include this variable in our analysis for now.

#load imputed c-peptide data
imputed_c_pep = read.csv('C:/Per/LaiJiang/Project/ADDAM/HP/results/2_4_C_pep.csv')


HP_dat_add_fts <- merge(HP_dat, imputed_c_pep, by = "IID")

#remove Cluster_insulin and cluster_total_insulin_dose
HP_dat_add_fts <- HP_dat_add_fts %>% 
  select(-c(Cluster_insulin, cluster_total_insulin_dose))

#add BMI quantile and BMI z-score according to CDC growth chart
bmi_dat = read.csv(paste0(PATH_wk, "HP/results/2_5_bmi.csv"))

HP_dat_add_fts <- merge(HP_dat_add_fts, bmi_dat, by = "IID")

HP_dat_add_fts <- HP_dat_add_fts %>% 
  select(-"cluster_BMI")

########################
#load SNP-level genotype data
geno_dat = read.csv(paste0(PATH_wk, "HP/results/2_6_geno.csv"))

HP_dat_add_fts <- merge(HP_dat_add_fts, geno_dat, by = "IID")


rownames(HP_dat_add_fts) <- HP_dat_add_fts$IID
HP_dat_add_fts$IID <- NULL

#save file
write.csv(HP_dat_add_fts, paste0(PATH_wk, "HP/results/4_2_process_updates.csv"))
