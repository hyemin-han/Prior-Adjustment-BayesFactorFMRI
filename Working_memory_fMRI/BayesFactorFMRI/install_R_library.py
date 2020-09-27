# for anaconda

from rpy2.robjects.packages import importr
utils = importr('utils')
# oro.nifti
utils.install_packages('oro.nifti')
# BayesFactor
utils.install_packages('BayesFactor')