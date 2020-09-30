library(oro.nifti)
library(imager)

# resize for testing
resize_for_testing<-function(nii){
  return(as.array(drop(
    resize(as.cimg(readNIfTI(nii)),size_x=91,size_y=109,size_z=91))))
}

# check NIFTI size
check_standard_MNI_nifti<-function(nii){
  return(check_standard_MNI(oro.nifti::img_data(nii)))
}
# test the image size (91x109x91)?
check_standard_MNI<-function(image){
  # get image size
  img_size<-dim(image)
  # 91 x 109 x 91?
  return (sum(dim(image)==c(91,109,91))==3)
}
# match to 91x109x91
to_standard_MNI<-function(nii){
  # get image origin
  origin_x<-abs(srow_x(nii)[4])/abs(srow_x(nii)[1])
  origin_y<-abs(srow_y(nii)[4])/abs(srow_y(nii)[2])
  origin_z<-abs(srow_z(nii)[4])/abs(srow_z(nii)[3])
  # offset
  offset_x<-45-origin_x
  offset_y<-63-origin_y
  offset_z<-36-origin_z
  # create NaN image
  result<-array(NaN,c(91,109,91))
  # get original image
  original<-oro.nifti::img_data(nii)
  # drop 4d
  if (length(dim(original))>3){
    original<-drop(original)
  }
  img_size<-dim(original)
  # loop
  for (x in 1:img_size[1]){
    for (y in 1:img_size[2]){
      for (z in 1:img_size[3]){
        # NaN -> jump
        if (is.na(original[x,y,z])){
          next
        }
        # or, fill the gap
        result[x+offset_x,y+offset_y,z+offset_z]<-original[x,y,z]
      }
    }
  }
  # return = 3D image array
  return(result)
}

# calculate overlap index
calc_overlap<-function(original, target){
  # same size?
  if (sum(dim(original)==dim(target))<3){
    # different. error!
    return(-1)
  }
  # calculate overlap index
  V_overlap<-0
  V_original<-0
  V_target<-0
  img_size<-dim(original)
  # loop
  for (x in 1:img_size[1]){
    for (y in 1:img_size[2]){
      for (z in 1:img_size[3]){
        # na?
        if (is.na(original[x,y,z])){
          next
        }
        if (is.na(target[x,y,z])){
          next
        }

        # original
        if (original[x,y,z]>0){
          V_original<-V_original+1
        }
        # target
        if (target[x,y,z]>0){
          V_target<-V_target+1
        }
        #overlap
        if ( (original[x,y,z]*target[x,y,z]>0)){
          V_overlap<-V_overlap+1
        }
      }
    }
  }
  return(c(V_overlap*V_overlap/V_original/V_target/(V_overlap/V_original+V_overlap/V_target),
           V_overlap,V_original,V_target))
}

# compare bayesmeta and all
bayes_adjusted<-resize_for_testing('./bf3_05_90.nii')
bayes_707 <-resize_for_testing('./Bayes_707.nii')
fwe<-resize_for_testing('./fwe.nii')
bayes_meta<-to_standard_MNI(readNIfTI('Bayes_meta.hdr'))
result_bayes_meta<-as.matrix(c(
  calc_overlap(bayes_meta,bayes_adjusted)[1],
  calc_overlap(bayes_meta,bayes_707)[1],
  calc_overlap(bayes_meta,fwe)[1]
))
# neurosynth
neurosynth<-to_standard_MNI(readNIfTI('./NeuroSynth.nii'))
result_neurosynth<-as.matrix(c(
  calc_overlap(neurosynth,bayes_adjusted)[1],
  calc_overlap(neurosynth,bayes_707)[1],
  calc_overlap(neurosynth,fwe)[1]
))
# brainmap
brainmap<-to_standard_MNI(readNIfTI('./brainmap.nii'))
result_brainmap<-as.matrix(c(
  calc_overlap(brainmap,bayes_adjusted)[1],
  calc_overlap(brainmap,bayes_707)[1],
  calc_overlap(brainmap,fwe)[1]
))
# neuroquery
# needs size up -> do rescale
neuroquery<-as.array(drop(
  resize(as.cimg(readNIfTI('./neuroquery.nii')),size_x=91,size_y=109,size_z=91)))
