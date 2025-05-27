#load Batch 2 genotype data
library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"

B2_genotpyes <- read.csv('C:/Per/LaiJiang/Project/ADDAM/res_cluster/cluster_2025_B2_genotype.csv')


B2_bed_file_path = 'G:/projects/ADDAM/Data/TopMed/merged_extracted_from_bim'
B2_bim <- read.table(paste0(B2_bed_file_path, '.bim'),  stringsAsFactors=F)

suffixes <- c("_A1", "_A2", "_A3")

bim_snp_id <- paste0(B2_bim$V1, ":", B2_bim$V4)
snp_col_names <-  unlist(lapply(bim_snp_id, function(x) paste0(x, suffixes)))

#assign B2_geno column names
colnames(B2_genotpyes)[-ncol(B2_genotpyes)] <-snp_col_names

#####################

#load Batch 1 genotype data
B1_dat_file_path = file_path = 'C:/Per/LaiJiang/Project/ADDAM/dat/AM.JDRF.SHARP'


B1_genotypes <- read.csv('C:/Per/LaiJiang/Project/ADDAM/res_cluster/cluster_Oct_genotype.csv')


B1_bim <- read.table(paste0(B1_dat_file_path, '.bim'),  stringsAsFactors=F)

suffixes <- c("_A1", "_A2", "_A3")


bim_snp_id <- paste0(B1_bim$V1, ":", B1_bim$V4)
snp_col_names <-  unlist(lapply(bim_snp_id, function(x) paste0(x, suffixes)))

#assign B2_geno column names
colnames(B1_genotypes)[-ncol(B1_genotypes)] <-snp_col_names


col_int<- intersect(colnames(B1_genotypes), colnames(B2_genotpyes))

#extract the common columns
B1_genotypes <- B1_genotypes[,col_int]
B2_genotpyes <- B2_genotpyes[,col_int]
#combine the two dataframes
B_combined <- rbind(B1_genotypes, B2_genotpyes)

B_combined <- B_combined %>% rename(IID = "Subject")


write.csv(B_combined, paste0(PATH_wk, "HP/results/2_6_geno.csv"), row.names=F, quote=F)