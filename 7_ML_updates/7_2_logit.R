#try logistic regression on the data as benchmark 

#load data
library(dplyr)
library(caret)
library(pROC)
library(ggplot2)
library(PRROC)


library(dplyr)
PATH_wk <-  "C:/Per/LaiJiang/Project/ADDAM/"

load(paste0(PATH_wk, "HP/results/7_1_split.RData"),verbose=TRUE)




# 1. Identify continuous predictors (all numeric except the binary Y)
cont_feats <- names(train_data)[
  sapply(train_data, is.numeric) & names(train_data) != "Y"
]

# 2. Fit a preprocessing model on the training set
pre_proc <- preProcess(
  train_data[, cont_feats],
  method = c("center", "scale")
)

# 3. Apply the same scaling to train and test
train_scaled <- train_data
train_scaled[, cont_feats] <- predict(pre_proc, train_data[, cont_feats])

test_scaled <- test_data
test_scaled[, cont_feats]  <- predict(pre_proc, test_data[,  cont_feats])

# 4. Build formula using all predictors
features <- setdiff(names(train_scaled), "Y")
f <- as.formula(paste("Y ~", paste(features, collapse = " + ")))

# 5. Fit logistic regression on the scaled training data
log_mod <- glm(f, data = train_scaled, family = binomial)

# 6. Predict probabilities on the scaled test set
test_scaled <- test_scaled %>%
  mutate(pred_prob = predict(log_mod, newdata = ., type = "response"))

# 7. ROC curve & AUC (via pROC)
roc_obj <- roc(test_scaled$Y, test_scaled$pred_prob)
auc_roc <- auc(roc_obj)
cat("ROC AUC:", round(auc_roc, 3), "\n")
plot(roc_obj, main = sprintf("ROC Curve (AUC = %.3f)", auc_roc))

# 8. Precision–Recall curve & AUC (via PRROC)
fg <- test_scaled$pred_prob[test_scaled$Y == 1]
bg <- test_scaled$pred_prob[test_scaled$Y == 0]
pr_obj <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = TRUE)
auc_pr <- pr_obj$auc.integral
cat("PR  AUC:", round(auc_pr, 3), "\n")
plot(pr_obj, main = sprintf("Precision–Recall Curve (AUC = %.3f)", auc_pr))


#what features are important in the logistic regression model?
summary(log_mod)
#print the significant features
log_mod_summary <- summary(log_mod)
log_mod_summary$coefficients[log_mod_summary$coefficients[, 4] < 0.05, ]



#conclusion: only two features are significant: Cluster_age and cluster_family_12_degree_bin


#save the model
save(log_mod, test_scaled, file = paste0(PATH_wk, "HP/results/7_2_logit.RData"))

