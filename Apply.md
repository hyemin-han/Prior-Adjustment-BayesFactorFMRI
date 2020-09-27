# How to apply the prior adjustment for your own planned analysis
In order to use the method for your own analysis, you need to create several files for analysis prep and modify a py file in **/Working_memory_fMRI/BayesFactorFMRI**.

1. Create "mask.nii" consisting of 0 (not to be analyzed) vs. 1 (to be analyzed) that indicate which voxels shall be analyzed. mask.nii can be created with other fMRI analysis tools, such as SPM 12. In the case of SPM 12, mask.nii can be created by performing simple one-sample *t*-test at the second level (group level).
2. Create "list.csv" that contains the filenames of nii files that you plan to analyze. This file must have one column, "Filename". "Filename" should be placed in the first row in the first column. Then, the nii filenames should be placed in the second row and thereafter in the first column. Refer to "list.csv" provided in the working memory fMRI test.
3. Modify "run_meta_test.py" according to your own estimated parameters (C, N, R). These values can be updated by modifying the numbers in the py file.
- C: Contrast (e.g., 1)
- N: Noise strength (e.g., .5)
- R: Proportion of true positives (e.g., .125)<br />
In addition, if needed, the number of cores to be used can be modified by altering the value in "cores."
4. Make sure that all R and py source code files and required nii and csv files are located in the same folder (or directory).
5. Run "run_meta_test.py" (e.g., python run_meta_test.py)
6. Resultant nii files will be created in the same folder (or directory). These are the filenames of the nii files containing thresholded results:
- bf3_05_80.nii: When P = 80%
- bf3_05_85.nii: When P = 85%
- bf3_05_90.nii: When P = 90%
- bf3_05_95.nii: When P = 95%
- Bayes_707.nii: When the prior adjustment was not performed but the default Cauchy prior (sigma = .707) with multiple comparison correction was applied.<br />
In addition to these thresholded result files, "BFs_\*.nii"s contain unthresholded Bayes Factor values in voxels and "Ds_\*.nii"s contain median poterior effect size values in voxels.
