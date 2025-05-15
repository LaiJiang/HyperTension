#after 1_create_elevated_bp_group.py 
#we manually added the online-calcuated percentiels and manually calucated the elevated BP group add that to the data 
#and then we save the data as HP/dat/BP_group_results.csv

#inthis file we sanity check on the data, and consolidate the results 

library(dplyr)
PATH_wk <-   "C:/Per/LaiJiang/Project/ADDAM/"

#load the data
#BP_group_results <- read.csv(paste0(PATH_wk, "HP/3_response/3_updates.csv"), header=T)
BP_group_results <- read.csv(paste0(PATH_wk, "HP/3_response/3_2_updates.csv"), header=T)

colnames(BP_group_results)

#remove columns that start with "X"
#BP_group_results <- BP_group_results[, !grepl("^X", colnames(BP_group_results))]

#rename Record... with IID
BP_group_results <- BP_group_results %>% rename(IID = "Record.ID..XX.XXX.XX.")
BP_group_results <- BP_group_results %>% rename(DOB = "Subject.s.Date.of.Birth")
#BP_group_results <- BP_group_results %>% rename(comments = "BP.Percentiles")
BP_group_results <- BP_group_results %>% rename(comments = "not_pediatric")

#how many rows have comments contain character "not pediatric"
#BP_group_results %>% filter(grepl("not pediateric", comments)) %>% nrow()
table(BP_group_results$elevated_bp_group,BP_group_results$comments)
#remove these rows
#BP_group_results <- BP_group_results %>% filter(!grepl("not pediateric", comments))


#filter comment  = 1 or not? !!!!!!!!!!!!!!!!!!
#BP_group_results <- BP_group_results %>% filter(comments == 0)


#select columns to keep: IID, DOB, days_from_DOB_to_BP1,Y_elevated
BP_group_results <- BP_group_results %>% select(IID, DOB, elevated_bp_group)
BP_group_results <- BP_group_results %>% rename(Y_elevated = elevated_bp_group)

###
#collect days_from_DOB_to_BP1 from the old file
BP_group_results_old <- read.csv(paste0(PATH_wk, "HP/dat/BP_group_results.csv"), header=T)

BP_group_results_old <- BP_group_results_old %>% select("Record.ID..XX.XXX.XX.", days_from_DOB_to_BP1)
BP_group_results_old <- BP_group_results_old %>% rename(IID = "Record.ID..XX.XXX.XX.")

#attach 
BP_group_results$days_from_DOB_to_BP1 <- BP_group_results_old$days_from_DOB_to_BP1[match(BP_group_results$IID, BP_group_results_old$IID)]


###
#remove rows with NA or missing values in any columns
BP_group_results <- BP_group_results %>% filter(!is.na(IID) & !is.na(DOB) & !is.na(days_from_DOB_to_BP1) & !is.na(Y_elevated))


BP_group_results$Y_elevated <- ifelse(BP_group_results$Y_elevated == "Yes", 1, 0)



#write data to csv file
write.csv(BP_group_results, paste0(PATH_wk, "HP/dat/BP_2_process.csv"), row.names=F, quote=F)
