# Preprint is available at bioRxiv https://bit.ly/3goFZAd

# Prior-Adjustment-BayesFactorFMRI
Adjusting prior distributions for Bayesian second-level fMRI analysis

This repository includes files for the prior adjustment for Bayesian second-level fMRI analysis. There are two case examples available: the simulation data test (/Simulation) and the working memory fMRI data test (/Working_memory_fMRI). Directions for each example are available in the following sections. <br />
In order to run the tests, both Python (tested with 3.7.3; >= 3.7.3 required, but 3.8 is not recommended) and R (tested with 4.0.2; >= 3.5 required) are required. Here are the list of dependencies for each language: <br />
1. Python: tkinter (developed with 8.6), shutil, pandas (developed with 0.24.2), nibabel (developed with 2.4.1), rpy2 (developed with 3.2.2), numpy (developed with 1.16.2), nilearn (developed with 0.6.2), subprocess. **Specified directions about how to install required dependencies are available in https://github.com/hyemin-han/BayesFactorFMRI/blob/master/README.md**
2. R: BayesFactor (developed with 0.9.12-4.2), metaBMA (developed with 0.6.1), oro.nifti (developed with 0.9.1), imager, tools

For further details about required software and dependencies, refer to and cite:<br />
- Han, H. (in press). BayesFactorFMRI: Implementing Bayesian second-level fMRI analysis with multiple comparison correction and Bayesian meta-analysis of fMRI images with multiprocessing. *Journal of Open Research Software*. (currently available at bioRxiv https://bit.ly/34t7555) <br />

In addition, please cite these papers as well:<br />
- Bayesian second-level fMRI analysis with multiple comparison correction: Han, H. (2020). Implementation of Bayesian multiple comparison correction in the second-level analysis of fMRI data: With pilot analyses of simulation and real fMRI datasets based on voxelwise inference. *Cognitive neuroscience, 11*(3), 157-169. 
- Bayesian meta-analysis of fMRI data: Han, H., & Park, J. (2019). Bayesian meta-analysis of fMRI image data. *Cognitive neuroscience, 10*(2), 66-76.

# Simulation data test
Source code and data files for the simulated data test are available in /Simulation. The test can be performed with "run_cycle.py". Required parameters can be entered on command line. Here are guidelines about how to enter the parameters:<br />
**> run_cycle.py Proportion(R) Ns Percentiles(P) Iterations Cores**<br />
- Proportion (R): Only one R can be provided. R should be one of the nii filenames in "originals" subfolder. For instance, if we want to test .10%, then it should be "0.10"
- Ns: The number(s) of subjects (or image files) to be tested. Multiple values can be provided with ",". For instance, if we want to test Ns = 8, 12, 16, 20 as done in the paper, then "8,12,16,20".
- Percentiles (P): P value(s) to be tested. Multiple values can be provided with ",". If P = "0," then the default Cauchy prior (sigma = .707) after multiple comparison correction is used. For instance, if we want to test 80%, 85%, 90%, 95%, and the default Cauchy prior, then ".80,.85,.90,.95,0".
- Iterations: How many times each condition shall be tested?
- Cores: How many cores shall be utilized?

For instance, if we want to test the simulated image with .10% of true positives (R = .10%), and Ns = 8, 12, 16, 20, P = 80%, 85%, 90%, 95%, Default Cauchy prior with 10 iterations for each condition with 4 cores, then,<br />
**> run_cycle.py 0.10 8,12,16,20 .80,.85,.90,.95,0 10 4**<br />
The current original files were created with C (contrast) = 1 and N (noise strength in terms of standard deviation) = .50.

# Working memory fMRI data test
If you want to test the working memory fMRI data as described in the paper, please use the files in /Working_memory_fMRI. There are three subfolders in this folder:
1. Meta_analysis: NIfTI files that report results from meta-analyses are contained in this subfolder. Run "meta_test.R" to estimate parameters required for the prior adjustment, C, N, and R.
2. BayesFactorFMRI: Files for Bayesian second-level fMRI analysis with prior adjustment are available. Run "run_meta_test.py" to perform Bayesian analysis (five conditions: no adjustment, P = 80%, 85%, 90%, 95%). Resultant nii files will be created in the same folder.
3. Performance_evaluation: Files for performance comparison are available. In this folder, resultant nii files from BayesFactorFMRI and SPM 12 are provided. In addition, meta-analysis results for evaluation created by BayesMeta, BrainMap, NeuroSynth, and NeuroQuery are also available. Run "test_overlap_working.R" to perform performance evaluation.

# Working memory fMRI data test (2)
The same test can be done with another working memory fMRI dataset in /Working_memory_fMRI_2. Among three steps in the prior section, **only 2 and 3** can be performed with the second working memory fMRI dataset.

# Want to test the method with your own nii files?
Please refer to https://github.com/hyemin-han/Prior-Adjustment-BayesFactorFMRI/blob/master/Apply.md
