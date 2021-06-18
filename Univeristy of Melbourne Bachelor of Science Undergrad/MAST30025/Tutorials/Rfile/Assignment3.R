## Question 2
# Part (a)
y = c(43, 45, 47, 46, 48, 33, 37, 38, 35, 56, 54, 57)
X = matrix(c(rep(1, 12), rep(1,5), rep(0, 7), rep(0, 5), rep(1, 4), rep(0, 3), rep(0, 9), rep(1, 3)), 12, 4)
XTX = t(X) %*% X

XTXc <- matrix(0, 4, 4)
XTXc[2:4, 2:4] = t(solve(XTX[2:4, 2:4]))
XTXc <- t(XTXc)
XTXc

# Verify AACA = A
round(XTX %*% XTXc %*% XTX, 2)

# Part (b)
XTY <- t(X) %*% y
b <- XTXc %*% XTY 
b

# Part (c)
t <- c(4, 2, 1, 1)
t %*% XTXc %*% XTX
# Yes, it is estimable

# Part (d)
t_d <- c(1, 1, 0, 0)
s2 <- sum((y-X%*%b)^2) / 9
t_d %*% b + c(-1, 1) * qt(0.975, 12 - 3) * sqrt(s2) * sqrt(1 + t(t_d) %*% XTXc %*% t_d)

# Part (e)
c<-matrix(c(0,0,1,-1), 1, 4)
m<-qr(c)$rank
num<-t(c%*%b)%*%solve(c%*%XTXc%*%t(c))%*%(c%*%b)/m
den<-s2
fstat<-num/den
fstat
pf(fstat,m,12-3, lower=F)
