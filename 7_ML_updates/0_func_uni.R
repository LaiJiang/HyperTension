outcome <- "Y"
predictors <- setdiff(colnames(HP_dat), outcome)

results <- lapply(predictors, function(var) {
  x <- HP_dat[[var]]
  y <- HP_dat[[outcome]]

  # Skip NA-only columns
  if (all(is.na(x)) || all(is.na(y))) return(NULL)

  # Remove rows with NAs
  complete <- complete.cases(x, y)
  x <- x[complete]
  y <- y[complete]

  if (length(unique(x)) <= 2 && all(x %in% c(0, 1, NA))) {
    # Binary predictor
    test <- tryCatch(t.test(y ~ x), error = function(e) NULL)
    stat <- if (!is.null(test)) test$statistic else NA
    pval <- if (!is.null(test)) test$p.value else NA
    type <- "binary_t_test"
  } else {
    # Numeric predictor
    test <- tryCatch(cor.test(x, y), error = function(e) NULL)
    stat <- if (!is.null(test)) test$estimate else NA
    pval <- if (!is.null(test)) test$p.value else NA
    type <- "pearson_cor"
  }

  data.frame(
    variable = var,
    stat = stat,
    pval = pval,
    test_type = type
  )
})

# Combine and sort
assoc_results <- do.call(rbind, results)
assoc_results <- assoc_results[order(assoc_results$pval), ]

# View top hits
head(assoc_results)

#print top 20 features
top_hits <- head(assoc_results, 70)
#top_hits

#table(HP_dat$"X6.32415221_A2",HP_dat$Y)

#print column names start with "x"
