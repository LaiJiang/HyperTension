

library(dplyr)
library(caret)
library(pROC)
library(PRROC)
library(randomForest)

# 2. Load train/test split
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
load(paste0(PATH_wk, "HP/results/7_1_split.RData"),verbose=TRUE)  #

HP_dat$Y <- factor(HP_dat$Y, levels = c(0, 1), labels = c("No", "Yes"))



ctrl_loocv <- trainControl(
  method = "LOOCV",
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

rf_loocv <- caret::train(
  Y ~ ., data = HP_dat,
  method = "rf",
  trControl = ctrl_loocv,
  metric = "ROC",
  preProcess = c("scale")
)

print(rf_loocv)


save(rf_loocv, file = paste0(PATH_wk, "HP/results/7_6_CV.RData"))


# Extract predicted probabilities for the positive class ("Yes")
pred_probs <- rf_loocv$pred

# Filter to only keep the rows corresponding to the selected tuning parameter (mtry = 18)
pred_probs <- pred_probs[pred_probs$mtry == rf_loocv$bestTune$mtry, ]

# Now get subject-level predicted probabilities and true labels
head(pred_probs[, c("obs", "Yes", "pred")])



library(pROC)

# ROC curve
roc_obj <- roc(pred_probs$obs, pred_probs$Yes, levels = c("No", "Yes"))

# Compute bootstrap-based confidence intervals for the ROC curve
ci_roc <- ci.se(roc_obj, specificities = seq(0, 1, 0.01), boot.n = 200)


# Convert to data frame for ggplot
roc_df <- data.frame(
  specificity = as.numeric(rownames(ci_roc)),
  sensitivity = ci_roc[, "50%"],
  lower = ci_roc[, "2.5%"],
  upper = ci_roc[, "97.5%"]
)

# Convert to 1 - specificity for x-axis
roc_df <- roc_df %>%
  mutate(fpr = 1 - specificity)

# Plot with ggplot
ggplot_cv<- 
ggplot(roc_df, aes(x = fpr, y = sensitivity)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "steelblue", alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +  # diagonal line
  labs(
    title = sprintf("ROC Curve with 95%% CI Band (AUC = %.3f)", auc(roc_obj)),
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)"
  ) +
  theme_minimal(base_size = 14)


# Save plot to JPEG
ggsave(paste0(PATH_wk,"HP/6_report/7_6_CV.jpeg"), plot = ggplot_cv, width = 6, height = 5, dpi = 300)


#plot predicted probabilities to be elevated
library(ggplot2)

pred_probs$ID <- seq_len(nrow(pred_probs))

# Plot
scatter_probs <- ggplot(pred_probs, aes(x = ID, y = Yes, color = obs)) +
  geom_point(size = 2) +
  labs(
    title = "Predicted Probabilities by Observed Class",
    x = "Subject Index",
    y = "Predicted Probability (Class = Yes)",
    color = "Observed Class"
  ) +
  scale_color_manual(values = c("No" = "blue", "Yes" = "red")) +
  theme_minimal(base_size = 14)

ggsave(paste0(PATH_wk,"HP/6_report/7_6_CV_probs.jpeg"), plot = scatter_probs, width = 6, height = 5, dpi = 300)
