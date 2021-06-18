# Statistics (MAST20005) & Elements of Statistics (MAST90058)
# Semester 2, 2020
#
# Module 7
#
# Poisson distribution example, in more detail.


X <- c(7, 4, 3, 6,  4, 4, 5, 3, 5,  3, 5, 5, 3, 2, 5, 4, 3, 3, 7, 6,
       6, 4, 3, 9, 11, 6, 7, 4, 5,  4, 7, 3, 2, 8, 6, 7, 4, 1, 9, 8,
       4, 8, 9, 3,  9, 7, 7, 9, 3, 10)
table(X)
n <- length(X)
X.bar <- mean(X)

dpois(0:11, X.bar)
ppois(11, X.bar)

X1 <- cut(X, breaks = c(0, 3.5, 4.5, 5.5, 6.5, 7.5, Inf))
T1 <- table(X1)
x <- as.numeric(T1)

p <- c(ppois(3, X.bar), dpois(4:7, X.bar), 1 - ppois(7, X.bar))

chisq.test(x, p = p)
