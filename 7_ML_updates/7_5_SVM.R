# 5_5_svm_linear.R
# Train & evaluate a linear‐kernel SVM using caret, with ROC & PRC

# 0) Install / load required packages
if (!requireNamespace("caret",  quietly=TRUE)) install.packages("caret")
if (!requireNamespace("kernlab", quietly=TRUE)) install.packages("kernlab")
if (!requireNamespace("pROC",    quietly=TRUE)) install.packages("pROC")
if (!requireNamespace("PRROC",   quietly=TRUE)) install.packages("PRROC")
if (!requireNamespace("dplyr",   quietly=TRUE)) install.packages("dplyr")

library(dplyr)
library(kernlab)   # for the svmLinear method
library(pROC)
library(PRROC)

# 1) Load train/test split
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
load(file.path(PATH_wk, "HP/results/7_1_split.RData"))  

# 2)  Y is a factor with levels "No","Yes"
train_data <- train_data %>%
  mutate(Y = factor(Y, levels = c(0,1), labels = c("No","Yes")))
test_data  <- test_data  %>%
  mutate(Y = factor(Y, levels = c(0,1), labels = c("No","Yes")))

# 3)  training control (5‑fold CV, repeated 3×, optimize ROC)
ctrl <- caret::trainControl(
  method          = "repeatedcv",
  number          = 5,
  repeats         = 3,
  classProbs      = TRUE,
  summaryFunction = caret::twoClassSummary,
  savePredictions = "final",
  verboseIter     = TRUE
)

# 4) Train the linear SVM 
set.seed(123)
svm_mod <- caret::train(
  Y ~ .,
  data      = train_data,
  method    = "svmLinear",
  metric    = "ROC",
  trControl = ctrl,
  tuneLength = 5    # will try 5 values of cost C
)

print(svm_mod)
#plot(svm_mod)

# 5) Predict on test set
test_data <- test_data %>%
  mutate(
    pred_prob  = predict(svm_mod, newdata = ., type = "prob")[, "Yes"],
    pred_class = predict(svm_mod, newdata = .)
  )

# 6) ROC & AUC
roc_svm <- pROC::roc(test_data$Y, test_data$pred_prob, levels = c("No","Yes"))
auc_svm <- pROC::auc(roc_svm)
cat("SVM ROC AUC:", round(auc_svm, 3), "\n")
plot(roc_svm, main = sprintf("SVM ROC Curve (AUC = %.3f)", auc_svm))

# 7) Precision–Recall & AUC
fg_svm <- test_data$pred_prob[test_data$Y == "Yes"]
bg_svm <- test_data$pred_prob[test_data$Y == "No"]
pr_svm <- PRROC::pr.curve(scores.class0 = fg_svm, scores.class1 = bg_svm, curve = TRUE)
cat("SVM PR  AUC:", round(pr_svm$auc.integral, 3), "\n")
plot(pr_svm, main = sprintf("SVM Precision–Recall (AUC = %.3f)", pr_svm$auc.integral))

# 8) Variable importance
imp_svm <- caret::varImp(svm_mod, scale = FALSE)
print(imp_svm)
plot(imp_svm, top = 20, main = "SVM Variable Importance")

save(svm_mod, test_data,
     file = file.path(PATH_wk, "HP/results/7_5_svm_linear.RData"))
