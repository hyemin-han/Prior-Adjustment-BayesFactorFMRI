# Prior-Adjustment-BayesFactorFMRI
Adjusting prior distributions for Bayesian second-level fMRI analysis

For further details about required software and dependencies, refer to.

# Working memory fMRI data test
If you want to test the working memory fMRI data as described in the paper, please use the files in /Working_memory_fMRI. There are three subfolders in this folder:
1. Meta_analysis: NIfTI files that report results from meta-analyses are contained in this subfolder. Run "meta_test.R" to estimate parameters required for the prior adjustment, C, N, and R.
2. BayesFactorFMRI: Files for Bayesian second-level fMRI analysis with prior adjustment are available. Run "run_meta_test.py" to perform Bayesian analysis (five conditions: no adjustment, P = 80%, 85%, 90%, 95%). Resultant nii files will be created in the same folder.
3. Performance_evaluation: Files for performance comparison are available. In this folder, resultant nii files from BayesFactorFMRI and SPM 12 are provided. In addition, meta-analysis results for evaluation created by BayesMeta, BrainMap, NeuroSynth, and NeuroQuery are also available. Run "test_overlap_working.R" to perform performance evaluation.
