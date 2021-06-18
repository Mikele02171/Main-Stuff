library(MASS)
data(quine)

## (a)
mle_p <- function(data, r=1.5) {
  return(
    sum(data) / (length(data) * r + sum(data))
  )
}
(mle_p(quine$Days))

## (b)
bayesian_p.basic <- function(data, r=1.5, a=0.5, b=0.5) {
  return(
    c(sum(data)+a, length(data) * r+b)
  )
}
(alp = (bayesian_p.basic(quine$Days))[1])
(bet = (bayesian_p.basic(quine$Days))[2])
(e_bayesian = alp / (alp + bet))
