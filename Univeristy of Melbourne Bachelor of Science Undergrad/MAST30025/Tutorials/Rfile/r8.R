library(MASS)
library(Matrix)

## Question Five
# (a)
data <- read.csv("data/filters.csv")
str(data)
data$type <- factor(data$type)

# (b)
# Contains of 5 treatment levels, one way anova, 6 each
y <- data$life
X <- matrix(0, 30, 6)
X[, 1] <- 1
for (i in 1:5) {
  X[data$type==i, i+1] = 1
}

# (c)
XTX <- t(X) %*% X
rankMatrix(t(X) %*% X)[1]
XTXc <- matrix(0, 6, 6)
M <- XTX[1:5, 1:5]
M.inv <- solve(M)
M.inv
XTXc[1:5, 1:5] <- t(M.inv)
XTXc <- t(XTXc)

# (d)
XTXc2 <- ginv(t(X) %*% X)
XTXc2
X %*% XTXc2 %*% t(X)

# (e)
X %*% XTXc %*% t(X)

X %*% XTXc2 %*% t(X)

# (f)
b <- XTXc2 %*% t(X) %*% y
