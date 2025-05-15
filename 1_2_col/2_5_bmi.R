#this script adds the BMI percentile and z-scores according to the CDC growth charts

#install packages for calculation 
install.packages( 'https://raw.github.com/CDC-DNPAO/CDCAnthro/master/cdcanthro_0.1.3.tar.gz', type='source', repos=NULL )


#first load the data of age, weight, heigh, bmi

#age: age in months specified as accurately as possible. If age is given as the completed number of months (as in NHANES), add 0.5. If age is given in days, divide by 30.4375.

#wt: weight (kg).

#ht: height (cm).

#bmi: BMI, kg/m^2.
library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"
clinical_dat <- read.csv( paste0(PATH_wk, "HP/results/4_1_process.csv"))

X_clustering <- read.csv(paste0(PATH_wk, "dat/cluster_clinical.csv"))

#take accurate age in days
cdc_dat1 <- clinical_dat %>%
  select(X, age_BP,Cluster_sex_bin)  %>% rename(IID = X) 


#take other covariates
cdc_dat2 <- X_clustering %>%
  select(Cluster_subjectID,Cluster_height,Cluster_weight) %>% rename(IID = Cluster_subjectID) 

#combine the two dataframes
cdc_dat <- cdc_dat1 %>%
  left_join(cdc_dat2, by = "IID") %>%
  mutate(age_months = age_BP/30.4375) %>%
  select(IID, age_months, Cluster_height, Cluster_weight,Cluster_sex_bin) %>%
  #add BMI as a new column
    mutate(bmi = (Cluster_weight / (Cluster_height/100)^2)) %>% rename(sex = Cluster_sex_bin) %>%
     mutate(
    SEX = ifelse(sex == 0, "female", "male"),
    SEX = factor(SEX, levels = c("female", "male"))
  ) %>%     select(-sex) 

#cdc Rpackage

library(cdcanthro)
cdc_bmi <-cdcanthro(cdc_dat, age = age_months, wt = Cluster_weight, ht = Cluster_height, bmi = bmi, all = FALSE)


table(clinical_dat$Cluster_sex)

cdc_bmi <- cdc_bmi %>% select(IID,bmi, bmiz, bmip)

#bmip and bmiz: CDC BMI percentile and z-score.
# These are based on the LMS method for children without obesity and the 'extended' method for children with obesity. See Wei et al. (2020)

#write to csv file
write.csv(cdc_bmi, paste0(PATH_wk, "HP/results/2_5_bmi.csv"), row.names=F, quote=F)