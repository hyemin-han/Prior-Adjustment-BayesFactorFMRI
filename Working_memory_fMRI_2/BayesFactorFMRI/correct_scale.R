# do correction
library(BayesFactor)
library("oro.nifti")

correct_scale<-function(filename_mask = 'mask.nii'){
  
  # read mask file
  MaskImg <- readNIfTI(filename_mask)
  MaskImgData = oro.nifti::img_data(MaskImg)
  
  # get mask size image
  X <- dim(MaskImg)[1]
  Y <- dim(MaskImg)[2]
  Z <- dim(MaskImg)[3]
  
  # let's count non-zero and non-nan voxel number
  count <- 0
  for (i in 1:X){
    for (j in 1:Y){
      for (k in 1:Z){
        if ((MaskImgData[i,j,k] != 0) && !(is.nan(MaskImgData[i,j,k])) ){
          # non zero and non nan -> count
          count <- count + 1
        }
        
      }
    }
  }

  # get combination (to find the # of comparison groups)
  # find m where mC2 = total voxel number
  # start from 2
  config_scale <- .707
  config_alpha <- .05

  now <- 2
  while(1){
    # calculate current combination
    combination <- now * (now-1)/2
    # combination >= count (non-zero non-nan voxel #?)
    if (combination >= count){
      break
    }
    # the goal not achieved, then, increase 1
    now <- now + 1
  }
  
  # finalize group number
  Group <- now
  
  # then, p(H01) = p(H0)^(2/m) where m = Group
  # calculate the corrected threshold value
  # .95 ^ (2/Group)
  
  corr_p <- (1-config_alpha)^(2/Group)
  
  # time to look for Cauchy distribution scale SCALE_NEW that satisfies 
  # pcauchy(qcauchy(.95,scale=.707), SCALE_NEW) = corr_p
  default_point <- qcauchy((1-config_alpha),scale=config_scale)
  
  # set desired precision
  # default = (1-corr_p) / 10
  
  precision <- (1-corr_p) / 10
  
  # starting from the default scale .707
  scale_default <- config_scale
  scale_current <- scale_default
  scale_previous <- scale_default
  trial <- 1
  
  while(1)
  {
    # until the precision is achieved...
    
    # if first trial,
    if (trial == 1)
    {
      # starting from the half of the default scale
      scale_current <- scale_default / 2.0
      # calculate the current culumative pdf at default_point
      current_cpdf <- pcauchy(default_point, scale= scale_current)
      # calculate difference
      diff <- abs(corr_p - current_cpdf)
      # diff <= precision?
      if (diff <= precision){
        # stop here
        break
      }
      # if not, trial <- trial + 1
      trial <- trial + 1
      # and also find the dirrection
      if ((corr_p - current_cpdf) > 0)
      {
        # scale_current should be decreased, so right direction
        direction <- -1
      }
      else
      {
        # scale_current should be increased, so let's tweak it
        direction <- 1
      }
    }
    else{
      # if not the first trial...
      # find the distance between current and previous scale
      distance <- abs(scale_current - scale_previous)
      
      # then, set the current scale as start_point + distance /2 * direction 		
      # also, update the previous scale
      scale_previous <- scale_current
      scale_current <- scale_current + distance / 2.0 * direction
      
      # calculate the current culumative pdf at default_point
      current_cpdf <- pcauchy(default_point,scale= scale_current)
      # calculate difference
      diff <- abs(corr_p - current_cpdf)
      # diff <= precision?
      if (diff <= precision){
        # stop here
        break
      }
      # if not, trial <- trial + 1
      trial <- trial + 1		
      # and also find the dirrection	
      if ((corr_p - current_cpdf) > 0)
      {
        # scale_current should be decreased, so right direction
        direction <- -1
      }
      else
      {
        # scale_current should be increased, so let's tweak it
        direction <- 1
      }	
    }
  }
  
  # found current scale!
  # let's use this scale for cauchy prior distribution
  return(scale_current)  
}