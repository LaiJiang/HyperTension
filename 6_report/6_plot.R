# plot_all_curves.R
# Overlay ROC and PR curves for Logistic, LASSO, and Random Forest

# 0) Install / load required packages
if (!requireNamespace("pROC", quietly=TRUE))  install.packages("pROC")
if (!requireNamespace("PRROC", quietly=TRUE)) install.packages("PRROC")
if (!requireNamespace("glmnet", quietly=TRUE)) install.packages("glmnet")
library(pROC)
library(PRROC)
library(glmnet)

# 1) Paths
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
ROC_file <- paste0(PATH_wk, "HP/6_report/roc_all.jpeg")
PR_file  <- paste0(PATH_wk, "HP/6_report/pr_all.jpeg")

# 2) Load Logistic results
load(paste0(PATH_wk, "HP/results/5_2_logit.RData"))   # loads log_mod, test_scaled
logit_test <- test_scaled                              

# 3) Load Random Forest results
load(paste0(PATH_wk, "HP/results/5_3_random_forest.RData"))  # loads rf_mod, test_data
rf_test <- test_data                                          

# 4) Load LASSO results and reconstruct test predictions
load(paste0(PATH_wk, "HP/results/5_1_split.RData"))     # train_data, test_data (numeric Y)
load(paste0(PATH_wk, "HP/results/5_2_1_lasso.RData"))   # loads cvfit
# build model matrix for LASSO
x_test  <- model.matrix(Y ~ ., test_data)[, -1]
y_test  <- test_data$Y
prob_lasso <- as.numeric(
  predict(cvfit, newx = x_test, s = cvfit$lambda.min, type = "response")
)

# 5) Compute ROC objects
roc_logit <- roc(logit_test$Y, logit_test$pred_prob)
truth_rf  <- ifelse(rf_test$Y == "Yes", 1, 0)
roc_rf    <- roc(truth_rf, rf_test$pred_prob)
roc_lasso <- roc(y_test, prob_lasso)

# 6) Plot all ROC on one JPEG

jpeg(filename = ROC_file, width = 800, height = 600)
plot(roc_logit, col = "blue",  lwd = 2, main = "ROC Curves: Logit / LASSO / RF")
plot(roc_lasso, add = TRUE, col = "green", lwd = 2)
plot(roc_rf,    add = TRUE, col = "red",   lwd = 2)
legend("bottomright",
       legend = c(
         sprintf("Logit (AUC=%.3f)", auc(roc_logit)),
         sprintf("LASSO (AUC=%.3f)", auc(roc_lasso)),
         sprintf("RF    (AUC=%.3f)", auc(roc_rf))
       ),
       col = c("blue","green","red"),
       lwd = 2)
dev.off()

# 7) Compute Precision–Recall curves
pr_logit <- pr.curve(
  scores.class0 = logit_test$pred_prob[logit_test$Y == 1],
  scores.class1 = logit_test$pred_prob[logit_test$Y == 0],
  curve = TRUE
)
pr_rf <- pr.curve(
  scores.class0 = rf_test$pred_prob[truth_rf == 1],
  scores.class1 = rf_test$pred_prob[truth_rf == 0],
  curve = TRUE
)
pr_lasso <- pr.curve(
  scores.class0 = prob_lasso[y_test == 1],
  scores.class1 = prob_lasso[y_test == 0],
  curve = TRUE
)

# 8) Plot all PR on one JPEG with y-axis from 0 to 1
jpeg(filename = PR_file, width = 800, height = 600)
plot(pr_logit$curve[,1], pr_logit$curve[,2],
     type = "l", col = "blue", lwd = 2,
     xlab = "Recall", ylab = "Precision",
     main = "Precision–Recall Curves",
     ylim = c(0, 1))
lines(pr_lasso$curve[,1], pr_lasso$curve[,2], col = "green", lwd = 2)
lines(pr_rf$curve[,1],    pr_rf$curve[,2],    col = "red",   lwd = 2)
legend("bottomleft",
       legend = c(
         sprintf("Logit (AUC=%.3f)", pr_logit$auc.integral),
         sprintf("LASSO (AUC=%.3f)", pr_lasso$auc.integral),
         sprintf("RF    (AUC=%.3f)", pr_rf$auc.integral)
       ),
       col = c("blue","green","red"),
       lwd = 2)
dev.off()



#plot the age and predicted prbabilities

# plot_rf_age_prob.R
# Plot Age vs. Predicted Probability from the Random Forest on the test set

# 0) Load required library
library(dplyr)

# 1)  paths
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
RF_RESULTS <- paste0(PATH_wk, "HP/results/5_3_random_forest.RData")
OUT_PLOT   <- paste0(PATH_wk, "HP/6_report/rf_age_predprob.jpeg")

# 2) Load the Random Forest results (loads `rf_mod` and `test_data`)
load(RF_RESULTS)

#test_data$pred_prob <- sqrt(test_data$pred_prob) # scale the predicted probabilities
# build the ggplot object
p <- ggplot(test_data, aes(x = age_BP, y = pred_prob, color = Y)) +
  geom_point(size = 3, alpha = 0.8) +
  scale_color_manual(
    values = c("Yes" = "red", "No" = "blue"),
    name   = "BP elevated group"
  ) +
  labs(
    x = "Age at BP measurement",
    y = "Predicted Probabilities",
    title = "Predicted Probability for elevated BP vs. Age",
    subtitle = "Colored by actual BP elevated group"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    legend.position = "top",
    plot.title      = element_text(face = "bold", size = 18),
    plot.subtitle   = element_text(size = 13)
  )

# display it
print(p)

# save it to JPEG
ggsave(
  filename = OUT_PLOT,
  plot     = p,
  width    = 8,    # inches
  height   = 6,    # inches
  dpi      = 300
)


dev.off()

cat("Saved plot to:", OUT_PLOT, "\n")



# 9. Variable importance

# 2) Extract and tidy importance
#imp_obj <- varImp(rf_mod, scale = FALSE)

imp_df  <- data.frame(
  Variable   = rownames(orig_imp_df),
  Importance = orig_imp_df$importance,
  row.names  = NULL,
  stringsAsFactors = FALSE
) %>%
  arrange(desc(Importance))

# 3) Select top N variables to plot
top_n <- 17
imp_top <- imp_df %>% slice_head(n = top_n)

# 4) Plot with ggplot2
p <- ggplot(imp_top, aes(x = reorder(Variable, Importance), y = Importance)) +
  geom_col(fill = "steelblue", width = 0.7) +
  coord_flip() +
  labs(
    title = paste( "Variable Importances\n(Random Forest)"),
    x     = NULL,
    y     = "Importance (Overall)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.y = element_text(size = 12),
    axis.title.y = element_text(size = 14),
    axis.title.x = element_text(size = 14)
  )

# 5) Save to file
out_file <- paste0(PATH_wk, "HP/6_report/5_3_rf_varimp_top10.jpeg")
ggsave(filename = out_file, plot = p, width = 8, height = 6, dpi = 300)

message("Saved variable importance plot to: ", out_file)