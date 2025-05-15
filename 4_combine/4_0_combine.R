#combine all data files together

library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"

#first load the response variable 

#Y_file <- read.csv(paste0(PATH_wk, "HP/3_response/Composite_with_elevated_bp_group.csv"))
Y_file_load <- read.csv(paste0(PATH_wk, "HP/dat/BP_2_process.csv"))

#rename "Record ID (XX-XXX-XX)" to IID
Y_file <- Y_file_load %>%
  rename(Y = "Y_elevated") %>%
  rename(age_BP = "days_from_DOB_to_BP1") %>%
  select(IID, age_BP, Y)



#
#X_clinical
#X_clustering
#x_antibody
#X_GRS
######################################################################################
#1. load clinical variables
X_clinical <- read.csv(paste0(PATH_wk, "HP/results/2_clinic.csv"))

#2. load the pre-existing clustering variables from the previous report
X_clustering <- read.csv(paste0(PATH_wk, "dat/cluster_clinical.csv"))

#
features_keep <- c("Cluster_age", "Cluster_diabete_history", 
                   "Cluster_sex", "Cluster_family_diabetes",
                   "Cluster_subjectID", "Cluster_insulin",
                   "Cluster_A1c")
X_clustering <- X_clustering[,features_keep]
#rename Cluster_subjectID to IID
X_clustering <- X_clustering %>% rename(IID = "Cluster_subjectID")

######################################################################################
#3. load the antibody variables from the previous report
X_antibody_ori <- read.csv(paste0(PATH_wk, "HP/dat/2_3_atb_ori.csv"))
X_antibody_updates <- read.csv(paste0(PATH_wk, "HP/dat/2_3_atb_updates.csv"))

colnames(X_antibody_updates) <- colnames(X_antibody_ori)

x_antibody <- bind_rows(X_antibody_ori, X_antibody_updates)
x_antibody <- x_antibody %>% rename(IID = Subject)


#now attach the DOB from Y_file_ori to x_antibody
x_antibody <- x_antibody %>%
  left_join(Y_file_load %>% select(IID, DOB, Y_elevated), by = "IID") %>%
   filter(!is.na(Y_elevated)) %>% filter(Draw.Date != "") 


x_antibody$DOB_date       <- as.Date(x_antibody$DOB,       format = "%d/%m/%Y")
x_antibody$Draw_date <- as.Date(x_antibody$"Draw.Date", format = "%Y-%m-%d")

# 2) compute the difference in days
x_antibody$age_atb <- as.numeric(x_antibody$Draw_date - x_antibody$DOB_date)


#####################################################################################################

#genetic risk scores
X_GRS <- read.table(paste0(PATH_wk, "HP/results/1_GRS.txt"),header=TRUE)

X_GRS <- X_GRS %>% select(IID, GRS)
#######################################################################################################

#find overlapping IID of 
#Y_file  
#X_clinical
#X_clustering
#x_antibody
#X_GRS




#  build one data.frame by inner‐joining all five,
#    then look at its IID column
df_all <- Y_file %>%
  inner_join(X_clinical,   by = "IID") %>%
  inner_join(X_clustering, by = "IID") %>%
  inner_join(x_antibody,   by = "IID") %>%
  inner_join(X_GRS,        by = "IID")

#remove Draw.Date and any column names with Qual in it
df_all <- df_all %>% select(-Draw.Date, -contains("Qual"), -DOB, -DOB_date, -Draw_date, -Y_elevated)

#remove the Index from column names
df_all <- df_all %>% rename_with(~ gsub(".Index", "", .), everything())

#save df_all
#write.csv(df_all, paste0(PATH_wk, "HP/results/4_combine.csv"), row.names = FALSE)

plot(df_all$Cluster_age)
df_all$IID[which.max(df_all$Cluster_age)]

#we removed the patient 01-309-04 because he is an outlier from the age group:age_atb
#he is born on 1999-08-01, hes not in pediatric group for both antibody and BP measurement 

#remove the patient 01-309-04 from df_all
df_all <- df_all %>% filter(IID != "01-309-04")
#save df_all
write.csv(df_all, paste0(PATH_wk, "HP/results/4_combine.csv"), row.names = FALSE)

####################################################################