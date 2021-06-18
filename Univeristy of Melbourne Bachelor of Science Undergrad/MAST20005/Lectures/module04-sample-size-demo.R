# Statistics (MAST20005) & Elements of Statistics (MAST90058)
# Semester 2, 2020
#
# Module 4
#
# Showing the relationship between accuracy and sample size for estimating a
# proportion.


# Calculates the margin of error (half the width) of a confidence interval for
# estimating a proportion.
epsilon <- function(n, p.hat = 0.5, conf.level = 0.95) {
    z <- qnorm((1 - conf.level) / 2, lower.tail = FALSE)
    z * sqrt(p.hat * (1 - p.hat) / n)
}

# Draws a curve showing the relationship between the sample size and the margin
# of error for estimating a proportion.
makePlot <- function() {
    par(mar = c(5.1, 5.1, 4.1, 2))  # custom margins to make ylab fit properly
    curve(epsilon,
          from = 50,
          to   = 3000,
          xlim = c(0, 3000),
          ylim = c(0, 0.14),
          lwd  = 3,
          col  = "blue",
          main = "Uncertainty when estimating a proportion",
          xlab = "Sample size (n)",
          ylab = expression("Margin of error (" * epsilon * ")"))
    grid(lty = 1)
}

# Actually draw the plot.
makePlot()
