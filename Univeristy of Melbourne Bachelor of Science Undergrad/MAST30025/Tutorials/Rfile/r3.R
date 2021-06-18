## Question 1
# input
x.values <- seq(-2, 2, by=0.1)

n <- length(x.values)
y.values <- rep(0, n)
for (i in 1:n) {
  x <- x.values[i]
  
  if (x <= 0) {
    y <- -x^3
  }
  else if (x <= 1) {
    y <- x^2
  }
  else {
    y <- sqrt(x)
  }
  
  y.values[i] <- y
}

## Question 2
x <- 0.8
n <- 10
h <- 0

for (i in 0:10) {
  h <- h + x^i  
}

print(h)

## Question 3
func_h <- function(x, n) {
  h <- 0
  
  # Do like exercise 2
  if (x == 1) {
    for (i in 0:n) {
      h <- h + x^i  
    }
  }
  # Otherwise do the close formula
  else {
    h <- (1-x^(n+1))/ (1-x)
  }
  
  return(h)
}

## Question 4
# Using a while loop
h <- 0
i <- 0
n <- 10
x <- 0.8
while (i <= n) {
  h <- h+x^i
  i <- i+1
}

print(h)

# vectorised
h <- sum(x^(0:n))
print(h)

## Question 5
x.old <- matrix(c(1, 0), 2, 1)
theta <- pi/4
A <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), 2, 2)
x.new <- A %*% x.old

## Question 6
# Using for loop
x <- c(2, 1, 3, 5, 1 ,3)
x.length <- length(x)
mult <- 1

for (i in (1:x.length)) {
  mult <- mult * x[i]  
}

print(mult^(1/x.length))

# Vectorised
mg <- prod(x) ^ (1/length(x))
mg

## Question 7
x <- rep(FALSE, 100)
for (i in 1:100) {
  for (j in seq(i, 100, i)) {
    x[j] <- !x[j]
  }
}

which(x)
