## Question 1
y <- c(8, 15, 16, 20, 25, 40)
X <- cbind(rep(1, 6), c(8, 12, 14, 16, 16, 20))

# (a) Confidence interval for the model parameter
n <- 6
p <- 2
b <- solve(t(X) %*% X, t(X) %*% y)
c <- solve(t(X) %*% X)
SSRes <- sum((y - X %*% b)^2)
s2 <- SSRes / (n-p)
s <- sqrt(s2)

# CI
b[1] + c(-1, 1) * qt(0.975, n-p) * sqrt(s2 * c[1, 1]) # intercept term
b[2] + c(-1, 1) * qt(0.975, n-p) * sqrt(s2 * c[2, 2]) # beta 1 term

income <- data.frame(income=y, education=X[, 2])
model <- lm(income ~ education, data=income)
confint(model, level=0.95)

# (b)
xst <- c(1, 18)
xst %*% b + c(-1, 1) * qt(0.975, n-p) * sqrt(t(xst) %*% c %*% xst) * s

person <- data.frame(education=18)
predict(model, person, interval="confidence", level=0.95)

# (c)
xst %*% b + c(-1, 1) * qt(0.975, n-p) * sqrt(1 + t(xst) %*% c %*% xst) * s
predict(model, person, interval="prediction", level=0.95)

## Question 3
n <- 30
x <- 1:n
y <- x + rnorm(30)

model <- lm(y ~ x)
newdata <- data.frame(x=x)
CI_u <- predict(model, newdata, interval="confidence", level=0.95)[, 3]
CI_l <- predict(model, newdata, interval="confidence", level=0.95)[, 2]
PI_u <- predict(model, newdata, interval="prediction", level=0.95)[, 3]
PI_l <- predict(model, newdata, interval="prediction", level=0.95)[, 2]
plot(x, y)
lines(x, CI_u, col="blue")
lines(x, CI_l, col="blue")
lines(x, PI_u, col="red")
lines(x, PI_l, col="red")

# We expect around 5% of y to lie beyond PI's

## Question 5
set.seed(3)
X <- cbind(rep(1, 100), 1:100)
beta <- c(0, 1)
y <- X %*% beta + rnorm(100)

# Partition
Xfit <- X[1:50,]
yfit <- y[1:50]
Xtest <- X[51:100,]
ytest <- y[51:100]

# (a)
betafit <- solve(t(Xfit) %*% Xfit, t(Xfit) %*% yfit)
SSfit <- sum((yfit - Xfit %*% betafit)^2)
print(SSfit)

SStest <- sum((ytest - Xtest %*% betafit) ^2)
print(SStest)

X <- cbind(X, matrix(runif(1000), 100, 10))
Xtest <- X[51:100,]
Xfit <- X[1:50,]

betafit <- solve(t(Xfit) %*% Xfit, t(Xfit) %*% yfit)
SSfit <- sum((yfit - Xfit %*% betafit)^2)
print(SSfit)

SStest <- sum((ytest - Xtest %*% betafit) ^2)
print(SStest)

# With the training data, we can match some of the noise using the new predictor variables
# However, this is of no use when applied to the test data, as there is nos systematic
# relationship between the noise and the new variables

# (b)
X <- cbind(X[, 1:2], (1:100)^2, (1:100)^2, (1:100)^3, (1:100)^4)
Xfit <- X[1:50,]
Xtest <- X[51:100,]

betafit <- solve(t(Xfit) %*% Xfit, t(Xfit) %*% yfit)
SSfit <- sum((yfit - Xfit %*% betafit)^2)
print(SSfit)

SStest <- sum((ytest - Xtest %*% betafit) ^2)
print(SStest)
