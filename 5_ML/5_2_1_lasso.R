# 5_4_lasso_glmnet.R
# Fit a LASSO‐penalized logistic model, select features, and evaluate ROC & PR curves

# 0) Install / load required packages
if (!requireNamespace("glmnet", quietly=TRUE))  install.packages("glmnet")
if (!requireNamespace("pROC",   quietly=TRUE))  install.packages("pROC")
if (!requireNamespace("PRROC",  quietly=TRUE))  install.packages("PRROC")
if (!requireNamespace("dplyr",  quietly=TRUE))  install.packages("dplyr")

library(glmnet)
library(pROC)
library(PRROC)
library(dplyr)

# 1) Load  train/test split
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
load(file.path(PATH_wk, "HP/results/5_1_split.RData"))  # 

# 2) Ensure Y is numeric 0/1
#    If factor("No"/"Yes"), convert it back:
if (is.factor(train_data$Y)) {
  train_data <- train_data %>%
    mutate(Y = ifelse(Y == "Yes", 1L, 0L))
  test_data <- test_data %>%
    mutate(Y = ifelse(Y == "Yes", 1L, 0L))
}

# 3) Build model matrices 
x_train <- model.matrix(Y ~ ., train_data)[, -1]  # drop intercept column
y_train <- train_data$Y

x_test  <- model.matrix(Y ~ ., test_data)[, -1]
y_test  <- test_data$Y

# 4) Cross‐validated LASSO (alpha=1), optimizing AUC
set.seed(123)
cvfit <- cv.glmnet(
  x         = x_train,
  y         = y_train,
  family    = "binomial",
  alpha     = 1,
  type.measure = "auc",
  nfolds    = 5
)

# Plot the cross‐validation curve
plot(cvfit)
abline(v = log(cvfit$lambda.min), col = "red", lty = 2)

# 5) Extract non‐zero coefficients at lambda.min
lambda_min <- cvfit$lambda.min
coefs <- coef(cvfit, s = lambda_min)
nz_idx <- which(coefs != 0)
selected <- data.frame(
  feature     = rownames(coefs)[nz_idx],
  coefficient = as.numeric(coefs[nz_idx])
)
message("Features selected by LASSO (nonzero @ lambda.min):")
print(selected)

# 6) Predict probabilities on the test set
prob_test <- predict(cvfit, newx = x_test, s = lambda_min, type = "response")
prob_test <- as.numeric(prob_test)  # convert matrix to vector

# 7) ROC curve & AUC
roc_obj <- roc(y_test, prob_test)
auc_roc <- auc(roc_obj)
cat("LASSO ROC AUC:", round(auc_roc, 3), "\n")
plot(roc_obj, main = sprintf("LASSO ROC Curve (AUC = %.3f)", auc_roc))

# 8) Precision–Recall curve & AUC
fg <- prob_test[y_test == 1]
bg <- prob_test[y_test == 0]
pr_obj <- pr.curve(
  scores.class0 = fg,
  scores.class1 = bg,
  curve = TRUE
)
cat("LASSO PR  AUC:", round(pr_obj$auc.integral, 3), "\n")
plot(pr_obj, main = sprintf("LASSO Precision–Recall (AUC = %.3f)", pr_obj$auc.integral))

# 9) Save fitted model and selected features
save(cvfit, selected,
     file = file.path(PATH_wk, "HP/results/5_2_1_lasso.RData"))
