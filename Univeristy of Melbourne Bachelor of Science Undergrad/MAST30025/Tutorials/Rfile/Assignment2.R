# Assignment 2
y <- c(5.5, 5.9, 6.5, 5.9, 8.0, 9.0, 10.0, 10.8)
X <- cbind(rep(1, length(y)), c(7.2, 10.0, 9.0, 5.5, 9.0, 9.8, 14.5, 8.0), c(8.7, 9.4, 10, 9, 12, 11, 12, 13.7), c(5.5, 4.4, 4.0, 7, 5, 6.2, 5.8, 3.9))
n <- length(y)
p <- dim(X)[2]

# (a)
b <- solve(t(X) %*% X, t(X) %*% y)
s2 <- sum((y-X%*%b)^2) / (n-p)
print(b)
print(s2)
# (b)
XTX.inverse <- solve(t(X) %*% X) # sigma2 >= 0
# b0 and b3 and  have the highest covariance

# (c)
t <- c(1, 8, 9, 5)
t(t) %*% b + c(-1, 1) * qt(0.995, df=n-p) * sqrt(s2) * sqrt(t %*% solve(t(X) %*% X) %*% t)

# (d)
# 90% Prediction interval
t(t) %*% b + c(-1, 1) * qt(0.95, df=n-p) * sqrt(s2) * sqrt(1 + t %*% solve(t(X) %*% X) %*% t)
pt(2.131847, n-p)

# (e)
# Testing corrected sum of square
H <- X %*% solve(t(X) %*% X) %*% t(X)
SSReg <- t(y) %*% H %*% y
SSRes <- sum((y-X%*%b)^2)

numerator <- (SSReg - (sum(y))^2 / n) / (p-1)
denominator <- SSRes / (n-p)
fvalue <- numerator / denominator
pf(fvalue, p-1, n-p, lower=F)

# Reject H0 if we assume alpha = 0.05

## To check using R
model <- lm (y ~ X[,-1])
summary(model)

## Question 5
cost <- c(7.2, 10, 9, 5.5, 9, 9.8, 14.5, 8)
unemployment.rate <- c(8.7, 9.4, 10.0, 9.0, 12.0, 11.0, 12.0, 13.7)
interest.rate <- c(5.5, 4.4, 4.0, 7, 5, 6.2, 5.8, 3.9)
y <- c(5.5, 5.9, 6.5, 5.9, 8, 9, 10, 10.8)

lambda <- 0.5
# We scaled every predictor variable
cost <- scale(cost, center=TRUE, scale=TRUE)
unemployment.rate <- scale(unemployment.rate, center=TRUE, scale=TRUE)
interest.rate <- scale(interest.rate, center=TRUE, scale=TRUE)

y <- scale(y, center=TRUE, scale=FALSE)
X <- cbind(cost, unemployment.rate, interest.rate)

# Calculate b
b <- solve(t(X) %*% X + lambda * diag(3)) %*% t(X) %*% y

# (c)
lambdas <- c()
AICs <- c()
n <- 8
for (lambda in seq(0, 10, by=0.1)) {
  df <- sum(diag(X %*% solve(t(X) %*% X + lambda * diag(3)) %*% t(X)))
  b <- solve(t(X) %*% X + lambda * diag(3)) %*% t(X) %*% y
  SSRes <- sum((y - X %*% b)^2)
  AIC <- n * log(SSRes/n) + 2 * df
  lambdas <- c(lambdas, lambda)
  AICs <- c(AICs, AIC)
}

plot(AICs, lambdas)

## Question Four
# legendary transformation
data(state)
statedata <- data.frame(state.x77, row.names=state.abb, check.names=TRUE)
pairs(statedata)
statedata$Murder <- log((statedata$Murder))
statedata$Illiteracy <- (statedata$Illiteracy)
statedata$Area <- log(statedata$Area)
statedata$Population <- statedata$Population
pairs(statedata)

# legendary legendary transformation
data(state)
statedata <- data.frame(state.x77, row.names=state.abb, check.names=TRUE)
statedata$Population <- log(statedata$Population)
statedata$Income <- log(statedata$Income)
statedata$HS.Grad <- log(statedata$HS.Grad)
statedata$Area <- log(statedata$Area)
pairs(statedata)

model <- lm(Murder ~ Population + Income + Illiteracy + Life.Exp + HS.Grad + Frost + Area, data=statedata)
plot(model, which=3)





