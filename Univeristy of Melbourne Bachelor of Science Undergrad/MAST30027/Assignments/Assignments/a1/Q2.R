load("assign1.Robj")

oddFromP = function(p) {
  return(p / (1-p))
}
pFromOdd = function(o) {
  return(o / (1+o))
}
model = glm(cbind(test, 1-test)~bmi, data=pima_subset, family = binomial())

# Easily shown log odd is logit is g. Thus g(g-1(x\beta)) = x\beta
# log(o) = b0 + b1x
betahat = model$coefficients
(10 * betahat[2])

ilogit <- function(x) exp(x)/(1+exp(x))
phat <- ilogit(betahat[1] + pima_subset$bmi*betahat[2])
I11 <- sum(phat*(1 - phat))
I12 <- sum(pima_subset$bmi*phat*(1 - phat))
I22 <- sum(pima_subset$bmi^2*phat*(1 - phat))
Iinv <- solve(matrix(c(I11, I12, I12, I22), 2, 2))
alpha=0.05
# The constant term is zero, so it's ignored
10 * betahat[2] + qnorm(c(alpha/2, 1-alpha/2)) * sqrt(10^2 * diag(Iinv)[2])
