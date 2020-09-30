# import oro.nifti

library("oro.nifti")

## calc_false_alarm
# a function to compare original and a provided nii (or hdr)
# first, false alaram
calc_false_alarm<-function(original, target){
  # calculate the number of true actives and false actives in target
  true_act <- sum((original>0 & target >0))
  false_act <- sum((original==0 & target > 0))
  
  false_alarm<-false_act/(true_act+false_act)
  return(false_alarm)
}

## calc_hit_rate
# second, hit rate calculated
calc_hit_rate<-function(original,target){
  # both should be active
  true_act <- sum((original>0 & target >0))
  # also, all active voxels in the original image should be counted
  original_act <- sum(original >0)
  # then calculate the ratio
  hit_rate <- true_act/original_act
  return(hit_rate)
}

# return image data matrix from filename
get_image<-function(filename){
  # remove NAN
  image<-oro.nifti::img_data(readNIfTI(filename))
  XX = dim(image)[1]
  YY = dim(image)[2]
  ZZ = dim(image)[3]
  
  # loop
  for (i in 1:XX){
    for (j in 1:YY){
      for (k in 1:ZZ){
        if(is.na(image[i,j,k])){
          image[i,j,k]<-0
        }
      }
    }
  }
  return(image)
}

# return image data matrix from filename
# concatrate one unnecessary dimension
get_image_4D<-function(filename){
  # remove NAN
  image<-oro.nifti::img_data(readNIfTI(filename))
  XX = dim(image)[1]
  YY = dim(image)[2]
  ZZ = dim(image)[3]
  
  image<-drop(image)
  
  # loop
  for (i in 1:XX){
    for (j in 1:YY){
      for (k in 1:ZZ){
        if(is.na(image[i,j,k])){
          image[i,j,k]<-0
        }
      }
    }
  }
  return(image)
}

## do_calculations
# do calculate both rates with a given filename list 
# and return in df
do_calculations<-function(original_filename,filenames){
  # get the number of target files
  num_files<-length(filenames)
  # then create two vectors to save results
  false_alarm<-rep(0,num_files)
  hit_rate<-rep(0,num_files)
  # get original image
  original_img<-get_image(original_filename)
  # calculate both indicators for each bf file
  for (i in 1:num_files){
    # load the current bf file
    current_img<-get_image(filenames[i])
    false_alarm[i]<-calc_false_alarm(original_img,current_img)
    hit_rate[i]<-calc_hit_rate(original_img,current_img)
  }
  # then combine two vectors to create a df
  results<-as.data.frame(cbind(false_alarm,hit_rate))
  # return the result
  return(results)
}

## eval_Bayesian
# first, calculate all performance indicators for Bayesian files
# original filename should be provided (including the directory)
# sub-directory can be specified. 
# if specified, then bayesian thresholded filed in the sub-directory are assessed.
eval_Bayesian<-function(original_filename,sub_dir = '.'){
  # filenames for four thresholds
  # consider the sub-directory if provided
  filenames<-c(paste(cbind(sub_dir,'bf3_05.nii'),collapse='/'),
               paste(cbind(sub_dir,'bf3_01.nii'),collapse='/'),
               paste(cbind(sub_dir,'bf3_005.nii'),collapse='/'),
               paste(cbind(sub_dir,'bf3_001.nii'),collapse='/'))
 
  # call the function to calculate performance indicators for Bayesian cases
  results<-do_calculations(original_filename,filenames)
  # change column names
  colnames(results)<-c('Bayesian False Alarm Rate','Bayesian Hit Rate')
  # change row names (threshold)
  rownames(results)<-c('.05','.01','.005','.001')
  return(results)
}

## eval_Classical
# first, calculate all performance indicators for Classical files
# original filename should be provided (including the directory)
# sub-directory can be specified. 
# if specified, then bayesian thresholded filed in the sub-directory are assessed.
eval_Classical<-function(original_filename,sub_dir = '.'){
  # filenames for four thresholds
  # consider the sub-directory if provided
  filenames<-c(paste(cbind(sub_dir,'fwe05.nii'),collapse='/'),
               paste(cbind(sub_dir,'fwe01.nii'),collapse='/'),
               paste(cbind(sub_dir,'fwe005.nii'),collapse='/'),
               paste(cbind(sub_dir,'fwe001.nii'),collapse='/'))
  
  # call the function to calculate performance indicators for Bayesian cases
  results<-do_calculations(original_filename,filenames)
  # change column names
  colnames(results)<-c('Classical False Alarm Rate','Classical Hit Rate')
  # change row names (threshold)
  rownames(results)<-c('.05','.01','.005','.001')
  return(results)
}

## report_results
# do both Bayesian and Classical evaluation in a designated directory
# specify that classical folder if it is different from the original folder
# create a csv file reporting results
# in both the wide and long formats
# in long format, record the designated subject information or directory name for further info
report_results<-function(original_filename,sub_dir = '.',sub_classical='classical',
                         subj_info=''){
  # if subject info is not specified, use the directory name
  if(subj_info==''){
    subj_info<-sub_dir
  }
  # designate classical directory
  if(sub_classical==''){
    dir_classical<-sub_dir
  }else{
    dir_classical<-sprintf('%s/%s',sub_dir,sub_classical)
  }
  # do two analyses
  Bayesian_result<-eval_Bayesian(original_filename,sub_dir)
  Classical_result<-eval_Classical(original_filename,dir_classical)
  # merge two result dfs
  # create one additional column to specify the type of inference
  # in addition, thresholds
  Bayesian_result<-cbind(Bayesian_result,rep(1,4),c(.05,.01,.005,.001))
  Classical_result<-cbind(Classical_result,rep(0,4),c(.05,.01,.005,.001))
  # use the common colnames
  colnames(Bayesian_result)<-c('false_alarm_rate','hit_rate','bayesian','threshold')
  colnames(Classical_result)<-c('false_alarm_rate','hit_rate','bayesian','threshold')
  # merge
  long_result<-rbind(Bayesian_result,Classical_result)
  rownames(long_result)<-c()
  
  #temporary
  return(long_result)
  
}

## report result for repeated test
## shape test
report_results_shape<-function(original_filename,current_n){
  # get the current result at n
  # if n is integer
  if (round(current_n)==current_n){
    Bayesian_result<-eval_Bayesian(original_filename,sprintf("./%d",current_n))
  }
  # get true active numbers
  original<-get_image(original_filename)
  true_act<-sum(original>0,na.rm = T)
  # write into file
  # add column for thresholds
  Bayesian_result<-cbind(Bayesian_result,rep(1,4),c(.05,.01,.005,.001),rep(current_n,4),rep(true_act,4))
  # change name
  colnames(Bayesian_result)<-c('false_alarm_rate','hit_rate','bayesian','threshold','current_n','true_active')
  # write into file
  if (round(current_n)==current_n){
    write.csv(Bayesian_result,file = sprintf("./%d.csv",current_n))
  }
  #####
  # return the result
  return(Bayesian_result)
}
