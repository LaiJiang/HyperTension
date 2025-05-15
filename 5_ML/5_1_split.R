#preprocess, split into training and test

# Load required libraries
library(dplyr)
library(caret)
library(pROC)
library(ggplot2)


library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"


HP_dat <- read.csv(paste0(PATH_wk, "HP/results/4_1_process.csv"))


#remove the first column IID
HP_dat <- HP_dat[,-1]



#step1: remove highly correlated features 
#remove features with correlation > 0.8
correlation_matrix <- cor(HP_dat)
highly_correlated <- findCorrelation(correlation_matrix, cutoff = 0.95)

HP_dat <- HP_dat[, -highly_correlated]

write.csv(HP_dat, file = paste0(PATH_wk, "HP/results/5_1_split_before.csv"))


HP_dat$age_BP <- HP_dat$age_BP/365.25 #convert to years
HP_dat$age_atb <- HP_dat$age_atb/365.25 #convert to years

#the number of unique values in each column
unique_values <- sapply(HP_dat, function(x) length(unique(x)))


#split into 75% training and 25% test set
set.seed(123) # for reproducibility
train_index <- createDataPartition(HP_dat$Y, p = 0.75, list = FALSE)
train_data <- HP_dat[train_index, ]
test_data <- HP_dat[-train_index, ]


#save the training and test data
save(train_data, test_data,  file=paste0(PATH_wk, "HP/results/5_1_split.RData")  )

par(mfrow=c(2,1))
plot(train_data$age_BP,col=ifelse(train_data$Y == 1, "red", "blue"),
     pch=19, cex=0.5, xlab="Age", ylab="Predicted Probability")

plot(test_data$age_BP,col=ifelse(test_data$Y == 1, "red", "blue"),
     pch=19, cex=0.5, xlab="Age", ylab="Predicted Probability")
    