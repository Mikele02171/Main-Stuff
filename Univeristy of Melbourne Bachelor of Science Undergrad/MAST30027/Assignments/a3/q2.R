## (c)
h.me <- function(x, c, d) {
  return(d * (1 + c * x)^3)
}

g.me <- function(x, c, d) {
  return(
    d * log((1 + c * x) ^ 3) - d * (1 + c * x)^3 + d
  );
}


f.star.me <- function(x, alpha) {
  d = alpha - 1/3;
  c = 1 / sqrt(9 * d);
  h.prime.me <- function(x) {
    return(3 * d * c * (1 + c * x) ^ 2)
  }
  return(
    h.me(x, c, d) ^ (alpha - 1) * exp(-h.me(x, c, d))* h.prime.me(x)
  );
}

yange.star.me <- function(x, alpha) {
  d = alpha - 1/3;
  c = 1 / sqrt(9 * d);
  return(
    exp(
      g.me(x, c, d)
    )
  )
}

ratio.comp <- function(alpha) {
  return(f.star.me(1, alpha) / yange.star.me(1, alpha))
}

h.star.me <- function(x) {
  return(exp(-x^2/2));
}

rgamma.me_ <- function(alpha=1, beta=1) {
  ratio = ratio.comp(alpha)
  d = alpha - 1/3;
  c = 1 / sqrt(9 * d);
  while (TRUE) {
    x = rnorm(1);
    y = runif(1);
    if (x > -1/c && y < f.star.me(x, alpha) / (h.star.me(x) * ratio)) {
      break;
    }
  }
  return(h.me(x, c, d)/beta);
}

rgamma.me <- function(n, alpha=1, beta=1) {
  return(replicate(n, rgamma.me_(alpha, beta)))
}

plot(qgamma(1:1000/1001, 1.2, 3), sort(rgamma.me(1000, 1.2, 3)),
     xlab="Gamma Quantile", ylab="gamma.me Quantile", cex.lab=0.7)
abline(0, 1, col="red")