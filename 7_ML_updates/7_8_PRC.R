library(PRROC)
library(ggplot2)



load( file = paste0(PATH_wk, "HP/results/7_6_CV.RData"),verbose=TRUE)


# Extract predicted probabilities for the positive class ("Yes")
pred_probs <- rf_loocv$pred

# Filter to only keep the rows corresponding to the selected tuning parameter (mtry = 18)
pred_probs <- pred_probs[pred_probs$mtry == rf_loocv$bestTune$mtry, ]

# Now get subject-level predicted probabilities and true labels
head(pred_probs[, c("obs", "Yes", "pred")])



library(pROC)



# Extract scores for positive and negative classes
fg <- pred_probs$Yes[pred_probs$obs == "Yes"]  # predicted probs for true positives
bg <- pred_probs$Yes[pred_probs$obs == "No"]   # predicted probs for true negatives

# Compute PR curve
pr_obj <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = TRUE)

# Convert to data frame for ggplot
pr_df <- data.frame(
  Recall = pr_obj$curve[, 1],
  Precision = pr_obj$curve[, 2]
)

# Plot PR curve
ggplot_pr <- ggplot(pr_df, aes(x = Recall, y = Precision)) +
  geom_line(color = "darkorange", size = 1.2) +
  labs(
    title = sprintf("Precision–Recall Curve (AUC = %.3f)", pr_obj$auc.integral),
    x = "Recall",
    y = "Precision"
  ) +
  theme_minimal(base_size = 14)

# Save PRC to JPEG
ggsave(paste0(PATH_wk, "HP/6_report/7_8_PRC.jpeg"), plot = ggplot_pr, width = 6, height = 5, dpi = 300)



# Step 1: Set recall grid and prepare bootstrap holder
recall_grid <- seq(0.01, 1, by = 0.01)
B <- 200  # number of bootstrap samples
pr_mat <- matrix(NA, nrow = B, ncol = length(recall_grid))

for (i in 1:B) {
  # Bootstrap sample
  boot_idx <- sample(1:nrow(pred_probs), replace = TRUE)
  boot_data <- pred_probs[boot_idx, ]
  
  fg <- boot_data$Yes[boot_data$obs == "Yes"]
  bg <- boot_data$Yes[boot_data$obs == "No"]
  
  if (length(fg) > 1 && length(bg) > 1) {
    pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = TRUE)
    
    interp_pr <- approx(x = pr$curve[, 1], y = pr$curve[, 2], xout = recall_grid, rule = 2)$y
    pr_mat[i, ] <- interp_pr
  }
}

# Step 2: Compute point estimate (original PR curve)
fg <- pred_probs$Yes[pred_probs$obs == "Yes"]
bg <- pred_probs$Yes[pred_probs$obs == "No"]
pr_base <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = TRUE)
base_interp <- approx(x = pr_base$curve[, 1], y = pr_base$curve[, 2], xout = recall_grid, rule = 2)$y

# Step 3: Compute confidence intervals at each recall level
pr_df <- data.frame(
  Recall = recall_grid,
  Precision = base_interp,
  CI_lower = apply(pr_mat, 2, quantile, probs = 0.025, na.rm = TRUE),
  CI_upper = apply(pr_mat, 2, quantile, probs = 0.975, na.rm = TRUE)
)

# Step 4: Plot with ggplot2
PR_band <- ggplot(pr_df, aes(x = Recall, y = Precision)) +
  geom_line(color = "darkorange", size = 1.2) +
  geom_ribbon(aes(ymin = CI_lower, ymax = CI_upper), fill = "orange", alpha = 0.3) +
  labs(
    title = "Precision–Recall Curve with 95% CI Band",
    x = "Recall",
    y = "Precision"
  ) +
  theme_minimal(base_size = 14)


  ggsave(paste0(PATH_wk, "HP/6_report/7_8_PRC_band.jpeg"), plot = PR_band, width = 6, height = 5, dpi = 300)
