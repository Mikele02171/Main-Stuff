###########################################################################
# This code is a sample that shows how the nonzero.interval function, the #
#  density function, and the distribution function could be defined for   #
#  a uniform distribution. Recall that the uniform distribution has two   #
#  parameters, a and b, specifying the minimum and maximum value of the   #
#  random variable.                                                       # 
###########################################################################

nonzero.interval <- function(a,b) { 
  c(a,b) 
}

density <- function(x, a, b) {
  ifelse(a <= x & x <= b, 1/(b-a), 0)
}

# Note: for the uniform distribution, one can determine a formula for its
#  probability distribution function by calculating an integral. For your 
#  chosen distribution, this may not be possible, but you are permitted
#  to use the integrate function to perform the calculation numerically.
#  In that case, you may need to Vectorize your function.
distribution <- function(x, a, b) {
  ifelse(x < a, 0, ifelse(x <= b, (x-a)/(b-a), 1))
}

# Now I can generate random numbers using the generate function.

# The following will generate 15 random numbers from a U(-5,10) distribution:
generate(15, -5, 10)

# The following will generate 1000 random numbers from a U(1,7) distribution:
generate(1000, 1, 7)


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