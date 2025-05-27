
library(caret)
library(randomForest)

set.seed(123)
B <- 200  # Number of bootstrap replicates
imp_list <- list()

for (i in 1:B) {
    print(paste0("Bootstrap iteration: ", i))
  # Bootstrap sample
  boot_idx <- sample(1:nrow(HP_dat), replace = TRUE)
  boot_data <- HP_dat[boot_idx, ]
  
  # Fit model
  rf <- caret::train(
    Y ~ ., data = boot_data,
    method = "rf",
    trControl = trainControl(method = "none", classProbs = TRUE, summaryFunction = twoClassSummary),
    metric = "ROC",
    preProcess = "scale"
  )
  
  # Save variable importances
  imp <- varImp(rf, scale = FALSE)$importance
  imp_list[[i]] <- imp
}

# Combine to one data.frame
imp_mat <- do.call(cbind, lapply(imp_list, function(x) x$Overall))
rownames(imp_mat) <- rownames(imp_list[[1]])

# Compute CI for each feature
imp_ci <- t(apply(imp_mat, 1, function(x) quantile(x, c(0.025, 0.5, 0.975))))
colnames(imp_ci) <- c("CI_2.5", "Median", "CI_97.5")

# Show top features with intervals
imp_ci[order(-imp_ci[, "Median"]), ][1:10, ]

library(ggplot2)

# Convert to a data frame for ggplot
imp_df <- as.data.frame(imp_ci)
imp_df$Feature <- rownames(imp_ci)

# Order by median importance
imp_df <- imp_df[order(imp_df$Median), ]
imp_df$Feature <- factor(imp_df$Feature, levels = imp_df$Feature)  # preserve order in plot

# Plot
plot_imp <- ggplot(imp_df, aes(x = Median, y = Feature)) +
  geom_point(color = "steelblue", size = 3) +
  geom_errorbarh(aes(xmin = CI_2.5, xmax = CI_97.5), height = 0.3, color = "gray40") +
  labs(
    title = "Random Forest Feature Importance with 95% Bootstrap CI",
    x = "Importance (Median with 95% CI)",
    y = "Feature"
  ) +
  theme_minimal(base_size = 14)


ggsave(paste0(PATH_wk,"HP/6_report/7_7_boots.jpeg"), plot = plot_imp, width = 6, height = 5, dpi = 300)

save(imp_ci, imp_ci, file = paste0(PATH_wk, "HP/results/7_7_boots.RData"))