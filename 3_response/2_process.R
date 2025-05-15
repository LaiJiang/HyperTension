#after 1_create_elevated_bp_group.py 
#we manually added the online-calcuated percentiels and manually calucated the elevated BP group add that to the data 
#and then we save the data as HP/dat/BP_group_results.csv

#inthis file we sanity check on the data, and consolidate the results 

library(dplyr)
PATH_wk <-   "C:/Per/LaiJiang/Project/ADDAM/"

#load the data
BP_group_results <- read.csv(paste0(PATH_wk, "HP/dat/BP_group_results.csv"), header=T)

colnames(BP_group_results)

#remove columns that start with "X"
BP_group_results <- BP_group_results[, !grepl("^X", colnames(BP_group_results))]

#rename Record... with IID
BP_group_results <- BP_group_results %>% rename(IID = "Record.ID..XX.XXX.XX.")
BP_group_results <- BP_group_results %>% rename(DOB = "Subject.s.Date.of.Birth")
BP_group_results <- BP_group_results %>% rename(comments = "BP.Percentiles")

#how many rows have comments contain character "not pediatric"
BP_group_results %>% filter(grepl("not pediateric", comments)) %>% nrow()
#remove these rows
BP_group_results <- BP_group_results %>% filter(!grepl("not pediateric", comments))


table(BP_group_results$elevated_bp_group,BP_group_results$Calculator)


#show the row where elevated_bp_group  = No, and Calculator = 1
BP_group_results %>% filter(elevated_bp_group == "No" & Calculator == 1)
BP_group_results %>% filter(elevated_bp_group == "Yes" & Calculator == 0)

#add a column: Y_elevated, as 1 if elevated_bp_group = "Yes" AND Calculator =1. Or else assign 0
BP_group_results <- BP_group_results %>% mutate(Y_elevated = ifelse(elevated_bp_group == "Yes" & Calculator == 1, 1, 0))


#select columns to keep: IID, DOB, days_from_DOB_to_BP1,Y_elevated
BP_group_results <- BP_group_results %>% select(IID, DOB, days_from_DOB_to_BP1, Y_elevated)


#remove rows with NA or missing values in any columns
BP_group_results <- BP_group_results %>% filter(!is.na(IID) & !is.na(DOB) & !is.na(days_from_DOB_to_BP1) & !is.na(Y_elevated))


#write data to csv file
write.csv(BP_group_results, paste0(PATH_wk, "HP/dat/BP_2_process.csv"), row.names=F, quote=F)
