# Statistics (MAST20005) & Elements of Statistics (MAST90058)
# Semester 2, 2020
#
# Module 1
#
# Demonstration and further explanation of QQ plots.


## Exploring QQ plots.

# 'Wrong' theoretical distribution, small sample size.
x <- rgamma(20, 3, 0.5)
qqnorm(x, pch = 19, col = 4)
qqline(x, col = 2)

# 'Wrong' theoretical distribution, large sample size.
x <- rgamma(50, 3, 0.5)
qqnorm(x, pch = 19, col = 4)
qqline(x, col = 2)

# Correct theoretical distribution, small sample size.
x <- rnorm(20)
qqnorm(x, pch = 19, col = 4)
qqline(x, col = 2)

# Correct theoretical distribution, large sample size.
x <- rnorm(50)
qqnorm(x, pch = 19, col = 4)
qqline(x, col = 2)


## How a QQ plot relates to the empirical CDF.

# Generate some data (n.b. not from a normal distribution).
x <- rt(25, df = 10)

# The usual empirical CDF, with hypothesised theoretical CDF.
plot(ecdf(x))
curve(pnorm, col = 2, add = TRUE)

# Re-do the empirical CDF, using Type 6 quantiles.
plot(sort(x), (1:25)/26, pch = 19, ylim = c(0, 1))
abline(h = c(0, 1), col = 8, lty = 2)
curve(pnorm, col = 2, add = TRUE)

# Now transform the y-axis
#  => makes reference CDF a straight line
#  => this is just a QQ plot!
plot(sort(x), qnorm((1:25) / 26), pch = 19)
abline(0, 1, col = 2)
