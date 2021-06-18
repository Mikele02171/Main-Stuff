library(ggplot2)

set.seed(30027)
x = rnorm(100, 5, 2)

# (b)

gibbs <- function(n, data, mu=1, tau=1) {
  samples = list(mu=numeric(n), tau=numeric(n));
  xbar = mean(data)
  m = length(data)
  
  for (i in 1:n) {
    mu = rnorm(1, xbar, sqrt(1/(m * tau)))
    tau = rgamma(1, m/2, sum((data-mu)^2)/2)
    
    samples$mu[i] = mu
    samples$tau[i] = tau
  }
  return(samples)
}

N = 2000
res1 = gibbs(N, x, 1000, 0.1)
res2 = gibbs(N, x, 0, 999)

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
