#working path
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"


#first load the GRS score of first batch 

GRS_batch1 <- read.table(paste0(PATH_wk, "HP/dat/ADDAM.score.profile"),header=T)

#remove the first 2 characters in IID
GRS_batch1$IID <- substr(GRS_batch1$IID, 3, nchar(GRS_batch1$IID))

GRS_batch1$FID <- substr(GRS_batch1$FID, 3, nchar(GRS_batch1$FID))

#load second batch

GRS_batch2 <- read.table(paste0(PATH_wk, "HP/dat/ADDAMB2.score.profile"),header=T)


#standardize the GRS score of the first batch
GRS_batch1$GRS <- (GRS_batch1$SCORESUM - mean(GRS_batch1$SCORESUM)) / sd(GRS_batch1$SCORESUM)

#standardize the GRS score of the second batch
GRS_batch2$GRS <- (GRS_batch2$SCORESUM - mean(GRS_batch2$SCORESUM)) / sd(GRS_batch2$SCORESUM)


#rbind the two batches
GRS <- rbind(GRS_batch1, GRS_batch2)

#save the file 
write.table(GRS, paste0(PATH_wk, "HP/results/1_GRS.txt"), row.names=F, col.names=T, quote=F)