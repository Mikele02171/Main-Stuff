# Load data
library(faraway)
data(orings)

## (a)
# Define functions
probit = pnorm     # Link
logLoss = function(beta, orings) {
  eta = cbind(1, orings$temp) %*% beta
  p = probit(eta)
  return(-sum(orings$damage * log(p/(1-p)) + 6 * log(1 - p)))
}

# fit parameters
# Initialiise with the parameter used on class
betahat = optim(c(10, -0.1), logLoss, orings=orings)
(betahat.loss = betahat$value)
(betahat = betahat$par)
plot(damage/6 ~ temp, orings, xlim=c(25,85), ylim=c(0,1),
     xlab="Temperature", ylab="Prob of damage")
x <- seq(25,85,1)
lines(x, probit(betahat[1] + betahat[2]*x), col="red")

## (b)
dnorm.deriv = function(eta) {
  return(- 1/sqrt(2*pi) * exp(-eta^2/2) * eta)
}

information = function(beta, orings) {
  finfo = 0
  for (i in 1:dim(orings)[1]) {
    xi = c(1, orings$temp[i])
    yi = orings$damage[i]
    eta = xi %*% beta
    eyi = 6 * probit(eta)
    part.1 = eyi * ((dnorm.deriv(eta)*pnorm(eta)-dnorm(eta)^2)/pnorm(eta)^2)[1]
    part.2 = -(6 - eyi) * ((dnorm.deriv(eta)*(1-pnorm(eta))+dnorm(eta)^2) / (1-pnorm(eta))^2)[1]
    finfo.i = -(part.1 + part.2)[1] * matrix(xi, nrow=2) %*% matrix(xi, nrow=1)
    finfo = finfo + finfo.i
  }
  return(finfo)
}

fisher.info.est = information(betahat, orings)
alpha = 0.05
betahat[1] + qnorm(c(alpha/2, 1-alpha/2)) * sqrt(diag(solve(fisher.info.est))[1])
betahat[2] + qnorm(c(alpha/2, 1-alpha/2)) * sqrt(diag(solve(fisher.info.est))[2])

## (c)
# Make model without temperature
# As the model will just be p = g-1(beta1) which is a constant not related to xi
# We can simply do a MLE
logLossMLE = function(beta, orings) {
  eta = beta
  p = probit(eta)
  return(-sum(orings$damage * log(p/(1-p)) + 6 * log(1 - p)))
}
betahat.null = optimise(logLossMLE, c(-5, 1), orings=orings, maximum=FALSE)
(betahat.null.loss = betahat.null$objective)
(betahat.null = betahat.null$minimum)
# Now compute the likelihood ratio test
lr = 2 * betahat.null.loss - 2 * betahat.loss
(p.value = pchisq(lr, df=1, lower.tail = FALSE))
# p value <<<<<<< 0.05 so we reject null hypothesis.

## (d)
xnew = c(1, 31)
etanew = xnew %*% betahat
# Point estimate
ynew = probit(etanew)
# CI estiamte
probit(etanew[1] + qnorm(c(alpha/2, 1-alpha/2)) * sqrt(xnew %*% solve(fisher.info.est) %*% xnew)[1])

## (e)
library(ggplot2)
xs = seq(from=30, to=90, length.out=500)
ps.probit = probit(cbind(1, xs) %*% betahat)
model = glm(cbind(damage,6-damage) ~ temp, data=orings, family = binomial())
ps.logit = predict(model, newdata=data.frame(temp=xs), type="response")
(ggplot()
  +geom_line(data = data.frame(xs=xs, ps=ps.probit), aes(x=xs, y=ps, col="blue"))
  +geom_line(data = data.frame(xs=xs, ps=ps.logit), aes(x=xs, y=ps, col="red"))
  +scale_color_discrete(name="P-hat values", labels = c("probit link", "logit link"))
  +geom_point(data = orings, aes(x=temp, y=damage/6)))

