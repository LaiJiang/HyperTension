#load clinical variables 
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"



clinical_updates = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/ADDAM_clustering_MCh_participants_Nov13.csv')
#clinical_ori = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/participants.csv')

#rename "Record.ID..XX.XXX.XX." to IID
clinical_updates <- clinical_updates %>%
  rename(IID = "Record.ID..XX.XXX.XX.")


#load 1st or 2nd degree family history:

source(paste0(PATH_wk, "HP/2_0_family.R"))


#load from cluster_cliical.csv: 
#age


#rename family_history_diabetes to cluster_family_12_degree in clinical_flagged
clinical_flagged <- clinical_flagged %>%
  rename(cluster_family_12_degree = family_history_diabetes)

#rename  "Record ID (XX-XXX-XX)" to IID
clinical_flagged <- clinical_flagged %>%
  rename(IID = "Record ID (XX-XXX-XX)")


#BMI
clinical_updates$cluster_BMI <- clinical_updates$"Subject.s.weight..kg." / (clinical_updates$"Subject.s.height..cm."/100)^2

#Ethnicity (self-reported ethnic origin of 4 grandparents)
#2 features: Predominant ancestry cluster_pred_ancestry
#and acestry diversity: “number of distinct ethnicities” (1–4), or better yet a Shannon‐diversity index:
# cluster_shannon
source(paste0(PATH_wk, "HP/2_0_ancestry.R"))


#Personal history of other autoimmune disease (yes/no, type of autoimmune disease): 

clinical_updates$cluster_autoimmune_disease <- (clinical_updates$Other.medical.condition.s..not.listed.above..please.specify=="")

#family history: Cluster_family_diabetes from cluster_clinical.csv

#1st degree and 2nd degree relatives with diabetes (yes/no): family_history_diabetes


#-Total daily insulin dose (units/kilogram/day)
#create a feature cluster_total_insulin_dose 
clinical_updates$cluster_total_insulin_dose <- clinical_updates$"Current.insulin.total.daily.dose..number.of.units."


#missing: -Multiple daily insulin injections>3 (yes/no) !!!!!!!!!!!!!!!!!

#missing: -Insulin pump therapy (yes/no) and duration (months)

#missing: Insulin (IAA) autoantibody titers (nmol/L), if blood sample taken within 2 weeks of diagnosis
#missing: Imputed basal C-peptide (nmol/l)


#T1D genetic risk score from 1_GRS.txt 

#cluster_A1C from cluster.csv 



#retain columns IID, and all features start with cluster_
clinical_updates <- clinical_updates %>%
  select(IID, starts_with("Cluster_"))


#retain columns IID, and all features start with cluster_ in clinical_flagged
clinical_flagged <- clinical_flagged %>%
  select(IID, starts_with("cluster_"))


#merge clinical_updates and clinical_flagged by IID
clinical <- merge(clinical_updates, clinical_flagged, by = "IID", all.x = TRUE)


#save the file to csv file
write.csv(clinical, paste0(PATH_wk, "HP/results/2_clinic.csv"), row.names = FALSE)