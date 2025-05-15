# 1) load packages
library(dplyr)

# 2) read  data
clinical <- read.csv(
  "C:/Per/LaiJiang/Project/ADDAM/dat/ADDAM_Clustering_MCh_participants_Nov13.csv",
  stringsAsFactors = FALSE, 
  check.names = FALSE
)

# 3) define the exact column names
first_deg <- c(
 "Are any of the subject's siblings diagnosed with diabetes (any type)?" ,
 "Is the subject's mother diagnosed with diabetes (any type)?" ,
 "Is the subject's father diagnosed with diabetes (any type)?" )



second_deg <- c(
  "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Paternal grandfather)" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Paternal grandmother)" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Paternal uncle (s))" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Paternal aunt (s))" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Maternal grandfather)" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Maternal grandmother)" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Maternal uncle (s))" ,
 "If a first degree relative of the subject has diabetes (mother, father or sibling), is there diabetes in any of the following family members? (check all that apply) (choice=Maternal aunt (s))" )




# 4) recode and build the family‐history flag
clinical_flagged <- clinical %>%
  
  # A) recode first‐degree: treat "Yes" as TRUE, anything else (NA/No) as FALSE
  mutate(across(all_of(first_deg),
                ~ .x == "Yes",
                .names = "fh1_{.col}")) %>%
  
  # B) recode second‐degree: treat "Checked" as TRUE, anything else as FALSE
  mutate(across(all_of(second_deg),
                ~ .x == "Checked",
                .names = "fh2_{.col}")) %>%
  
  # C) combine into a single Yes/No flag
  mutate(
    family_history_diabetes = if_else(
      # if any fh1_ or fh2_ column is TRUE
      rowSums(select(., starts_with("fh1_")), na.rm = TRUE) +
      rowSums(select(., starts_with("fh2_")), na.rm = TRUE) > 0,
      "Yes", 
      "No"
    )
  )

# 5) inspect
table(clinical_flagged$family_history_diabetes, useNA = "ifany")

# 
# write.csv(clinical_flagged,
#           "C:/Per/LaiJiang/Project/ADDAM/dat/ADDAM_with_family_history.csv",
#           row.names = FALSE)
