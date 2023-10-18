####################################################################
# In the blank space below, write the code to define the functions #
#  specified in the description of the task.                       # 
####################################################################



#################################################
#   DO NOT MODIFY ANYTHING BELOW THIS LINE!!!   #
#################################################

quantile <- Vectorize(function(p, ...) {
  interval <- nonzero.interval(...)
  objective <- function(x) { (distribution(x, ...) - p)^2 }
  optimise(objective, interval=c(interval[1], interval[2]))$minimum
})

generate <- function(n, ...) {
  uniform <- runif(n) 
  quantile(uniform, ...)
}
