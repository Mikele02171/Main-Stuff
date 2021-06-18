## ----echo=FALSE----------------------------------------------------------
set.seed(1528)


## ----fig.height=3--------------------------------------------------------
a <- 1
b <- 1
y <- 8
n <- 20
theta <- seq(0, 1, 0.01)
prior     <- dbeta(theta, a, b)
posterior <- dbeta(theta, a + y, b + n - y)
par(mar = c(4, 4, 1, 1))  # tighter margins
plot(theta, posterior, type = "l", lwd = 2, col = "blue",
     xlab = expression(theta),
     ylab = expression(f(theta)))
points(theta, prior, type = "l", lty = 2, lwd = 2, col = "red")


## ------------------------------------------------------------------------
(a + y) / (a + b + n)


## ------------------------------------------------------------------------
qbeta(c(0.025, 0.975), a + y, b + n - y)


## ------------------------------------------------------------------------
sample.p <- rbeta(1000, a + y, b + n - y)
mean(sample.p / (1 - sample.p))


## ----message=FALSE, fig.height=4-----------------------------------------
library(Bolstad)
par(mar = c(4, 4, 1, 1))  # tighter margins
binobp(8, 20, 5, 5, plot = TRUE)


## ------------------------------------------------------------------------
theta <- 0.1 # true parameter
n <- 20      # sample size
a <- 2       # prior parameter (alpha)
b <- 2       # prior parameter (beta)
nsim <- 1000 # number of simulations

# Simulate data.
y <- rbinom(nsim, size = n, prob = theta)

# Calculate limits for credible interval.
l1 <- qbeta(0.025, a + y, b + n - y)
u1 <- qbeta(0.975, a + y, b + n - y)

# Calculate limits for confidence interval.
p.tilde <- (y + 2) / (n + 4)
se <- sqrt(p.tilde * (1 - p.tilde) / n)
l2 <- p.tilde - 1.96 * se
u2 <- p.tilde + 1.96 * se

# Calculate coverage probabilities.
mean(l1 < theta & theta < u1)
mean(l2 < theta & theta < u2)


## ------------------------------------------------------------------------
post.mean <- 7.87   # posterior mean
post.mean
post.sd <- 64.5 / sqrt(240)  # posterior standard deviation
post.sd
qnorm(c(0.025, 0.975), post.mean, post.sd)


## ------------------------------------------------------------------------
7.87 + c(-1, 1) * 1.96 * 64.5 / sqrt(240)


## ----fig.height=3--------------------------------------------------------
A <- rnorm(100, 7.87, 17.35)
B <- rnorm(100, 7.87, 17.35)
C <- rnorm(100, 7.87, 17.35)
D <- rnorm(100, 7.87, 17.35)
par(mar = c(4, 4, 1, 1))  # tighter margins
boxplot(A, B, C, D, horizontal = TRUE, col = "lightblue")


## ----fig.height=3--------------------------------------------------------
y.bar <- c(28, 8, -3, 7)
se2 <- c(15, 10, 16, 11)
theta.0 <- rep( 7.87, 4)
sigma.0 <- rep(17.35, 4)
post.means <- (sigma.0^2 / (sigma.0^2 + se2)) * y.bar +
              (      se2 / (sigma.0^2 + se2)) * theta.0
post.sd <- sqrt(sigma.0^2 * se2 / (sigma.0^2 + se2))
A <- rnorm(100, post.means[1], post.sd[1])
B <- rnorm(100, post.means[2], post.sd[2])
C <- rnorm(100, post.means[3], post.sd[3])
D <- rnorm(100, post.means[4], post.sd[4])
par(mar = c(4, 4, 1, 1))  # tighter margins
boxplot(A, B, C, D, horizontal = TRUE, col = "lightblue")


## ----fig.width=6, fig.height=5-------------------------------------------
O2 <- c(0.47, 0.75, 0.83, 0.98, 1.18, 1.29, 1.40, 1.60, 1.75, 1.90, 2.23)
HR <- c(94, 96, 94, 95, 104, 106, 108, 113, 115, 121, 131)
plot(HR, O2, xlab = "Heart Rate", ylab = "Oxygen uptake (Percent)")
x <- HR - mean(HR)
y <- O2
coef(summary(lm(y ~ x)))  # usual regression fit


## ------------------------------------------------------------------------
bayes.lin.reg(y = O2, x = HR, slope.prior = "flat", intcpt.prior = "flat")


## ------------------------------------------------------------------------
bayes.lin.reg(O2, HR, slope.prior = "n", intcpt.prior = "n",
              ma0 = 1.2, mb0 = 0.04, sa0 = 0.05, sb0 = 0.005)

