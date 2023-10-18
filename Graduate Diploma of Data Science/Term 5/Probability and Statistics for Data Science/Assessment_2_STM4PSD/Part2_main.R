---
  title: "part2_main"
output: word_document
date: "2023-10-14"
---
## Computing the nonzero-interval.
## Distribution, I have chosen for PART II, the beta distribution.
nonzero.interval <- function(x1,x2) { 
  c(0,1)
}

## Computing the density (or PDF)  of the Beta Distribution in R.
## gamma() in R computes the gamma function 

density <- function(x,a,b) {
  if (a <= x & x <= b) {
    return(gamma(a+b)*x^(a-1)*(1-x)^(b-1)/(gamma(a)*gamma(b)))
  } else {
    return(0)
  }
}

f <- Vectorize(density)

## Computing the distribution in R in other words
# Computing the cdf of the beta distribution 
distribution <- function(x,a,b) {
  if (x<a) {
    return(0)
  } else if (x<=b) {
    return(integrate(f,lower = -Inf, upper = Inf)$value)
  } else {
    return(1)
  }
}

#Expected value function in R for the Beta Distribution.

expected_value <- function(a,b){
  ifelse(a>0 & b>0, a/(a+b),0)
  
}


#Variance value function in R for the Beta Distribution.

variance <- function(a,b){
  b/((a+b)^2*(a+b+1))
}


#quantile function computed in R.
quantile <- Vectorize(function(p,a,b) {
  interval <- nonzero.interval(a,b)
  objective <- function(x) {(distribution(x,a,b) - p)^2 }
  optimise(objective, interval=c(interval[1], interval[2]))$minimum
})

# Now I can generate random numbers using the generate function to
# randomly generate 
generate <- function(n,a,b) {
  beta <- rbeta(n,a,b) 
  quantile(beta,a,b)
}



#Here we are generating some values from the beta distribution in R. 
generate(1000,2,2)
generate(1000,1,3)


#Here we are computing the following expectations for the Beta Distributions in R
expected_value(2,2)
expected_value(1,3)
#[1] 0.50
#[1] 0.25

#Here we are computing the following variances for the Beta Distributions in R
variance(2,2)
variance(1,3)

#[1] 0.0250
#[1] 0.0375

#Plotting the pdf of the Beta Distribution in R using alpha 2 and beta 2  
#define range
p = seq(0, 1, length=100)

#create plot of Beta distribution with shape parameters 2 and 2
plot(p, dbeta(p, 2, 2), type='l')




#Plotting the beta density distribution in R using alpha 1 and beta 3.
#define range
p = seq(0, 1, length=100)

#create plot of Beta distribution with shape parameters 1 and 3.
plot(p, dbeta(p, 1, 3), type='l')




#Creating the beta distribution density in R with parameters alpha=1 and beta = 3

# Specify x-values for pbeta function
x_pbeta <- seq(0, 1, by = 0.025)      

# Apply pbeta() function
y_pbeta <- pbeta(x_pbeta, shape1 = 1, shape2 = 3)  

# Plot pbeta values
plot(y_pbeta)



#Creating the beta distribution density in R with parameters alpha=2 and beta = 2

# Specify x-values for pbeta function
x_pbeta <- seq(0, 1, by = 0.025)      

# Apply pbeta() function
y_pbeta <- pbeta(x_pbeta, shape1 = 2, shape2 = 2)  

# Plot pbeta values
plot(y_pbeta)

