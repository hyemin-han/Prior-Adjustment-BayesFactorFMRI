# import oro.nifti

library("oro.nifti")
library(tools)

# create 0 vs 1 map
# process NaN -> 0
create_binary_map<-function(ImgData){
  # get size
  XX = dim(ImgData)[1]
  YY = dim(ImgData)[2]
  ZZ = dim(ImgData)[3]
  
  # loop
  for (i in 1:XX){
    for (j in 1:YY){
      for (k in 1:ZZ){
        # 0 or 1?
        # NaN
        if (is.na(ImgData[i,j,k])){
          ImgData[i,j,k]<-0
        }else{
          # > 0?
          if (ImgData[i,j,k]>0){
            ImgData[i,j,k]<-1
          }else{
            # 0
            ImgData[i,j,k]<-0
          }
        }
      }
    }
  }
  
  # return
  return(ImgData)
}

# create noise added image
# ImgData and SD: what is the strength of the noise in SD scale
add_noise<-function(ImgData,SD){
  # get size
  XX = dim(ImgData)[1]
  YY = dim(ImgData)[2]
  ZZ = dim(ImgData)[3]
  count <- XX * YY * ZZ
  # add noise vector
  ImgData<-ImgData+rnorm(count,sd=SD)
  # return
  return(ImgData)
}

# get image header
# before load_image
# load image
load_image_n<-function(filename){
  # deal with non-nifti (hdr, img)
  if (file_ext(filename)=='nii'){
    Img <- readNIfTI(filename)
  }else{
    Img<-readANALYZE(filename)
    Img<-dropImageDimension(Img)
    Img<-as.nifti(Img)
    # deal with minus one
    for(i in 1:length(pixdim(Img))){
      if (pixdim(Img)[i]<0){
        pixdim(Img)[i]<-pixdim(Img)[i]*-1
      }
    }
    # save nifti copy for the future
    write_image(Img,oro.nifti::img_data(Img),file_path_sans_ext(filename))
  }
  return(Img)
}

# get image
get_image_n<-function(Img){
  # load image and then return matrix
  ImgData = oro.nifti::img_data(Img)
  return(ImgData)
}

# write image
# header is needed
write_image<-function(Img,ImgData,filename){
  # Set Image data
  oro.nifti::img_data(Img)<-ImgData
  # to double
  oro.nifti::datatype(Img)<-64
  oro.nifti::bitpix(Img)<-64
  writeNIfTI(Img,filename,gzipped = FALSE)
  
  # done
  return(1)
}

# create N of noise images
# original file, directory, N, SD
create_noise_images<-function(original_filename,directory='.',N,SD){
  # open the original file
  Img<-load_image_n(original_filename)
  ImgData<-get_image_n(Img)
  # binary image
  ImgData<-create_binary_map(ImgData)
  
  # loop
  for (i in 1:N){
    # create noised image
    noised_image<-add_noise(ImgData,SD)
    # save in the designated folder
    file_now<-sprintf('%s//%d',directory,i)
    # write file
    write_image(Img,noised_image,file_now)
  }
  
  # done
  return(1)
}