## ----echo=FALSE----------------------------------------------------------
set.seed(1938)


## ----eval=FALSE----------------------------------------------------------
## install.packages("foreign")


## ----results="hide"------------------------------------------------------
library(foreign)
cdata <- read.dta("crime.dta")
summary(cdata)


## ------------------------------------------------------------------------
plot(cdata[, -c(1, 2)])


## ----eval=FALSE----------------------------------------------------------
## plot(log(cdata[, -c(1, 2)]))


## ----eval=FALSE----------------------------------------------------------
## cor(cdata[, -c(1, 2)])


## ------------------------------------------------------------------------
round(100 * cor(cdata[, -c(1, 2)]))


## ------------------------------------------------------------------------
m1 <- lm(crime ~ single, data = cdata) # fit model (compute estimates)
summary(m1)  # show results


## ------------------------------------------------------------------------
confint(m1)


## ------------------------------------------------------------------------
newdata <- data.frame(single = 11.5)
predict(m1, newdata, interval = "confidence")


## ------------------------------------------------------------------------
predict(m1, newdata, interval = "prediction")


## ------------------------------------------------------------------------
n <- nrow(cdata) # sample size
RSS <- sum(m1$residuals^2) # extract, square and sum the residuals
sqrt(RSS / n)  # MLE


## ----fig.width=8, fig.height=4-------------------------------------------
par(mfrow = c(1, 2))  # set up a 1*2 array for drawing plots
plot(m1, 1:2)  # this will draw 2 plots, filling up the 1*2 array


## ------------------------------------------------------------------------
cdata[c(9, 25, 51),]


## ------------------------------------------------------------------------
y <- cdata$crime
sd(y)


## ------------------------------------------------------------------------
m0 <- lm(crime ~ 1, data = cdata)
summary(m0)


## ------------------------------------------------------------------------
TSS <- sum((y - mean(y))^2)
1 - sum(RSS / TSS)


## ----results="hide"------------------------------------------------------
m2 <- lm(crime ~ poverty, data = cdata)
summary(m2)


## ------------------------------------------------------------------------
library(MASS)
m3 <- rlm(crime ~ single, data = cdata)
summary(m3)


## ------------------------------------------------------------------------
hweights <- data.frame(state  = cdata$state,
                       resid  = m3$resid,
                       weight = m3$w)
hweights2 <- hweights[order(m3$w), ]
hweights2[1:15, ]

