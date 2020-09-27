# correcting Cauchy prior based on effect size and proportion of predicted positives
# inputs: contrast, noise (standard deviation, etc.), proportion of positives, percentile (e.g., .9? .95?)
# precision (default = 1e-9), max iterations (default = 10000)
# output: corrected Cauchy prior

# function to find
f <- function(x){
  # pcauchy
  # ES should be defined globally
  # percentile should also be defined globally
  fx<-pcauchy(ES,scale=x)-percentile
  return(c(fx))
}

adjust_cauchy_scale<-function(contrast, noise, proportion, percentile = .9, precision = 1e-9, max_iter=10000)
{
  # calculate average ES
  ES <<- contrast / noise * proportion
  # put percentile in global
  percentile<<-percentile
  # numerically estimate scale
  # from 0 to 100, start from 50
  now <- 50
  from <- 0
  to <- 100
  iteration<-0
  while(1){
    iteration <- iteration + 1
    # calculate pcauchy with the current scale
    current <- f(now)
    # difference?
    if (abs(current) <= precision){
      # within the boundary of the allowed precision. Stop
      break
    }
    # if not, then move for 1/2
    # if difference < 0, it indicates that the scale should increase
    if (current >0){
      from<-now
      now <- (now + to)/2
      
    }else{
      # else, then the scale should decrease
      to<-now
      now <- (from + now)/2
      
    }
    # if iteration > max_iteration, stop
    if (iteration >= max_iter){
      break
    }
  }
  # return iteration # and result
  # if convergence failed then return -1
  if (iteration >= max_iter){
    return (-1)
  }else{
    return(now)
  }
}