## ----echo=FALSE----------------------------------------------------------
set.seed(1125)


## ------------------------------------------------------------------------
tasmania <- read.csv("tasmania.csv") # load data
dim(tasmania) # check data dimension
names(tasmania[, 1:5]) # names of the first 5 columns
year <- tasmania[, 1]   # create a vector for year
s1   <- tasmania[, 2]   # create a vector for station 1 (Burnie)
s2   <- tasmania[, 3]   # create a vector for station 2 (Cape Grim)


## ------------------------------------------------------------------------
summary(s1) # 5-number summary plus sample mean
sd(s1)  # sample standard deviation
IQR(s1) # interquartile range
quantile(s1, type = 6) # sample percentiles using Type 6 approximations
quantile(s1, type = 7) # sample percentiles using Type 7 approximations
summary(s2)
sd(s2, na.rm = TRUE)
IQR(s2, na.rm = TRUE)


## ----fig.height=4.5, fig.width=6-----------------------------------------
hist(s1, freq = FALSE, xlab = "Extreme rainfall (Burnie, Tas)", col = 8)
smooth.density = density(s1)  # fits a smooth curve
lines(smooth.density, lty = 2, lwd = 2, col = 2)  # draws the curve


## ----fig.height=4, fig.width=6-------------------------------------------
boxplot(s1, s2, horizontal = TRUE, names = c("Burnie Is", "Cape Grim"),
        col = c("yellow", "orange"))


## ----fig.height=4, fig.width=6-------------------------------------------
ecdf1 <- ecdf(s1)
ecdf2 <- ecdf(s2)
plot(ecdf1)
plot(ecdf2, col = 2, add = TRUE)


## ----fig.height=4, fig.width=6-------------------------------------------
qqnorm(s1, main = "Normal QQ plot for S1")
qqline(s1)


## ----fig.height=4, fig.width=6-------------------------------------------
Finv <- function(p) {-log(-log(p))}  # quantile function
p <- (1:20) / 21
y <- sort(s1) # order statistics
x <- Finv(p)  # theoretical quantiles
plot(x, y, ylab = "Sample quantiles", xlab = "EV quantiles")
fit <- lm(y ~ x) # this computes the "line of best fit"
                 # (more details later in the semester)
abline(fit)  # this plots the "line of best fit"


## ----fig.keep="none"-----------------------------------------------------
dnorm(0)
dnorm(0) * sqrt(2 * pi)
dnorm(0, mean = 4, sd = 2)
dnorm(c(-1, 0, 1))
x <- seq(-20, 20, by = 0.1)
y <- dnorm(x)
plot(x, y)
y <- dnorm(x, mean = 2.5, sd = 0.5)
plot(x, y)


## ----fig.keep="none"-----------------------------------------------------
pnorm(0)  # lower tail probability (cdf)
pnorm(1)
pnorm(1, lower.tail = FALSE)  # upper tail probability
pnorm(0, mean = 2, sd = 3)
x <- seq(-20, 20, by = 0.1)
y <- pnorm(x)
plot(x, y)
y <- pnorm(x, mean = 3, sd = 4)
plot(x, y)


## ----fig.keep="none"-----------------------------------------------------
qnorm(c(0.25, 0.5, 0.75), mean = 1, sd = 2) # quartiles for N(1,2)
x <- seq(0, 1, by = 0.05)
y <- qnorm(x)
plot(x, y)
y <- qnorm(x, mean = 3, sd = 2)
plot(x, y)
y <- qnorm(x, mean = 3, sd = 0.1)
plot(x, y)


## ----fig.keep="none"-----------------------------------------------------
rnorm(4)
rnorm(4, mean = 3, sd = 3)
rnorm(4, mean = 3, sd = 3)
y <- rnorm(200)
hist(y)
y <- rnorm(200, mean = -2)
hist(y)
qqnorm(y)
qqline(y)


## ------------------------------------------------------------------------
mu.hat = mean(s1)
mu.hat
n = length(s1)
sigma.hat = sqrt((n - 1) * var(s1) / n)
sigma.hat


## ------------------------------------------------------------------------
library(MASS)

# Prepares the Gumbel pdf:
dgumbel <- function(x, mu, sigma)
    exp((mu - x) / sigma - exp((mu - x) / sigma)) / sigma
# Fits the Gumbel distribution
gumbel.fit <- fitdistr(x = s1, densfun = dgumbel,
                       start = list(mu = 50, sigma = 10))
gumbel.fit


## ------------------------------------------------------------------------
normal.fit <- fitdistr(x = s1, densfun = "normal")
normal.fit


## ------------------------------------------------------------------------
neg.llk <- function(theta) { # negative log-likelihood
    mu    <- theta[1]
    sigma <- theta[2]
    out   <- -sum(log(dgumbel(s1, mu, sigma)))
    return(out)
}
fit <- optim(c(50, 10), neg.llk) # fits MLEs
theta.hat <- fit$par # returns estimates
theta.hat


## ----fig.height=4, fig.width=6-------------------------------------------
# Write fitted normal and Gumbel pdfs
pdf1 <- function(x) dnorm(x, mean = mu.hat, sd = sigma.hat)
pdf2 <- function(x) dgumbel(x, mu = theta.hat[1], sigma = theta.hat[2])

# Plot data and fitted models
hist(s1, freq = FALSE, col = "gray", main = NULL, xlab = "x", xlim = c(0,100))
curve(pdf1, from = 0, to = 100, col = 2, lty = 2, lwd = 2, add = TRUE)
curve(pdf2, from = 0, to = 100, col = 1, lty = 1, lwd = 2, add = TRUE)


## ------------------------------------------------------------------------
x.bar  <- mean(s1)
x2.bar <- mean(s1^2)
a <- 0.577215
b <- 1.978
sigma.tilde <- sqrt((x2.bar - x.bar^2) / (b - a^2))
sigma.tilde
mu.tilde <- x.bar - a * sigma.tilde
mu.tilde

