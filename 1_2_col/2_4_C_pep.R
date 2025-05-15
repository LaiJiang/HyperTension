
#add add "imputed C-peptide" as a clinical feature and see if this is associated with the 2 identified clusters;  imputed C-peptide is calculated using the following formula:

#A1c+(Ins)x 4, where Ins is the insulin dose in units/kg/day



clinical_updates = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/ADDAM_clustering_MCh_participants_Nov13.csv')
#clinical_ori = read.csv('C:/Per/LaiJiang/Project/ADDAM/dat/participants.csv')


plot(clinical_updates[,c(26)]/1000,clinical_updates[,c(27)],xlab="Insulin dose (units/kg/day)",ylab="C-peptide (nmol/L)")


##stopped here!!!