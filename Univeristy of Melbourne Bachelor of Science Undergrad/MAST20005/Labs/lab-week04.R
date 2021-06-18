## ----echo=FALSE----------------------------------------------------------
set.seed(2253)


## ------------------------------------------------------------------------
p <- c(0.9, 0.95, 0.975)
qnorm(p)


## ----eval=FALSE----------------------------------------------------------
## qnorm(p, 5, 3)


## ----eval=FALSE----------------------------------------------------------
## qt(p, 5)


## ----eval=FALSE----------------------------------------------------------
## qchisq(p, 1)


## ----eval=FALSE----------------------------------------------------------
## # your turn...


## ----eval=FALSE----------------------------------------------------------
## qf(p, 12, 4)


## ----echo=FALSE----------------------------------------------------------
PTweight <- read.table("PTweight.txt")

## ------------------------------------------------------------------------
x <- PTweight[1:5, 2]
n <- length(x)
x.bar <- mean(x)
s <- sd(x)
t <- qt(0.95, n - 1)
x.bar + c(-1, 1) * t * s / sqrt(n)


## ------------------------------------------------------------------------
t.test(x, conf.level = 0.90)


## ------------------------------------------------------------------------
y <- PTweight[6:10, 2]  # stress group data
y.bar <- mean(y)
s.p <- sqrt((4 * var(x) + 4 * var(y)) / 8)  # pooled sample sd
x.bar - y.bar + c(-1, 1) * qt(0.975, df = 8) * s.p * sqrt(1 / 5 + 1 / 5)


## ------------------------------------------------------------------------
t.test(x, y, var.equal = TRUE)


## ------------------------------------------------------------------------
var.test(x, y)


## ------------------------------------------------------------------------
lambda <- 10
B <- 1000  # simulation runs
n <- 10    # sample size
xbar <- 1:B  # we will collect results in these two vectors
s2   <- 1:B
for (b in 1:B) {  # repeat B times for b = 1,...,B
    x <- rpois(n, lambda)
    xbar[b] <- mean(x)  # compute and store X-bar
    s2[b]   <- var(x)   # compute and store S^2
}


## ------------------------------------------------------------------------
mean(xbar)
mean(s2)


## ------------------------------------------------------------------------
var(xbar)
var(s2)


## ------------------------------------------------------------------------
lambda / n
lambda * (2 * n * lambda + n - 1) / (n * (n - 1))


## ----fig.height=4, fig.width=6-------------------------------------------
boxplot(xbar, s2, names = c("X-bar", "S-squared"),
        col = "lightblue", horizontal = TRUE)

# Draw a dashed vertical line showing the true parameter value.
abline(v = lambda, lty = 2, lwd = 2, col = "magenta")


## ------------------------------------------------------------------------
invadopodia <- read.table("invadopodia.txt")
x1 <- invadopodia[invadopodia$Condition == 1, 2]
x2 <- invadopodia[invadopodia$Condition == 2, 2]
x.bar1 <- mean(x1)
x.bar2 <- mean(x2)


## ------------------------------------------------------------------------
# 95% CI for group 1.
x.bar1 + c(-1, 1) * 1.96 * sqrt(x.bar1 / length(x1))
# 95% CI for group 2.
x.bar2 + c(-1, 1) * 1.96 * sqrt(x.bar2 / length(x2))


## ------------------------------------------------------------------------
qnorm(0.95)   # use this to obtain a 90% CI
qnorm(0.995)  # use this to obtain a 99% CI


## ------------------------------------------------------------------------
# 95% CI for difference between groups 1 and 2.
x.bar1 - x.bar2 + c(-1, 1) * 1.96 *
    sqrt(x.bar1 / length(x1) + x.bar2 / length(x2))


## ------------------------------------------------------------------------
sample(c("tails", "heads"), 10, replace = TRUE)


## ------------------------------------------------------------------------
days <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
sample(days, 1)


## ------------------------------------------------------------------------
sample(c("tails", "heads"), 10, prob = c(0.2, 0.8), replace = TRUE)

