# Statistics (MAST20005) & Elements of Statistics (MAST90058)
# Semester 2, 2020
#
# Module 3
#
# Demonstration of important distributions.


# Help pages.
help("Chisquare")
help("TDist")
help("FDist")

# Another way to get help pages.
?dchisq
?dt
?df

# Chi-squared distribution.
plot(NULL, type = "n",
     xlab = "x", ylab = "f(x)", main = "Chi-squared distribution",
     xlim = c(0, 10), ylim = c(0, 1))
curve(dchisq(x, df = 1), 0, 10, add = TRUE, lwd = 2, col = 1)
curve(dchisq(x, df = 2), 0, 10, add = TRUE, lwd = 2, col = 2)
curve(dchisq(x, df = 5), 0, 10, add = TRUE, lwd = 2, col = 3)
curve(dchisq(x, df = 8), 0, 10, add = TRUE, lwd = 2, col = 4)

# t-distribution.
plot(NULL, type = "n",
     xlab = "x", ylab = "f(x)", main = "t-distribution",
     xlim = c(-4, 4), ylim = c(0, 0.4))
curve(dt(x, df = 1), -4, 4, add = TRUE, lwd = 2, col = 1)
curve(dt(x, df = 2), -4, 4, add = TRUE, lwd = 2, col = 2)
curve(dt(x, df = 5), -4, 4, add = TRUE, lwd = 2, col = 3)
curve(dt(x, df = 8), -4, 4, add = TRUE, lwd = 2, col = 4)
curve(dnorm(x), -4, 4, add = TRUE, lty = 2, lwd = 2, col = 6)

# F-distribution.
#
# Try it out yourself...
# 
# The R function for the pdf is `df()`
