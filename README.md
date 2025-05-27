# Updates: May 23



We docducted major updates on the ML algorithms:


* 1_2_col/2_4_C_pep.r: add imputed C-peptide to the analysis. 
* 1_2_col/2_5_bmi.r: bmi percentile and z-score according to the CDC growth chart. Done.
* 1_2_col/2_6_geno.r: collected the SNP-level genotype data. 

* 4_combine/4_2_process_updates.R: update the 4_1_process.R for the new paper. add more features..etc.

* 6_report/analysis_updates_May_23.ipynb: the updated analysis report. The corresponding html and pdf reports are also generated.

* 7_ML_update: updated machine leanning processes with all these new features for the new paper. 
  - 7_6_CV.R: generate leave-one-out cross-validated random forest predictions, and then derive bootstrap confidence intervals for ROC curve.
  - 7_7_boots.R:  apply bootstrap to get confidence intervals for the feature imortance weights from random forest.


