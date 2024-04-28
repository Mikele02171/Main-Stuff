#############################
# Workshop 2
#############################

#############################
# Question 1
#############################

library(gstat)
library(geoR)
library(sp)
library(spatstat)

a<-as.data.frame(sic.100$data)
s<- SpatialPointsDataFrame(sic.100$coords, a, proj4string=CRS(projargs=as.character(NA)), match.ID=TRUE)
bin1 <- variog(sic.100)
ols1.n <- variofit(bin1, ini = c(15000,50), nugget=0, weights="equal", cov.model = "gauss")
plot(bin1)
lines(ols1.n, lwd = 2)

v.fit<-as.vgm.variomodel(ols1.n)

m1 <- sapply(1:100, function(x) mean(krige(sic.100.data~1, s[-x,], s, v.fit)$var1.var))
which(m1 == min(m1))
plot(sort(m1))

which(m1 %in% sort(m1)[1:5])

range(sic.100$coords[,1])
range(sic.100$coords[,2])

max(sic.100$coords[,1])

myppp <- ppp(sic.100$coords[,1], sic.100$coords[,2], c(29.52739, 320.9114),  c(19.36854, 217.05655))

marks(myppp)<-m1
myppp
summary(myppp)
plot(myppp)

#############################
# Question 2
#############################

library(spatstat)
par(mfrow=c(1,2))
a<-runif(4,min = 0, max = 10)
a
lambda1 <- function(x, y) {50*as.numeric((abs(x -a[1])<1) & (abs(y -a[2])<1))}
plot(rpoispp(lambda1, win=owin(c(0,10),c(0,10))))

lambda1 <- function(x, y) {50*as.numeric((abs(x -a[3])<1) & (abs(y -a[4])<1))}
plot(rpoispp(lambda1, win=owin(c(0,10),c(0,10))),add=TRUE)

a<-runif(4,min = 0, max = 10)
a
lambda1 <- function(x, y) {50*as.numeric((abs(x -a[1])<1) & (abs(y -a[2])<1))}
plot(rpoispp(lambda1, win=owin(c(0,10),c(0,10))))

lambda1 <- function(x, y) {50*as.numeric((abs(x -a[3])<1) & (abs(y -a[4])<1))}
plot(rpoispp(lambda1, win=owin(c(0,10),c(0,10))),add=TRUE)


#############################
# Question 3
#############################
library(spatstat)
mydata <- read.csv("Covid.csv")
str(mydata)
mydata <- mydata[,c("Latitude", "Longitude")]
head(mydata)
str(mydata)

range(mydata$Longitude)
range(mydata$Latitude)

myppp <- ppp(mydata$Longitude, mydata$Latitude, c(141.3923, 148.4656),  c(-38.65969, -34.18713))

plot(myppp)
summary(myppp)
lamb <- summary(myppp)$intensity
lamb

quadratcount(myppp, nx = 6, ny = 3)
Q <- quadratcount(myppp, nx = 6, ny = 3)
plot(myppp, cex = 0.5, pch = "+")
plot(Q, add = TRUE, cex = 2)

den <- density(myppp, sigma = 1)
plot(den)
plot(myppp, add = TRUE, cex = 0.5)

contour(den)
plot(myppp, add = TRUE, cex = 0.5)


KS <- cdf.test(myppp, function(x, y) {x})
plot(KS)
pval <- KS$p.value
pval

KS <- cdf.test(myppp, function(x, y) {y})
plot(KS)
pval <- KS$p.value
pval


a<-rpoispp(lamb,  win=owin(c(141.3923, 148.4656),  c(-38.65969, -34.18713)))
a
plot(a)

KS <- cdf.test(a, function(x, y) {x})
plot(KS)
pval <- KS$p.value
pval

KS <- cdf.test(a, function(x, y) {y})
plot(KS)
pval <- KS$p.value
pval
