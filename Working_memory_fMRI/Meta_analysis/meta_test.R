# play with meta-analysis

# import functions for getting images
source('eval_performance.R')

# load BF image
BFs<-get_image('BFs.nii')
# load ES image
Means<-get_image('Means.nii')

# image size
img_size<-sum(!is.na(BFs)&abs(BFs)>0)

# thresholding
BF6<-BFs>=exp(3) & BFs>0 & Means > 0
BF0<-!(BFs>=exp(3) & BFs>0 & Means > 0)

# thresholded mean map
Means_t <- Means * BF6 
# the rese ES
Means_r <- Means * BF0
# zero to nan
Means_t<-replace(Means_t,Means_t==0,NaN)
Means_r<-replace(Means_r,Means_r==0,NaN)
Means_o<-replace(Means,abs(BFs)==0,NaN)
# contrast value
Contrast<-mean(Means_t,na.rm=TRUE)-mean(Means_r,na.rm=TRUE)
# sd
SD <- sd(Means_o,na.rm=TRUE)
# proportion
proportion<-sum(BF6)/sum(!is.na(BFs)&abs(BFs)>0)
