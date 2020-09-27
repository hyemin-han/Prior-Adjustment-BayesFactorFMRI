# Prior-Adjustment-BayesFactorFMRI
Adjusting prior distributions for Bayesian second-level fMRI analysis

For further details about required software and dependencies, refer to.

# Simulation data test
Source code and data files for the simulated data test are available in /Simulation. The test can be performed with "run_cycle.py". Required parameters can be entered on command line. Here are guidelines about how to enter the parameters:
**> run_cycle.py Proportion(R) Ns Percentiles(P) Iterations Cores**
- Proportion (R): Only one R can be provided. R should be one of the nii filenames in "originals" subfolder. For instance, if we want to test .10%, then it should be "0.10"
- Ns: The number(s) of subjects (or image files) to be tested. Multiple values can be provided with ",". For instance, if we want to test Ns = 8, 12, 16, 20 as done in the paper, then "8,12,16,20".
- Percentiles (P): P value(s) to be tested. Multiple values can be provided with ",". If P = "0," then the default Cauchy prior (sigma = .707) after multiple comparison correction is used. For instance, if we want to test 80%, 85%, 90%, 95%, and the default Cauchy prior, then ".80,.85,.90,.95,0".
- Iterations: How many times each condition shall be tested?
- Cores: How many cores shall be utilized?
For instance, if we want to test the simulated image with .10% of true positives (R = .10%), and Ns = 8, 12, 16, 20, P = 80%, 85%, 90%, 95%, Default Cauchy prior with 10 iterations for each condition with 4 cores, then,
**> run_cycle.py 0.10 8,12,16,20 .80,.85,.90,.95,0 10 4**
The current original files were created with C (contrast) = 1 and N (noise strength in terms of standard deviation) = .50.

# Working memory fMRI data test
If you want to test the working memory fMRI data as described in the paper, please use the files in /Working_memory_fMRI. There are three subfolders in this folder:
1. Meta_analysis: NIfTI files that report results from meta-analyses are contained in this subfolder. Run "meta_test.R" to estimate parameters required for the prior adjustment, C, N, and R.
2. BayesFactorFMRI: Files for Bayesian second-level fMRI analysis with prior adjustment are available. Run "run_meta_test.py" to perform Bayesian analysis (five conditions: no adjustment, P = 80%, 85%, 90%, 95%). Resultant nii files will be created in the same folder.
3. Performance_evaluation: Files for performance comparison are available. In this folder, resultant nii files from BayesFactorFMRI and SPM 12 are provided. In addition, meta-analysis results for evaluation created by BayesMeta, BrainMap, NeuroSynth, and NeuroQuery are also available. Run "test_overlap_working.R" to perform performance evaluation.
