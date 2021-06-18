## ----echo=FALSE----------------------------------------------------------
set.seed(1409)


## ----results="hide", fig.keep="none"-------------------------------------
data  <- read.table("corn.txt", header = TRUE)
Corn  <- factor(data[, 1])
Yield <- data[, 2]
Corn
table(Corn)
Yield
tapply(Yield, list(Corn), mean)  # group means
boxplot(Yield ~ Corn)


## ----results="hide", fig.keep="none"-------------------------------------
m1 <- lm(Yield ~ Corn)
qqnorm(residuals(m1))
summary(m1)
anova(m1)


## ----results="hide"------------------------------------------------------
pairwise.t.test(Yield, Corn, pool.sd = FALSE, p.adjust.method = "none")


## ----results="hide"------------------------------------------------------
t.test(Yield[Corn == 1], Yield[Corn == 3])


## ----results="hide"------------------------------------------------------
x <- rnorm(5)
y <- rnorm(5)
test.result <- t.test(x, y, var.equal = TRUE)
names(test.result)


## ----results="hide"------------------------------------------------------
test.result$statistic


## ------------------------------------------------------------------------
ts <- replicate(1000,
                t.test(rnorm(5), rnorm(5), var.equal = TRUE)$statistic)


## ----fig.width=6, fig.height=4-------------------------------------------
hist(ts, freq = FALSE, nclass = 25, col = "grey", ylim = c(0, 0.4),
     xlab = "T statistic", ylab = "Density")  # histogram
lines(density(ts), lty = 2, lwd = 2)     # smooth density estimate
curve(dt(x, df = 8), from = -4.5, to = 4.5, add = TRUE,
      col = "red", type = "l", lwd = 2)  # theoretical density


## ----fig.width=4.5, fig.height=4.5---------------------------------------
qqplot(ts, rt(1000, df = 8), col = 4,
       xlab = "Test statistics",
       ylab = "Theoretical t-distribution (simulated)")
abline(0, 1)


## ------------------------------------------------------------------------
probs <- c(0.9, 0.95, 0.99)
quantile(ts, probs)
qt(probs, df = 8)


## ----fig.width=8, fig.height=4-------------------------------------------
pvals.welch <- replicate(1000, t.test(rnorm(10), rnorm(10))$p.value)
pvals.ttest <- replicate(1000, t.test(rnorm(10), rnorm(10),
                                     var.equal = TRUE)$p.value)
par(mfrow = c(1, 2))
hist(pvals.welch, freq = FALSE, col = 8, xlab = "p-values", main = "Welch")
hist(pvals.ttest, freq = FALSE, col = 8, xlab = "p-values", main = "Pooled")


## ------------------------------------------------------------------------
probs <- c(0.5, 0.7, 0.9, 0.95, 0.99)
quantile(pvals.welch, probs)
quantile(pvals.ttest, probs)


## ----fig.width=8, fig.height=4-------------------------------------------
pvals.welch <- replicate(1000, t.test(rnorm(10), rnorm(10, 1))$p.value)
pvals.ttest <- replicate(1000, t.test(rnorm(10), rnorm(10, 1),
                                      var.equal = TRUE)$p.value)
par(mfrow = c(1, 2))
hist(pvals.welch, freq = FALSE, col = 8, xlab = "p-values", main = "Welch")
hist(pvals.ttest, freq = FALSE, col = 8, xlab = "p-values", main = "Pooled")


## ------------------------------------------------------------------------
quantile(pvals.welch, probs)
quantile(pvals.ttest, probs)


## ------------------------------------------------------------------------
B <- 1000                            # number of simulation runs
R <- 50                              # number of power values
n <- 5                               # sample sizes
delta.seq <- seq(-3, 3, length = R)  # sequence of true differences
power.t <- numeric(R)                # initialize power vectors
power.w <- numeric(R)

for (i in 1:R) {
  delta <- delta.seq[i]

  # Simulate B p-values for each test.
  pvals.t <- replicate(B, t.test(rnorm(n), rnorm(n, delta),
                                 var.equal = TRUE)$p.value)
  pvals.w <- replicate(B, wilcox.test(rnorm(n), rnorm(n, delta),
                                      exact = FALSE)$p.value)

  # Record the estimated power (proportion of rejections).
  power.t[i] <- mean(pvals.t < 0.05)
  power.w[i] <- mean(pvals.w < 0.05)
}


## ----fig.width=6, fig.height=4-------------------------------------------
# Plot simulated power for t- and Wilcoxon tests.
plot(delta.seq, power.t, type = "l", ylim = c(0, 1),
     ylab = "Power", xlab = expression(delta))
lines(delta.seq, power.w, lty = 2, col = 2)
abline(v = 0, lty = 3)

