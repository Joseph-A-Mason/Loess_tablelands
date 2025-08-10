library(terra)
library(dismo)
library(gstat)
library(sf)
library(ggplot2)

setwd('')

#This imports a dem that is the exact area over which we want to do the
#interpolation. Substitute the one you are using.
rast1<-rast("gs_idw_dankworth_ext.tif")
#make sure it looks right
plot(rast1)
rast1

#Import the shapefile of wells with bedrock depth interpreted
wells_a<-vect("Dankworth_RW_TH.shp")
wells<-project(wells_a,crs(rast1))
#make sure they all plot on the area of interest
plot(wells, add=TRUE)
#makes an sf object from the wells vector data
wells_st<-st_as_sf(wells)
xy <- terra::xyFromCell(rast1, 1:ncell(rast1))
rast1_pts<-st_as_sf(as.data.frame(xy), coords = c("x", "y"), crs=st_crs(rast1))

numwells<-nrow(wells_st)
# matrix to store the rmse values obtained with leave one out
#estimate for each value of n
test_mat <- matrix(,nrow=numwells-4,ncol=3) # IDW

#function to calculate RMSE from residuals
RMSE <- function(residuals) {
  sqrt(sum((residuals)^2) / length(residuals))
}

#runs through n values from 5 up to total number of wells
#Edit TopOg_m to match the name of the attribute representing
#elevation of the top of bedrock
for (i in 5:numwells){
  gs1 <- gstat(formula = TopOg_m ~ 1, locations = wells_st, nmax = i,
              set = list(idp = 1))
  idw1 <- predict(gs1,rast1_pts)
  crossval1<-gstat.cv(gs1)
  test_mat[i-4, 1]<-i
  test_mat[i-4, 2]<-RMSE(crossval1$residual)
  gs2 <- gstat(formula = TopOg_m ~ 1, locations = wells_st, nmax = i,
              set = list(idp = 2))
  idw2 <- predict(gs2,rast1_pts)
  crossval2<-gstat.cv(gs2)
  test_mat[i-4, 3]<-RMSE(crossval2$residual)
}

#get a dataframe of rmse for all the values of n and powers of distance
test_df<-as.data.frame(test_mat)
colnames(test_df)<-c("n_max", "Pwr_1_RMSE","Pwr_2_RMSE")
write.csv(test_df, "Wauneta_wells3_test.csv")

#Select best parameters from test_mat and run final interpolation,
#also getting residuals

gs <- gstat(formula = TopOg_m ~ 1, locations = wells_st, nmax = 20,
             set = list(idp = 2))
idw <- predict(gs,rast1_pts)
crossval<-gstat.cv(gs)

idw<- terra::rasterize(idw, rast1, field = "var1.pred", fun = "mean")
plot(idw)
writeRaster(idw, "gs_idw_wauneta.tif", overwrite=TRUE)

nrow(crossval)
resid_list<-matrix(nrow=nrow(crossval),ncol=4)
crossval_rmse<-RMSE(crossval$residual)
resid_list[,1]<-crossval$var1.pred
resid_list[,2]<-crossval$observed
resid_list[,3]<-crossval$residual
resid_list[,4]<-crossval_rmse
resid_df<-as.data.frame(resid_list)
colnames(resid_df)<-c("predicted","observed", "residual", "RMSE")
m_index<-match(wells_a$TopOg_m, resid_df$observed)
resid_df_df<-resid_df[m_index,]
write.csv(resid_df,"wauneta_resid.csv")
wells_a$observed<-resid_df$observed
wells_a$predicted<-resid_df$predicted
wells_a$residual<-resid_df$residual
wells_a$rmse<-resid_df$RMSE
writeVector(wells_a, "wauneta_wells_resid.shp", overwrite=TRUE)
#Look at what you got, plotting wells shaded by residuals over
#DEM
plot(rast1)
plot(wells_a, y="residual", add=TRUE)
plot(wells_a, y="residual")
