# Integrate X images from X = x to xmax
# For BFs, Means, and Medians

library("oro.nifti")
integrate_result<-function(filename_list = 'mask.nii', start = 0){
  # To get a header, read one original file in the list (First item)
  # Read filelist
 # data<-read.csv(filename_list)
 # filecount <-nrow(data)
  
  # Get the first file
 # filename <- toString(data[1,1])
  # Read the current nifti
  Img <- readNIfTI(filename_list)
  # Extract current image data
  ImgData = oro.nifti::img_data(Img)
  
  XX = dim(ImgData)[1]
  YY = dim(ImgData)[2]
  ZZ = dim(ImgData)[3]
  
  # Start with BFs.
  for (i in 1:XX){
  	filename <- sprintf("./output_%d/BF_%d.Rdata",start,i)
  	# Read the current RData.
  	load (file =filename)
  	# Attach current BFs
  	for (j in 1:YY){
  		for (k in 1:ZZ){
  			ImgData[i,j,k] = BF_current[j,k]
  		}
  	}
  }
  
  # set data type
  datatype(Img)<-64
  bitpix(Img)<-64
  

  # Write BFs.nii
  # Set Image data
  oro.nifti::img_data(Img)<-ImgData
  writeNIfTI(Img,sprintf("BFs_%d",start),gzipped = FALSE)


  # thresholding
  for (i in 1:XX){
    for (j in 1:YY){
      for (k in 1:ZZ){
        if ((ImgData[i,j,k]>=3)&&!(is.na(ImgData[i,j,k]))){
        ImgData[i,j,k] = 1.0}else{
          ImgData[i,j,k] = 0.0
        }
      }
    }
  }


  # thresholded image BF > 3
  oro.nifti::img_data(Img)<-ImgData
  writeNIfTI(Img,sprintf("bf3_%s_%d",'05',start),gzipped = FALSE)
  
  # Then, Ds
  for (i in 1:XX){
  	filename <- sprintf("./output_%d/D_%d.Rdata",start,i)
  	# Read the current RData.
  	load (file =filename)
  	# Attach current Mean
  	for (j in 1:YY){
  		for (k in 1:ZZ){
  			ImgData[i,j,k] = D_current[j,k]
  		}
  	}
  }
  
  
  # Write Ds.nii
  # Set Image data
  oro.nifti::img_data(Img)<-ImgData
  writeNIfTI(Img,sprintf("Ds_%d",start),gzipped = FALSE)
  
  # done
  return(1)
}