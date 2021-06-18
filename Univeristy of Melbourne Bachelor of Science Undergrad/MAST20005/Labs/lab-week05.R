## ----echo=FALSE----------------------------------------------------------
set.seed(1153)


## ------------------------------------------------------------------------
n <- 20
p.hat <- 6 / n
p.hat
z0 <- qnorm(0.95)
p.hat + c(-1, 1) * z0 * sqrt(p.hat * (1 - p.hat) / n)


## ------------------------------------------------------------------------
num <- p.hat + z0^2 / (2 * n) +
       c(-1, 1) * z0 * sqrt(p.hat * (1 - p.hat) / n + z0^2 / (4 * n^2))
den <- 1 + z0^2 / n
num / den


## ------------------------------------------------------------------------
prop.test(x = 6, n = 20, conf.level = 0.90, correct = FALSE)


## ------------------------------------------------------------------------
t <- binom.test(x = 6, n = 20, conf.level = 0.90)
t
names(t)    # shows names of various objects returned by binom.test()
t$conf.int  # extracts the confidence interval


## ------------------------------------------------------------------------
p <- 0.3           # set the true proportion
n <- 15            # set number of trials
z0 <- qnorm(0.95)  # quantile for 90% confidence level
B <- 2500          # number of simulated samples

result1 <- result2 <- result3 <- 1:B  # empty vectors, to store results
for (b in 1:B) {
    y <- rbinom(1, size = n, prob = p) # generate a binomial outcome
    p.hat <- y / n  # sample proportion

    # Wald interval.
    int1 <- p.hat + c(-1, 1) * z0 * sqrt(p.hat * (1 - p.hat) / n)

    # Interval based on quadratic equation.
    num <- p.hat + z0^2 / (2 * n) +
           c(-1, 1) * z0 * sqrt(p.hat * (1 - p.hat) / n + z0^2 / (4 * n^2))
    den <- 1 + z0^2 / n
    int2 <- num / den

    # Clopper-Pearson "exact" interval.
    t <- binom.test(y, n, conf.level = 0.90)
    int3 <- t$conf.int

    # Check if p is in the intervals and store results.
    result1[b] <- (int1[1] < p) & (p < int1[2])
    result2[b] <- (int2[1] < p) & (p < int2[2])
    result3[b] <- (int3[1] < p) & (p < int3[2])
}


## ------------------------------------------------------------------------
mean(result1)  # coverage Wald CI
mean(result2)  # coverage quadratic CI
mean(result3)  # coverage Clopper-Pearson CI


## ----fig.height=4.5------------------------------------------------------
library(binom)
p <- seq(0, 1, 0.001)
coverage.wald    <- binom.coverage(p, 25, method = "asymptotic")$coverage
coverage.agresti <- binom.coverage(p, 25, method = "agresti-coull")$coverage
plot( p, coverage.wald, type = "l", ylab = "coverage")
lines(p, coverage.agresti, col = "blue", lwd = 2)
abline(h = 0.95, col = "red") # desired coverage


## ------------------------------------------------------------------------
prop.test(x = c(141, 170), n = c(460, 440), correct = FALSE)


## ------------------------------------------------------------------------
prop.test(x = c(141, 170), n = c(460, 440),
          alternative = "less", correct = FALSE)

