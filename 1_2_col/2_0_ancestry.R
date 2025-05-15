# 2_0_ancestry.R
# Clean, cluster grandparent ancestral country, and compute family diabetes history


#---- Libraries ----
library(dplyr)
library(countrycode)
library(vegan)   # for diversity()

#---- Specify ancestry columns ----
ancestry_columns <- c(
  "Birth.place.of.paternal.grandfather..country.",
  "Birth.place.of.paternal.grandmother..country.",
  "Birth.place.of.maternal.grandfather..country.",
  "Birth.place.of.maternal.grandmother..country."
)

#---- (Optional) Load data ----
PATH_wk <- "~/scratch/UQAC/meth/"
# clinical_updates <- read.csv(paste0(PATH_wk, "HP/clinical_updates.csv"),
#                             stringsAsFactors = FALSE)

#---- Process ancestry and family history ----
clinical_updates <- clinical_updates %>%
  # 1. Clean blanks/"Unknown" -> NA for ancestry
  mutate(across(all_of(ancestry_columns),
                ~ na_if(., "") %>% na_if("Unknown"),
                .names = "{.col}_clean")) %>%
  # 2. Map cleaned country -> standard continent
  mutate(across(ends_with("_clean"),
                ~ countrycode(.x, "country.name", "continent"),
                .names = "{.col}_continent")) %>%
  # 3. Recode continent -> 5 ancestry groups (_eth5)
  mutate(across(ends_with("_continent"),
                ~ case_when(
                    .x == "Africa"   ~ "African",
                    .x == "Europe"   ~ "European",
                    .x == "Americas" ~ "American",
                    .x == "Asia"     ~ "Asian",
                    .x == "Oceania"  ~ "Oceanian",
                    TRUE               ~ "Other/Unknown"
                  ),
                .names = "{.col}_eth5")) %>%
  # 4. merge Oceanian into Asian for 4-group solution (_eth4)
  mutate(across(ends_with("_eth5"),
                ~ if_else(.x == "Oceanian", "Asian", .x),
                .names = "{.col}_eth4")) %>%
  # 5. Compute predominant continent + Shannon diversity
  rowwise() %>%
  mutate(
    cluster_pred_ancestry = {
      conts <- na.omit(c_across(ends_with("_continent")))
      if (length(conts) == 0) NA_character_
      else names(which.max(table(conts)))
    },
    cluster_shannon = {
      conts <- na.omit(c_across(ends_with("_continent")))
      if (length(conts) == 0) NA_real_
      else diversity(as.numeric(table(conts)), index = "shannon")
    }
  ) %>%
  ungroup() %>%
  # 6. Compute family history: any first-/second-degree relative with diabetes
  mutate(
    family_history_diabetes = if_else(
      if_any(
        c(
          starts_with("Are.any.of.the.subject.siblings.diagnosed"),
          starts_with("Is.the.subject.s.mother.diagnosed"),
          starts_with("Is.the.subject.s.father.diagnosed"),
          starts_with("If.a.first.degree.relative.of.the.subject.has.diabetes")
        ),
        ~ !is.na(.) & . != ""
      ),
      "Yes", "No"
    )
  )

#--Save augmented data ----
# write.csv(clinical_updates,
#           file = paste0(PATH_wk, "HP/clinical_updates_with_ancestry_and_family.csv"),
#           row.names = FALSE)

