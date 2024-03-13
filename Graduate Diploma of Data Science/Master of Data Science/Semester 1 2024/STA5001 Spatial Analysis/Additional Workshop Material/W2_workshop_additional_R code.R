#############################
# Workshop 2
#############################

library(sp)
aucities <- read.table("au.csv", sep = ",", header=TRUE)
str(aucities)
aucities1 <- cbind(aucities$lat, aucities$lng)
row.names(aucities1) <- 1:nrow(aucities1)
str(aucities1)

llCRS <- CRS("+proj=longlat +ellps=WGS84")


df <- SpatialPoints(aucities1, proj4string=llCRS)
summary(df)
bbox(df)

sort(df$coords.x2)

l2lon <- which(df$coords.x2 %in% sort(df$coords.x2)[1:2])
l2lon
coordinates(df)[l2lon,]

plot(df)

df1 <- SpatialPointsDataFrame(aucities1, aucities, proj4string=llCRS, match.ID=TRUE)
str(df1)
summary(df1)


for (i in unique(df1$states)){
print(c(i,length(df1[df1$states==i,])))
}

summary(df1$population)

summary(df1[df1$states=="Victoria",]$population)


library(lattice)
proj4string(df1) <- CRS(as.character(NA))
spplot(df1, "population",do.log =T)
spplot(df1[df1$states=="Victoria",], "population",do.log =T)

df1$states <- as.factor(df1$states)
spplot(df1,"states")

df1$pop1M <- as.factor(df1$population > 10000)
spplot(df1, "pop1M",do.log =T)


