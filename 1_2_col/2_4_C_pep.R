
#add add "imputed C-peptide" as a clinical feature and see if this is associated with the 2 identified clusters;  imputed C-peptide is calculated using the following formula:

#A1c+(Ins)x 4, where Ins is the insulin dose in units/kg/day


library(dplyr)
clinical_updates = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/ADDAM_clustering_MCh_participants_Nov13.csv')
#clinical_ori = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/participants.csv')


plot(clinical_updates[,c(26)],clinical_updates[,c(27)],xlab="Insulin dose (units/kg/day)",ylab="C-peptide (nmol/L)")


#feature: corrected insulin dosage: total daily insulin dose are scaled in units/kilogram/day.
clinical_updates$cor_insulin = clinical_updates[,c(26)]/clinical_updates$"Subject.s.weight..kg."
#feature: C-pep 
clinical_updates$imputed_C_pep = clinical_updates[,c(27)] + (clinical_updates$cor_insulin * 4)


plot( clinical_updates[,c(27)] , (clinical_updates[,c(26)]/clinical_updates$"Subject.s.weight..kg." * 4))

#feature: duration of diabetes (months) as the difference between "Date.of.diabetes.diagnosis" to the "Visit.Date" date
clinical_updates$duration_diabetes = as.numeric(difftime(as.Date(clinical_updates$"Visit.Date", format="%m/%d/%Y"), as.Date(clinical_updates$"Date.of.diabetes.diagnosis", format="%m/%d/%Y"), units="days"))

#keep Record.ID..XX.XXX.XX.. 
clinic_addition <- clinical_updates %>%   
select("Record.ID..XX.XXX.XX.", cor_insulin,imputed_C_pep, duration_diabetes)  %>% rename(IID = "Record.ID..XX.XXX.XX.") 


#clinical_updates[1:5,c("Visit.Date", "Date.of.diabetes.diagnosis", "duration_diabetes")]
#summary(clinic_addition$duration_diabetes)

#save clinic_addition
write.csv(clinic_addition, 'C:/Per/LaiJiang/Project/ADDAM/HP/results/2_4_C_pep.csv', row.names=F, quote=F)