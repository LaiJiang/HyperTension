# 0) Install / load required packages
if (!requireNamespace("mlr", quietly=TRUE))         install.packages("mlr")
if (!requireNamespace("ParamHelpers", quietly=TRUE)) install.packages("ParamHelpers")
if (!requireNamespace("pROC", quietly=TRUE))        install.packages("pROC")
if (!requireNamespace("PRROC", quietly=TRUE))       install.packages("PRROC")
library(mlr)
library(ParamHelpers)
library(pROC)
library(PRROC)
library(dplyr)

# 1)  XGBoost training function
train_model <- function(data){
  set.seed(42)
  #no need for weights
  w <- rep(1, nrow(data))
  w[data$response == 0] <- sum(data$response == 1) / sum(data$response == 0)
  
  # force response to factor
  data$response <- as.factor(data$response)
  
  # learner + static hyperparams
  learner <- makeLearner("classif.xgboost", predict.type = "prob")
  learner$par.vals <- list(
    objective   = "binary:logistic",
    eval_metric = "aucpr",
    nrounds     = 150L,
    eta         = 0.1
  )
  
  # tuning space
  ps <- makeParamSet(
    makeDiscreteParam("booster",        values = "gbtree"),
    makeIntegerParam("max_depth",       lower  = 3L,  upper = 10L),
    makeNumericParam("min_child_weight",lower  = 1,   upper = 10),
    makeNumericParam("colsample_bytree",lower  = 0.5, upper = 1),
    makeNumericParam("lambda",          lower  = 0,   upper = 5),
    makeNumericParam("gamma",           lower  = 1,   upper = 10)
  )
  
  task <- makeClassifTask(
    data   = data,
    target = "response",
    weights = w
  )
  
  rdesc <- makeResampleDesc("CV", stratify = TRUE, iters = 3L)
  ctrl  <- makeTuneControlRandom(maxit = 10L)
  
  # optimize for PR‑AUC
  tune <- tuneParams(
    learner   = learner,
    task      = task,
    resampling= rdesc,
    measures  = gpr,        # PR‑AUC
    par.set   = ps,
    control   = ctrl,
    show.info = TRUE
  )
  
  # set the tuned hyperparams
  tuned <- setHyperPars(learner, par.vals = tune$x)
  
  # train final model
  xgb_mod <- train(tuned, task)
  return(xgb_mod)
}

# 2) Load split
PATH_wk <- "C:/Per/LaiJiang/Project/ADDAM/"
load(paste0(PATH_wk, "HP/results/7_1_split.RData"))

# 3) Rename Y  response (numeric 0/1)
train_data$response <- train_data$Y
test_data$response  <- test_data$Y



# 1) rename Y  response and then drop the old Y column
train_data <- train_data %>%
  mutate(response = Y) %>%
  select(-Y)

test_data  <- test_data %>%
  mutate(response = Y) %>%
  select(-Y)


# 1) Convert ALL logical columns into numeric 0/1
train_data <- train_data %>%
  mutate(across(where(is.logical), ~ as.numeric(.) ))

test_data <- test_data %>%
  mutate(across(where(is.logical), ~ as.numeric(.) ))

# 4) Fit XGBoost
xgb_model <- train_model(train_data)

# 5) Predict on test set
pred <- predict(xgb_model, newdata = test_data)

# extract prob for class 1
# mlr outputs columns prob.0 and prob.1 in pred$data
pred_probs <- pred$data$prob.1

# get true labels as numeric
truth <- as.numeric(as.character(test_data$response))

#plot age and pred_probs, colored by truth
plot(test_data$age_BP, pred_probs, col = ifelse(truth == 1, "red", "blue"),
     pch = 19, xlab = "Age", ylab = "Predicted Probability")




# 6) ROC & AUC
roc_obj <- roc(truth, pred_probs)
auc_roc <- auc(roc_obj)

#save ROC plot 
jpeg(filename = paste0(PATH_wk, "HP/7_ML_updates/roc_xgb.jpeg"), width = 800, height = 600)
cat("XGB ROC AUC:", round(auc_roc,3), "\n")
plot(roc_obj, main = sprintf("XGBoost ROC (AUC = %.3f)", auc_roc))
dev.off()


# 7) Precision–Recall & AUC
fg <- pred_probs[truth == 1]
bg <- pred_probs[truth == 0]
pr_obj <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = TRUE)
cat("XGB PR  AUC:", round(pr_obj$auc.integral,3), "\n")
plot(pr_obj, main = sprintf("XGBoost PR Curve (AUC = %.3f)", pr_obj$auc.integral))

# 8) (Optional) Variable importance
imp <- getFeatureImportance(xgb_model)$res
imp_df <- data.frame(
  Feature = imp$variable,
  Importance = imp$importance
) %>%
  arrange(desc(Importance))
print(head(imp_df, 20))

# 9) Save model
save(xgb_model, file = paste0(PATH_wk, "HP/results/7_4_xgboost.RData"))


