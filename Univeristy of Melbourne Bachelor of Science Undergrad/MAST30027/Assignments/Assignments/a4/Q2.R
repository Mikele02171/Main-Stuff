library(ggplot2)

set.seed(30027)
x = rnorm(100, 5, 2)

logpiparam <- function(mu, tau, data) {
  prior = log(1 / tau)
  likelihood = sum(dnorm(data, mu, sqrt(1/tau),log = TRUE))
  return(prior + likelihood)
}


mh <- function(n, data, mu=1, tau=1) {
  samples = list(mu=numeric(n), tau=numeric(n));
  xbar = mean(data)
  m = length(data)
  
  for (i in 1:n) {
    while (TRUE) {
      mu_  = rnorm(1, mu, sqrt(tau))
      tau_ = rgamma(1, 5*tau, 5)
      qtop = dnorm(mu, mu_, sqrt(tau_), log = TRUE) + dgamma(tau, 5*tau_, 5, log = TRUE)
      qbot = dnorm(mu_, mu, sqrt(tau), log = TRUE) + dgamma(tau_, 5*tau, 5, log = TRUE)
      p = exp(qtop + logpiparam(mu_, tau_, data) - (qbot + logpiparam(mu, tau, data)))
      if (p > runif(1)) {
        mu = mu_
        tau = tau_
        break
      }
    }
    
    samples$mu[i] = mu
    samples$tau[i] = tau
  }
  return(samples)
}

N = 2000
res1 = mh(N, x, 0.1, 10)
res2 = mh(N, x, 10, 0.1)

df = data.frame(x = 1:N, mu1=res1$mu, tau1=res1$tau, mu2=res2$mu, tau2=res2$tau)

(ggplot(df, aes(x)) + geom_line(aes(y=mu1), colour="red", alpha=0.8) + 
  geom_line(aes(y=mu2), colour="green", alpha=0.8) + 
  xlab('iteration') + ylab('mu')+ggtitle('trace plot:mu'))


(ggplot(df, aes(x)) + geom_line(aes(y=tau1), colour="red", alpha=0.8) + 
  geom_line(aes(y=tau2), colour="green", alpha=0.8) + 
  xlab('iteration') + ylab('tau')+ggtitle('trace plot:tau'))

# (c)
mu = sort(df$mu1[c(500:length(df$mu1))])
tau = sort(df$tau1[c(500:length(df$tau1))])

hist(mu, probability = TRUE)
(mean(mu))
quantile(mu, c(0.05,0.95))

hist(tau, probability = TRUE)
(mean(tau))
quantile(tau, c(0.05,0.95))
