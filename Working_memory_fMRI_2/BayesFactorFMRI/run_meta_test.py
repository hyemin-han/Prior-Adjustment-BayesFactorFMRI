import rpy2.robjects as robjects
import pandas as pd
import bayes_adjust_main as bcm
from datetime import datetime
import sys
import math
import os
import shutil

# calculate current scale
# input: type (0 = .707, 1 = customized)
# contrast default = 1 (C)
# SD default = .5 (N)
# proportion default = .1 (R)
# percentile default = .9 (P)

# parameters
# Contrast (C)
C = .551914551595074
# Noise (N)
N = .329079935522663
# Proportion of true positives
R = .129173568930609

# use four cores
# you may change this value as per your resource availability
cores = 4

def calc_scale(type=0, contrast=1, SD = .5, proportion = .1, percentile = .9):
	# .707 or customized?
	if type == 0:
		# do general correction
		r = robjects.r
		r.source("correct_scale.R")
		scale=r.correct_scale()
		scale=scale[0]
	else:
		# customized
		r = robjects.r
		r.source("adjust_cauchy_scale.R")
		scale=r.adjust_cauchy_scale(contrast,SD,proportion,percentile)
		scale=scale[0]
	return (scale)

# calculate scales for four trials 80% to 95%
# with results from previous meta-analysis


scale707 = calc_scale(0,C,N,R,.80)
scale80 = calc_scale(1,C,N,R,.80)
scale85 = calc_scale(1,C,N,R,.85)
scale90 = calc_scale(1,C,N,R,.90)
scale95 = calc_scale(1,C,N,R,.95)

start =0  
# default prior (.707)
bcms = bcm.bayes_correction_main('mask.nii','./list.csv',cores,scale707,0, start)
shutil.move(('./BFs_%d.nii')%(start),('./BFs_707.nii'))
shutil.move(('./bf3_05_%d.nii')%(start), ('./Bayes_707.nii') )
shutil.move(('./Ds_%d.nii')%(start), ('./Ds_707.nii') )

# with P = 80%
bcms = bcm.bayes_correction_main('mask.nii','./list.csv',cores,scale80,0, start)
shutil.move(('./BFs_%d.nii')%(start),('./BFs_80.nii'))
shutil.move(('./bf3_05_%d.nii')%(start), ('./bf3_05_80.nii') )
shutil.move(('./Ds_%d.nii')%(start), ('./Ds_80.nii') )

# with P = 85%
bcms = bcm.bayes_correction_main('mask.nii','./list.csv',cores,scale85,0, start)
shutil.move(('./BFs_%d.nii')%(start),('./BFs_85.nii'))
shutil.move(('./bf3_05_%d.nii')%(start), ('./bf3_05_85.nii') )
shutil.move(('./Ds_%d.nii')%(start), ('./Ds_85.nii') )

# with P = 90%
bcms = bcm.bayes_correction_main('mask.nii','./list.csv',cores,scale90,0, start)
shutil.move(('./BFs_%d.nii')%(start),('./BFs_90.nii'))
shutil.move(('./bf3_05_%d.nii')%(start), ('./bf3_05_90.nii') )
shutil.move(('./Ds_%d.nii')%(start), ('./Ds_90.nii') )

# with P = 95%
bcms = bcm.bayes_correction_main('mask.nii','./list.csv',cores,scale95,0, start)
shutil.move(('./BFs_%d.nii')%(start),('./BFs_95.nii'))
shutil.move(('./bf3_05_%d.nii')%(start), ('./bf3_05_95.nii') )
shutil.move(('./Ds_%d.nii')%(start), ('./Ds_95.nii') )