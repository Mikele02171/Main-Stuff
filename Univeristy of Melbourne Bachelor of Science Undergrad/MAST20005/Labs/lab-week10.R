## ----echo=FALSE----------------------------------------------------------
set.seed(2331)


## ----fig.width=6, fig.height=3.5-----------------------------------------
theta <- 0.5
x1.simulated <- numeric(1000)  # initialise an empty vector
for (i in 1:1000) {
    x <- runif(3, theta - 0.5, theta + 0.5)
    x1.simulated[i] <- min(x)
}

g <- function(x)
    3 * (1 - x)^2

hist(x1.simulated, breaks = 20, freq = FALSE, col = "lightblue",
     xlim = c(0, 1), ylim = c(0, g(0)),
     main = NULL, xlab = expression(x[(1)]))
curve(g, from = 0, to = 1, add = TRUE, col = "blue", lwd = 2)


## ------------------------------------------------------------------------
w.simulated <- matrix(nrow = 100, ncol = 3)  # initialise an empty matrix
for (i in 1:100) {
    x <- runif(3, theta - 0.5, theta + 0.5)
    x <- sort(x)
    w1 <- mean(x)
    w2 <- x[2]
    w3 <- (x[1] + x[3]) / 2
    w  <- c(w1, w2, w3)
    w.simulated[i, ] <- w
}


## ------------------------------------------------------------------------
# Compute `mean` and `var` for each column of `w.simulated`.
means <- apply(w.simulated, 2, mean)
vars  <- apply(w.simulated, 2, var )
means
vars


## ------------------------------------------------------------------------
# CI for E(W1).
means[1] + c(-1, 1) * qnorm(0.975) * sqrt(vars[1]) / sqrt(100)


## ------------------------------------------------------------------------
qbinom(c(0.025, 0.975), 11, 0.5)


## ------------------------------------------------------------------------
pbinom(8, 11, 0.5) - pbinom(1, 11, 0.5)


## ------------------------------------------------------------------------
f <- function() {
    X <- runif(11)
    Y <- sort(X)
    c(Y[2], Y[9])
}
f()  # try it out


## ----fig.height=3.5, fig.width=6-----------------------------------------
nsimulations <- 100
C <- t(replicate(nsimulations, f()))
matplot(C, type = "l", xlab = "Simulated sample", ylab = "CI")
abline(c(0.5, 0), lty = 2, col = "darkgrey")
mean((C[, 1] < 0.5) & (0.5 < C[, 2]))


## ------------------------------------------------------------------------
x <- rcauchy(25, location = 5)
x


## ------------------------------------------------------------------------
x.bar <- mean(x)
x.bar
x.bar.tr <- mean(x, trim = 0.35)  # exclude 35% of observations from each tail
x.bar.tr


## ------------------------------------------------------------------------
B <- 1000
x.bar.boot    <- numeric(B)
x.bar.tr.boot <- numeric(B)
for (i in 1:B) {
    x.ast <- sample(x, size = 25, replace = TRUE)
    x.bar.boot[i]    <- mean(x.ast)
    x.bar.tr.boot[i] <- mean(x.ast, trim = 0.35)
}


## ----fig.width=6, fig.height=8.2-----------------------------------------
xlim <- range(x.bar.boot, x.bar.tr.boot)
ylim <- c(0, 0.7)
par(mfrow = c(2, 1), mar = c(5.1, 4.1, 1, 1))
hist(x.bar.boot, xlab = expression(bar(X)), freq = FALSE,
     xlim = xlim, ylim = ylim, col = "lightblue", main = NULL)
hist(x.bar.tr.boot, xlab = expression(bar(X)[tr]), freq = FALSE,
     xlim = xlim, ylim = ylim, col = "lightblue", main = NULL)


## ------------------------------------------------------------------------
quantile(x.bar.tr.boot, c(0.025, 0.975))


## ----fig.width=6, fig.height=4-------------------------------------------
x <- faithful$waiting
mean(x)
hist(x, col = "lightblue")


## ----fig.width=6, fig.height=5-------------------------------------------
B <- 10000
x.bar.boot <- numeric(B)
for (i in 1:B) {
    x.ast <- sample(x, replace = TRUE)
    x.bar.boot[i] <- mean(x.ast)
}
hist(x.bar.boot, xlab = expression(bar(X)), freq = FALSE,
     col = "lightblue", main = NULL)


## ------------------------------------------------------------------------
quantile(x.bar.boot, c(0.025, 0.975))

