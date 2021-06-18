# Statistics (MAST20005) & Elements of Statistics (MAST90058)
# Semester 2, 2020
#
# Module 5
#
# Visualising the variability in estimates for a linear regression model.


# Set the random seed, for reproducibility.
set.seed(20180823)

# Parameters.
K <- 20  # no. datasets to simulate
n <- 10  # sample size for each dataset
a <- 1   # true intercept
b <- 2   # true slope
s <- 1   # true standard deviation

# Run simulations.
x <- runif(n, 1, 5)
L <- vector("list", K)
for (k in seq_len(K)) {
    # Simulate dataset.
    y <- rnorm(n, a + b * x, s)

    # Fit model.
    l <- lm(y ~ x)

    # Add to list.
    L[[k]] <- l
}

# Set up a 1x2 grid for plots.
par(mfrow = c(1, 2))

# Plot a single dataset and model fit.
plot(x, y, col = "blue", pch = 20, cex = 2, main = "Single dataset")
abline(a, b, col = "red", lwd = 5)  # true model
abline(l, col = "blue", lwd = 2)

# Plot many model fits (on different datasets).
plot(x, y, type = "n", main = "All datasets (fitted models only)")
abline(a, b, col = "red", lwd = 5)  # true model
for (k in seq_len(K))
    abline(L[[k]], col = "darkgrey")
