
library(dplyr)
library(caret)
library(pROC)
library(PRROC)
library(randomForest)

# 2. Load train/test split
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
load(paste0(PATH_wk, "HP/results/7_1_split.RData"),verbose=TRUE)  #

# 3. Convert Y to factor for classification
train_data <- train_data %>%
  mutate(Y = factor(Y, levels = c(0,1), labels = c("No","Yes")))
test_data  <- test_data  %>%
  mutate(Y = factor(Y, levels = c(0,1), labels = c("No","Yes")))

# 4. Set up caret training control to compute ROC during CV
ctrl <- trainControl(
  method            = "repeatedcv",
  number            = 5,
  repeats           = 3,
  classProbs        = TRUE,
  summaryFunction   = twoClassSummary,
  savePredictions   = "final",
  verboseIter       = TRUE
)

# 5. Train the Random Forest
set.seed(123)
rf_mod <- caret::train(
  Y ~ .,
  data   = train_data,
  method = "rf",
  metric = "ROC",
  trControl = ctrl,
  tuneLength = 5 ,  # try 5 different mtry values,
  preProcess = c("scale")
)

print(rf_mod)
# Optional: plot tuning curve
plot(rf_mod)

# 6. Predict on test set
test_data <- test_data %>%
  mutate(
    pred_prob = predict(rf_mod, newdata = ., type = "prob")[, "Yes"],
    pred_class = predict(rf_mod, newdata = .)
  )

# 7. ROC & AUC
roc_rf <- roc(test_data$Y, test_data$pred_prob, levels = c("No","Yes"))
auc_rf <- auc(roc_rf)
cat("RF ROC AUC:", round(auc_rf,3), "\n")
plot(roc_rf, main = sprintf("RF ROC Curve (AUC = %.3f)", auc_rf))

# 8. PR curve & AUC
fg_rf <- test_data$pred_prob[test_data$Y == "Yes"]
bg_rf <- test_data$pred_prob[test_data$Y == "No"]
pr_rf <- pr.curve(scores.class0 = fg_rf, scores.class1 = bg_rf, curve = TRUE)
cat("RF PR  AUC:", round(pr_rf$auc.integral,3), "\n")
plot(pr_rf, main = sprintf("RF Precision–Recall (AUC = %.3f)", pr_rf$auc.integral))

# 9. Variable importance
imp <- varImp(rf_mod, scale=FALSE)
print(imp)
plot(imp, main="RF Variable Importance")

# 10. Save model and scaled data

#scale the predicted probabilities 
test_data$pred_prob <- sqrt(test_data$pred_prob )
#plot the age and predicted prbabilities, colored by  the actual Y
plot(test_data$bmiz, test_data$pred_prob, col = ifelse(test_data$Y == "Yes", "red", "blue"), pch = 19,
     xlab = "Age at BP measurement", ylab = "Predicted Probabilities",cex=2)

orig_imp_df <- imp

save(rf_mod, test_data, orig_imp_df, file = paste0(PATH_wk, "HP/results/7_3_random_forest.RData"))

########
#experimental: tried PCA before ML, but not useful
if(FALSE){
# 1) pull out  PCA preProcess object
pp <- rf_mod$preProcess

# the loadings matrix
loadings <- pp$rotation  

# 2) extract the PC importances
pc_imp <- imp$importance$Overall

# 3) compute a weighted sum of absolute loadings
#    for feature i: sum_k |loading[i,k]| * pc_imp[k]
orig_imp <- rowSums( abs(loadings) * matrix(pc_imp, 
                                            nrow = nrow(loadings), 
                                            ncol = ncol(loadings), 
                                            byrow = TRUE) )

# 4) assemble into a data.frame and sort
orig_imp_df <- data.frame(
  feature    = rownames(loadings),
  importance = orig_imp
)
orig_imp_df <- orig_imp_df[order(-orig_imp_df$importance), ]

print(orig_imp_df)
save(rf_mod, test_data, orig_imp_df, file = paste0(PATH_wk, "HP/results/7_3_random_forest.RData"))

}