## ----echo=FALSE----------------------------------------------------------
set.seed(2317)


## ----echo=TRUE-----------------------------------------------------------
62 + 5 - 7 * 9 + 15/3 - 2^2  # ^ means "to the power of"


## ----echo=TRUE-----------------------------------------------------------
2 + 3 / 4^3
2 + (3 / 4)^3


## ----echo=TRUE-----------------------------------------------------------
log(25)        # Logarithm of 25 using natural base e
sqrt(4)        # Square root of 4
pi * 4^2       # Area of a circle of radius 4
a <- pi * 4^2  # Create the variable "a"
a              # Print "a"


## ----echo=TRUE-----------------------------------------------------------
rm(list = ls())


## ----echo=TRUE-----------------------------------------------------------
x <- c(4.1, -1.3, 2.5, -0.6, -21.7)
x


## ----echo=TRUE-----------------------------------------------------------
x <- c(1, 3, 9, 10)
x
y <- c(30, 35, 4)
y
z <- c(x, y)
z


## ----echo=TRUE-----------------------------------------------------------
n <- 5
1:n - 1
1:(n - 1)


## ----echo=TRUE-----------------------------------------------------------
z[2]
z[1:4]
z[c(1, 2, 6)]
z[2] <- 2015


## ----echo=TRUE-----------------------------------------------------------
seq(1, 2, by = 0.1)
seq(1, 2, length.out = 20)


## ----echo=TRUE-----------------------------------------------------------
A <- matrix(c(2, -1, 4, 2, -1, 3), nrow = 2) # create a matrix
A


## ----echo=TRUE-----------------------------------------------------------
A[1, 2]   # extract the element in first 1st row and 2nd column
A[1, ]    # extract the first row
mean(A)   # sample average for all the elements


## ----echo=TRUE-----------------------------------------------------------
u1 <- c("male", "female")
u2 <- c("apple", "pear", "kiwi", "orange")
u1
u2


## ----echo=TRUE-----------------------------------------------------------
labels <- paste(c("X", "Y"), 1:10, sep = "")
labels


## ----echo=TRUE-----------------------------------------------------------
c(1, 2) + c(2, 5)


## ----echo=TRUE-----------------------------------------------------------
c(1, 2, 3) + c(2, 5)


## ----echo=TRUE-----------------------------------------------------------
1:5 + 3


## ----echo=TRUE-----------------------------------------------------------
mean(z)


## ----echo=TRUE-----------------------------------------------------------
z <- rnorm(10)  # generate a vector with 10 observations from N(0,1)
z


## ----echo=TRUE-----------------------------------------------------------
x <- rnorm(10, mean = 10, sd = 2)
x


## ----echo=TRUE, fig.height=4, fig.width=4--------------------------------
x <- rnorm(100, mean = 10, sd = 2)  # sample of size 100 from N(10, 4)
y <- rnorm(100, mean =  0, sd = 4)  # sample of size 100 from N(0, 16)
plot(x, y, xlab = "Name of variable x", ylab = "Name of variable y")


## ----echo=TRUE, fig.height=4, fig.width=4--------------------------------
boxplot(x, y, names = c("x", "y"))  # creates paired boxplots


## ----echo=TRUE, fig.height=4, fig.width=4--------------------------------
hist(x, freq = FALSE, nclass = 10)


## ----echo=TRUE-----------------------------------------------------------
qqnorm(x)
qqline(x)


## ----echo=TRUE-----------------------------------------------------------
x <- rnorm(100)                   # generate 3 vectors of length 100
y <-   2 * x + rnorm(100, 0, 0.8)
z <- 0.5 * x + rnorm(100, 0, 0.5)
t <- data.frame(x, y, z)          # create a data frame
summary(t$x)                      # summary statistics for x
plot(t)                           # scatter plot matrix


## ----echo=TRUE-----------------------------------------------------------
L <- list(one = 1, two = c(1, 2), five = seq(0, 1, length.out = 5))
L
L$five + 10


## ----echo=TRUE-----------------------------------------------------------
# Construct and store a simple data frame.
t <- data.frame(x = c(1, 2, 3), y = c(30, 20, 10))
t
write.table(t, file = "mydata.txt", row.names = FALSE) # save file
t2 <- read.table(file = "mydata.txt", header = TRUE)   # load file
t2


## ----echo=TRUE-----------------------------------------------------------
x <- c(rnorm(10), NA, rnorm(2))


## ----echo=TRUE-----------------------------------------------------------
min(x)


## ----echo=TRUE-----------------------------------------------------------
min(x, na.rm = TRUE)
mean(x, na.rm = TRUE)


## ----echo=TRUE-----------------------------------------------------------
x <- rnorm(10)


## ----echo=TRUE-----------------------------------------------------------
if (mean(x) > median(x)) {
    "The mean is greater than the median"
} else {
    "The mean is smaller than the median"
}


## ----echo=TRUE, fig.width=4, fig.height=4--------------------------------
B <- 1000                       # number of runs
n <- 5                          # sample size
xbar.seq <- 1:B                 # a vector of size to be filled with means
for (i in 1:B) {
    sample <- rnorm(5)
    xbar.seq[i] <- mean(sample)
}
hist(xbar.seq)                 # plot the results


## ----echo=TRUE, fig.width=4, fig.height=4--------------------------------
myfun <- function(x) {        # Specifies function name and argument
    y <- x^2                  # Specifies what the function should do
    return(y)                 # Returned value
}
myfun(1.5)                    # Computes 1.5^2
x <- seq(-2, 2, length.out = 100) # Plots the new function
plot(x, myfun(x), type = "l" )


## ----echo=TRUE-----------------------------------------------------------
mymedian <- function(x) {
    n <- length(x)
    m <- sort(x)[(n + 1) / 2]
    return(m)
}


## ----echo=TRUE-----------------------------------------------------------
mymedian <- function(x) {
    n <- length(x)
    if (n %% 2 == 1) { # odd
        med <- sort(x)[(n + 1) / 2]
    } else {   # even
        middletwo <- sort(x)[(n / 2) + 0:1]
        med <- mean(middletwo)
    }
    return(med)
}
x <- rnorm(10)
mymedian(x)
median(x)

