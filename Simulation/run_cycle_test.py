import rpy2.robjects as robjects
import pandas as pd
import bayes_adjust_main as bcm
from datetime import datetime
import sys
import math
import os
import shutil

# get original file name, N, SD, dir
# create noise images 
def create_noise_images(original,directory=".",N=20,SD=.5):
	# filename generation
	original_file = (('./originals/%.2f.nii')%original)

	# import r function
	r=robjects.r

	r.source("add_noise.R")
	# do add noise
	result = r.create_noise_images(original_file,directory,N,SD)

	return(1)

# create list.csv with Ns
def create_nii_list(directory=".",N=20,start=0):
	# from 1 to N
	lists = ["" for x in range(N)]
	for i in range(N):
		lists[i] = ('%s/%d.nii' % (directory,(i+1) ))
	# create dataframe
	df = pd.DataFrame(pd.Series(lists),columns=['Filename'])
	# write list.csv in directory
	df.to_csv(('list_%d.csv' % start), index=False)

# evaluation
# input: current bf3 file (default: bf3_05.nii)
# original: in number
# directory : default ('./originals')
# return: false alarm, hit rate
def do_evaluation(original,current="bf3_05.nii", directory="./originals"):
	# create original filename
	filename_original = ('%s/%.2f.nii'% (directory,original))
	# do comparison
	r=robjects.r
	r.source("eval_performance_auto.R")
	# false alarm
	fr=r.calc_false_alarm_file(original=filename_original,target=current)
	# hit rate
	hit =r.calc_hit_rate_file(original=filename_original,target=current)
	# return
	return (fr[0], hit[0])

# calculate current scale
# input: type (0 = .707, 1 = customized)
# contrast default = 1
# SD default = .5
# proportion default = .1
# percentile default = .9
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

# do loop
# proportion = will be used for original nii filename. No default.
# Ns = N list = [8 12 16 20] (x 4)
# percentiles = percentile list = [.8 .85 .9 .95] + [.707] (x5)
# iterations = default iterations per condition = (x 10)
def do_loop(proportion, Ns=[8, 12, 16, 20], percentiles=[.8, .85, .9, .95, 0], iterations = 10, cpus = 4, mask = 'mask.nii', start=0):
	# record when it starts
	# it will be used for the log filename
	# datetime object containing current date and time
	now = datetime.now()
	filename = (("%s_%d.csv")% (now.strftime("%m_%d_%Y_%H_%M_%S"),start))
	# create header
	fd= open(filename, 'a')
	fd.write('Proportion,N,Percentile,Iteration,FalsePositive,HitRate\n')
	fd.close()

	for i in range(iterations):
		# create directory
		os.mkdir(('%d' % (i+start)))
		# first of all, create noise images
		create_noise_images(proportion,("./%d"%(i+start)))

		# then, create list.csv for each N
		for j in range(len(Ns)):
			# create list.csv for the current N
			create_nii_list(("./%d"%(i+start)),Ns[j],(i+start))
			# do test for each percentile value
			for k in range(len(percentiles)):
				# if 0 then do 707
				if (percentiles[k] == 0):
					scale = calc_scale(0)
				else:
					# general adjustment
					scale = calc_scale(1,1,.5,proportion/100,percentiles[k])
				# Then, run bayes_correction_main
				bcms = bcm.bayes_correction_main(mask,('./list_%d.csv' % (i+start)),cpus,scale,0, start)

				# thresholding (BF >= 3) with bf3_05.nii
				# evaluation (eval_performance_auto.R)
				# write the current outcome in csv (for each iteration, open as append, write, and close)
				# filename shall be fixed at the beginning of the function (date + time)
				result = do_evaluation(proportion,('bf3_05_%d.nii')%(start))
				# print result
				with open(filename, 'a') as fd:
					fd.write(('%f,%d,%f,%d,%f,%f\n')%(proportion,Ns[j],percentiles[k],i+start,result[0],result[1]))
				fd.close()
				# rename the current output file
				shutil.move(('./BFs_%d.nii')%(start),('./results/BFs_%f_%d_%f_%d.nii')%(proportion,Ns[j],percentiles[k],i+start))
				shutil.move(('./bf3_05_%d.nii')%(start), ('./results/bf3_05_%f_%d_%f_%d.nii') % (proportion, Ns[j], percentiles[k], i+start))
				shutil.move(('./Ds_%d.nii')%(start), ('./results/Ds_%f_%d_%f_%d.nii') % (proportion, Ns[j], percentiles[k], i+start))
		#print(('N = %d, percentile = %f, %d/%d done!')% ())

		print('Done!')
	return 1

# test
#create_noise_images("16.nii","./test",20,.5)
#create_nii_list('./test',16)
#test=do_evaluation(1.6,"bf3_05_1.6.nii")
#print(test[0])
#print(test[1])
#test_707=calc_scale(0)
#print(test_707)
#test_90=calc_scale(1,1,.5,.2172543010,.9)
#print(test_90)
#do_loop(12.8,[12,16],[.9,0],2,6)

# get parameters to run
do_loop(.01,[16],[.9],1,4,'mask.nii',0)