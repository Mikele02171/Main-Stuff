## QUESTION 1
x <- 123
a <- 1.1
b <- 1.2

z <- x^a^b
z <- (x^a)^b
z <- 3*x^3 + 2*x^2 + 6*x + 1
x.sub <- x %% 100
z <- z + 1

## QUESTION 2
v1 <- c(1:8, 7:1)
v2 <- rep(1:5, 1:5)
mat1 <- matrix(1, 3, 3) - diag(3)
mat2 <- matrix(c(0, 0, 7, 2, 5, 0, 3, 0 ,0), 3, 3)

## QUESTION 4
x <- 1:100
idx <- (x %% 2 != 0) & (x %% 3 != 0) & (x %% 7 != 0)
x[idx]

## QUESTION 5
queue <- c("S", "R", "A", "L")
queue <- c(queue, "B")
queue <- queue[-1]
queue <- c("P", queue)
queue <- queue <- queue[(queue != "B" & queue != "A")]
which(queue == "R")

## QUESTION 6
rm(list=ls())
x <- 1
x[3] <- 3
y <- c()
y[2] <- 2
y[3] <- y[1]
z[1] <- 0

## QUESTION 7
ID <- 5*diag(10)
ID

