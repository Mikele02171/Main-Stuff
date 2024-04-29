library(sp)
library(spacetime)
library(gstat)
library(rgdal)
data(air)
data(DE_RB_2005)
str(DE_RB_2005)

smplDays <- as.integer(c(1,2, 50,51, 100, 150, 203, 360))

DE_NUTS1 <- spTransform(DE_NUTS1, CRS("+init=epsg:32632"))

stplot(as(DE_RB_2005[,smplDays],"STFDF"),
       col.regions=bpy.colors(120)[-(1:20)],
       sp.layout = list("sp.polygons", DE_NUTS1), scales=list(draw=F), 
       key.space="right", colorkey=TRUE, 
       main=NULL)

rural <- STFDF(stations, dates, data.frame(PM10 = as.vector(air)))
rr <- rural[,"2005::2010"]
unsel <- which(apply(as(rr, "xts"), 2, function(x) all(is.na(x))))
r5to10 <- rr[-unsel,]
vv <- variogram(PM10~1, r5to10, width=20, cutoff = 200, tlags=0:5)

plot(vv)
plot(vv,map=F) 
plot(vv,wireframe=T)

separableModel0 <- vgmST("separable", 
                         space=vgm(0.9,"Exp", 150, 0.1),
                         time =vgm(0.9,"Sph", 3, 0.1),
                         sill=40, temporalUnit="days")

separableModel01<-fit.StVariogram(vv, separableModel0, fit.method = 7,
                                  stAni = 200, method = "L-BFGS-B",
                                  control = list(parscale = c(100, 1, 10, 1, 100)),
                                  lower = c(10, 0, 0.1, 0, 0.1),
                                  upper = c(2000, 1, 12, 1, 200))
plot(vv,separableModel01,all=T)
plot(vv,separableModel01,map=F,all=T) 
plot(vv,separableModel01,wireframe=T,all=T) 


separableModel <- vgmST("separable", 
                        space=vgm(0.9,"Exp", 150, 0.1),
                        time =vgm(0.9,"Exp", 3, 0.1),
                        sill=40, temporalUnit="days")

separableModel1<-fit.StVariogram(vv, separableModel, fit.method = 7,
                                 stAni = 200, method = "L-BFGS-B",
                                 control = list(parscale = c(100, 1, 10, 1, 100)),
                                 lower = c(10, 0, 0.1, 0, 0.1),
                                 upper = c(2000, 1, 12, 1, 200))

plot(vv,separableModel1,all=T)
plot(vv,separableModel1,map=F,all=T) 
plot(vv,separableModel1,wireframe=T,all=T) 

gridDE <- SpatialGrid(GridTopology(DE_RB_2005@sp@bbox[,1]%/%10000*10000, c(10000,10000),
                                   cells.dim=ceiling(apply(DE_RB_2005@sp@bbox,1,diff)/10000)))
proj4string(gridDE) <- CRS("+init=epsg:32632")
fullgrid(gridDE) <- F

DE_pred <- STF(gridDE, DE_RB_2005@time[smplDays])
proj4string(DE_pred) <- CRS("+init=epsg:32632")
proj4string(DE_RB_2005) <- CRS("+init=epsg:32632")
tIDS <- unique(pmax(1,pmin(as.numeric(outer(-5:5, smplDays, "+")), 365)))

separableModel0$space$range <- separableModel0$space$range*1000
separableModel$space$range <- separableModel$space$range*1000

sepPred0 <- krigeST(PM10~1, data=DE_RB_2005[,tIDS], 
                    newdata=DE_pred, separableModel0, nmax=50,
                    stAni=200)

stplot(sepPred0, col.regions=bpy.colors(), scales=list(draw=F),
       sp.layout = list("sp.polygons", DE_NUTS1,first=FALSE, col=gray(0.5)),
       main="spatio-temporal separable model")



sepPred <- krigeST(PM10~1, data=DE_RB_2005[,tIDS], 
                   newdata=DE_pred, separableModel, nmax=50,
                   stAni=200)

stplot(sepPred, col.regions=bpy.colors(), scales=list(draw=F),
       sp.layout = list("sp.polygons", DE_NUTS1,first=FALSE, col=gray(0.5)),
       main="spatio-temporal separable model")


