mammals <- read.csv("data/sleep.csv")
mammals$BodyWt <- log(mammals$BodyWt)
mammals$BrainWt <- log(mammals$BrainWt)

## Question 1
model <- lm(BrainWt ~ BodyWt, data=mammals)
summary(model)

# Plot
plot(mammals$BodyWt, mammals$BrainWt)
lines(mammals$BodyWt, model$fitted.values, col="red")
# Yes looks linear

plot(model, which=1) # Diagnostic plot
# Not enough to be problem, but slight trend toward negativity
plot(model, which=2)
# QQ plot looks reasonably linear
plot(model, which=3)
# No sign of heteroskesdasticitiy, no obvious trend which makes it difficult to correct
plot(model, which=5)
# Plot looks fine, no point with high cooks distance

## Question 2
n <- dim(mammals)[1]
p <- 2
X <- cbind(rep(1, n), mammals$BodyWt)
y <- mammals$BrainWt

# (a)
b <- solve(t(X) %*% X, t(X) %*% y)
model$coefficients

# (b)
e <- y - X %*% b
str(model$residuals)

# (c)
SSRes <- sum(e^2)
deviance(model)

# (d)
SSReg <- sum(y^2) - SSRes
sum(y^2) - SSRes

# (e)
s2 <- SSRes / (n-p)
deviance(model) / model$df.residual

# (f)
str(rstandard(model))

# (g)
str(lm.influence(model)$hat)

# (h)
str(cooks.distance(model))

# (i)
confint(model)

## Question 3
data <- data.frame(BodyWt = c(log(50)))
predict(model, data, interval="confidence", level=0.95)

## Question 4
data <- data.frame(BodyWt = c(log(50)))
predict(model, data, interval="prediction", level=0.95)

# To get the original value, just take exponential out of y -> e^result

## Question 5
n <- dim(mammals)[1]
p <- 2
X <- cbind(1, mammals$BodyWt)
b0 <- seq(1.8, 2.4, length=100)
b1 <- seq(0.65, 0.85, length=100)
f <- function(beta0, beta1) {
  f.out <- rep(0, length(beta0))
  for (i in 1:length(beta0)) {
    beta <- matrix(c(beta0[i], beta1[i]), 2, 1)
    f.out[i] <- t(as.matrix(model$coef) - beta) %*% t(X) %*% X %*% (as.matrix(model$coef)-beta)
  }
  return(f.out)
}
z <- outer(b0, b1, f)
contour(b0, b1, z, levels=2*(deviance(model)/ model$df.residual) * qf(0.95, 2, n-p))

## Question 6
# (a)
null <- lm(y ~ 0)
model <- lm(y ~ X[, 2])
anova(null, model)
# Reject null hypothesis

# (b)
null <- lm(y ~ 1)
anova(null, model)
# Reject null hypothesis

# (c)
null <- lm(y ~ 0 + X[, 2])
anova(null, model)
# Reject null hypothesis

# (d)
dst <- c(2, 1)
C <- diag(2)
library(car)
linearHypothesis(model, C, dst)
## Reject null hypothesis

## Question 7
mammals <- read.csv("data/sleep.csv")
hist(mammals$BrainWt, breaks=50)
hist(mammals$BodyWt, breaks=50)
# We see that both brain weight and body weight have extremely right skewed distributions. 
# This is one of the hallmark that we need to apply log transformation of the data
# In addition, both variables are constrained to be positive, another indication that a 
# logarithmic transformation may be required.

plot(log(mammals$BodyWt), log(mammals$BrainWt))
