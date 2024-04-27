#############################
# Workshop 2
#############################

#############################
# Question 1
#############################

library(geoR)
str(Ksat)
summary(Ksat)
plot(Ksat)
par(mfrow = c(2,2))
points(Ksat, xlab = "Coord X", ylab = "Coord Y")
points(Ksat, xlab = "Coord X", ylab = "Coord Y", pt.divide = "rank.prop")
points(Ksat, xlab = "Coord X", ylab = "Coord Y", cex.max = 1.7, col = gray(seq(1, 0.1, l=100)), pt.divide = "equal")
points(Ksat, pt.divide = "quintile", xlab = "Coord X", ylab = "Coord Y")

cloud1 <- variog(Ksat, option = "cloud", max.dist=10)
cloud2 <- variog(Ksat, option = "cloud", estimator.type = "modulus", max.dist=10)
bin1 <- variog(Ksat, uvec=seq(0,10,l=11))
bin2  <- variog(Ksat, uvec=seq(0,10,l=11), estimator.type= "modulus")

par(mfrow=c(2,2))
plot(cloud1, main = "classical estimator")
plot(cloud2, main = "modulus estimator")
plot(bin1, main = "classical estimator")
plot(bin2, main = "modulus estimator")

dev.off()
plot(bin1)
lines.variomodel(cov.model = "power", cov.pars = c(0.6,0.6), nugget = 0, max.dist = 10,  lwd = 3)
legend(7, 0.5, c("power", "empirical"), lty=c(1,0), lwd = c(3,1), pch=c(NA,1))

vario90 <- variog(Ksat, max.dist = 10, direction=pi/2)
plot(vario90)
title(main = expression(paste("directional, angle = ", 90 )))

vario.4 <- variog4(Ksat, max.dist = 10)
plot(vario.4, lwd=2)

Ksat$coords[,1]
names(Ksat)
fit <- lm(Ksat$data ~ I(Ksat$coords[,1]^2) + I(Ksat$coords[,2]^2) + I(Ksat$coords[,1] * Ksat$coords[,2]) + Ksat$coords[,1] + Ksat$coords[,2])
fit


par(mfrow=c(1,2))
Ksat1 <- Ksat
Ksat1$data <- predict(fit,Ksat) - mean(predict(fit,Ksat))
points(Ksat1, xlab = "Coord X", ylab = "Coord Y", cex.max = 1.7, col = gray(seq(1, 0.1, l=100)), pt.divide = "equal")

Ksat1$data <- residuals(fit)
points(Ksat1, xlab = "Coord X", ylab = "Coord Y", cex.max = 1.7, col = gray(seq(1, 0.1, l=100)), pt.divide = "equal")

#############################
# Question 2
#############################
par(mfrow=c(1,3))
plot(0:2, 0:2, type="n")
for (i in 1:10) {
  lines.variomodel(cov.model = "exp", cov.pars = c(i*0.1,0.3), nugget = 0, max.dist = 2,  lwd = 3)
}


plot(0:2, 0:2, type="n")
for (i in 1:10) {
  lines.variomodel(cov.model = "exp", cov.pars = c(1, i*0.1), nugget = 0, max.dist = 2,  lwd = 3)
}

plot(0:2, 0:2, type="n")
for (i in 1:10) {
  lines.variomodel(cov.model = "exp", cov.pars = c(1, 0.3), nugget = i*0.1, max.dist = 2,  lwd = 3)
}