neuroquery<-ifelse(neuroquery==0,NA,neuroquery)
result_neuroquery<-as.matrix(c(
  calc_overlap(neuroquery>=3,bayes_adjusted)[1],
  calc_overlap(neuroquery>=3,bayes_707)[1],
  calc_overlap(neuroquery>=3,fwe)[1]
))
# merge
result90<-data.frame(result_bayes_meta,result_neurosynth,result_brainmap,result_neuroquery)
rownames(result90)<-c('bayes_adjusted_90','bayes_707','fwe')
colnames(result90)<-c('bayes_meta','neurosynth','brainmap','neuroquery')




# compare bayesmeta and all 80%
bayes_adjusted<-resize_for_testing('./bf3_05_80.nii')
result_bayes_meta<-as.matrix(c(
  calc_overlap(bayes_meta,bayes_adjusted)[1]
))
# neurosynth
result_neurosynth<-as.matrix(c(
  calc_overlap(neurosynth,bayes_adjusted)[1]
))
# brainmap
result_brainmap<-as.matrix(c(
  calc_overlap(brainmap,bayes_adjusted)[1]
))
# neuroquery
# needs size up -> do rescale
neuroquery<-ifelse(neuroquery==0,NA,neuroquery)
result_neuroquery<-as.matrix(c(
  calc_overlap(neuroquery>=3,bayes_adjusted)[1]
))
# merge
result80<-data.frame(result_bayes_meta,result_neurosynth,result_brainmap,result_neuroquery)
rownames(result80)<-c('bayes_adjusted_80')
colnames(result80)<-c('bayes_meta','neurosynth','brainmap','neuroquery')



# compare bayesmeta and all 85%
bayes_adjusted<-resize_for_testing('./bf3_05_85.nii')
result_bayes_meta<-as.matrix(c(
  calc_overlap(bayes_meta,bayes_adjusted)[1]
))
# neurosynth
result_neurosynth<-as.matrix(c(
  calc_overlap(neurosynth,bayes_adjusted)[1]
))
# brainmap
result_brainmap<-as.matrix(c(
  calc_overlap(brainmap,bayes_adjusted)[1]
))
# neuroquery
# needs size up -> do rescale
result_neuroquery<-as.matrix(c(
  calc_overlap(neuroquery>=3,bayes_adjusted)[1]
))
# merge
result85<-data.frame(result_bayes_meta,result_neurosynth,result_brainmap,result_neuroquery)
rownames(result85)<-c('bf3_05_90')
colnames(result85)<-c('bayes_meta','neurosynth','brainmap','neuroquery')


# compare bayesmeta and all 95%
bayes_adjusted<-resize_for_testing('./bf3_05_95.nii')
result_bayes_meta<-as.matrix(c(
  calc_overlap(bayes_meta,bayes_adjusted)[1]
))
# neurosynth
result_neurosynth<-as.matrix(c(
  calc_overlap(neurosynth,bayes_adjusted)[1]
))
# brainmap
result_brainmap<-as.matrix(c(
  calc_overlap(brainmap,bayes_adjusted)[1]
))
# neuroquery
# needs size up -> do rescale
result_neuroquery<-as.matrix(c(
  calc_overlap(neuroquery>=3,bayes_adjusted)[1]
))
# merge
result95<-data.frame(result_bayes_meta,result_neurosynth,result_brainmap,result_neuroquery)
rownames(result95)<-c('bayes_adjusted_95')
colnames(result95)<-c('bayes_meta','neurosynth','brainmap','neuroquery')

results<-rbind(result80,result85,result90,result95)
