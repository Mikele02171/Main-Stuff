#############################
# Workshop 2
#############################

parks <- read.csv("Park_Locations.csv", header = TRUE)
str(parks)
parks <- parks[complete.cases(parks),]
bparks <- parks[, c("LONG", "LAT", "SHAPE_Area")]
bparks_coor <- cbind(bparks$LONG, bparks$LAT)
row.names(bparks_coor) <-  1:nrow(bparks_coor)
row.names(bparks) <-  1:nrow(bparks)
llCRS <- CRS("+proj=longlat +ellps=WGS84")
bparks_sp <- SpatialPoints(bparks_coor, proj4string = llCRS)
summary(bparks_sp)
bparks_spdf <-
  SpatialPointsDataFrame(bparks_coor,
                         bparks,
                         proj4string = llCRS,
                         match.ID = TRUE)
summary(bparks_spdf)

bparks_sf <-  st_as_sf(bparks_spdf)
str(bparks_sf)
mapview(bparks_sf,
        col.regions = "red",
        cex = "SHAPE_Area",
        fgb = FALSE)

bparks_sf[bparks_sf$SHAPE_Area %in% sort(bparks_sf$SHAPE_Area, decreasing = T)[1:5],]

bparks_l <- bparks_sf[bparks_sf$SHAPE_Area %in% sort(bparks_sf$SHAPE_Area, decreasing = T)[1:5],]

lnstr_sfg2 <-
  st_linestring(as.matrix(bparks_l[, c("LONG", "LAT"), drop = TRUE]))
lnstr_sfc <- st_sfc(lnstr_sfg2,
                    crs = 4326)
mapview(
  lnstr_sfc,
  alpha.regions = 0,
  color = "red",
  lwd = 2,
  fgb = FALSE
)

mapview(bparks_sf,
        col.regions = "red",
        cex = "SHAPE_Area",
        fgb = FALSE) + mapview(
          lnstr_sfc,
          alpha.regions = 0,
          color = "red",
          lwd = 2,
          fgb = FALSE
        )
