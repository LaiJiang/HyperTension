#process data .

library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"

HP_dat <- read.csv( paste0(PATH_wk, "HP/results/4_combine.csv"))


max(HP_dat$cluster_BMI)

#check how many rows are missing for each column
missing1 <- sapply(HP_dat, function(x) sum(is.na(x)))

#remove these rows with missing values
HP_dat <- HP_dat[complete.cases(HP_dat), ]


######
#code Y into 1 or 0 for Yes or No
#HP_dat$Y <- ifelse(HP_dat$Y == "Yes", 1, 0)



table(HP_dat$cluster_pred_ancestry)
#create 3 dummary variables for each one of the ancestry clusters
HP_dat$cluster_pred_ancestry_Africa <- ifelse(HP_dat$cluster_pred_ancestry == "Africa", 1, 0)
HP_dat$cluster_pred_ancestry_Americas <- ifelse(HP_dat$cluster_pred_ancestry == "Americas", 1, 0)
HP_dat$cluster_pred_ancestry_Europe <- ifelse(HP_dat$cluster_pred_ancestry == "Europe", 1, 0)

#remove the original cluster_pred_ancestry column
HP_dat$cluster_pred_ancestry <- NULL

#########
#update sex information
clinical_info_updates = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/ADDAM_clustering_MCh_participants_Nov13.csv')


HP_dat$Cluster_sex = clinical_info_updates$"Subject.s.Sex.at.Birth"[match(HP_dat$IID, clinical_info_updates$"Record.ID..XX.XXX.XX.")]

HP_dat$Cluster_sex_bin  =  ifelse(HP_dat$Cluster_sex == "Male", 1, 0)
HP_dat$Cluster_sex <- NULL


#convert to numeric 
HP_dat$cluster_family_12_degree_bin <- ifelse(HP_dat$cluster_family_12_degree == "Yes", 1, 0)
HP_dat$cluster_family_12_degree <- NULL



rownames(HP_dat) <- HP_dat$IID
HP_dat$IID <- NULL

#save file
write.csv(HP_dat, paste0(PATH_wk, "HP/results/4_1_process.csv"))
