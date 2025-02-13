#script for multiple types of slope mapping and plotting by elevation bands

library(terra)
library(sf)
library(RColorBrewer)
library(ggplot2)
library(qgisprocess)

#version for multiple ESRI ascii DEMs in a folder

setwd("")

#create list of output dems
list_asc <- list.files(pattern='.elevation.', full=TRUE)
#check if list is in correct order
list_asc

#loop creates slope map and calculates and plots distribution of slope in 10 m
#elevation slices
for (i in 2:length(list_asc)) {
  dem = rast(list_asc[i])
  #setup year and elevation column labels
  years<-250*(i-1)
  years_txt<-as.character(years)
  if(i<49|i>164){
    elevation_col<-as.character(substring(list_asc[i], 3, 23))
  }
  else{
    elevation_col<-as.character(substring(list_asc[i], 3, 22))
  }
  elevation_col
  slp<-terrain(dem, v="slope", neighbors=8,unit="degrees")
  filename<-paste0("./slope/slope_maps/slope_", years_txt, ".png")
  png(filename, height=nrow(slp), 
      width=ncol(slp)) 
  plot(slp, range=c(0.0, 30.0), 
       plg=list(cex=2), 
       mar=c(3,3,3,7),
       pax=list(cex.axis=2.2))
  dev.off()
  
  start_elev = 1170
  end_elev = 1250
  steps=8
  increment = (end_elev-start_elev)/steps
  rcl_matrix <- matrix(nrow=steps, ncol=3)
  lower = start_elev
  for(i in 1:steps){
    rcl_matrix[i,]=c(lower, lower+increment, lower)
    lower = lower+increment
  }
  elev_class <- classify(dem, rcl_matrix)
  filename2<-paste0("./slope/classes/classes_", years_txt, ".png") 
  png(filename2, height=nrow(elev_class), 
      width=ncol(elev_class)) 
  plot(elev_class, 
       plg=list(cex=2), 
       mar=c(3,3,3,7),
       pax=list(cex.axis=2.2))
  dev.off()
  
  #create stratified sample points (adjust number as needed)
  sample_points <- spatSample(elev_class, 10000, method="stratified", value=TRUE, as.points=TRUE)
  
  #Extract slope values
  slope_sample<-extract(slp, sample_points, bind=TRUE, raw=FALSE)
  sample_df<-as.data.frame(slope_sample)
  
  #change second $ to name of elevation class variable in the df
  sample_df$elev_class<-as.factor(sample_df[,grep(elevation_col, names(sample_df))])
  
  ggplot(sample_df,aes(x = slope)) +
    geom_histogram(bins = 25,aes(fill = elev_class)) +
    geom_histogram(bins = 25, fill = NA, color = 'black') +
    labs(x="Slope (degrees)", y="Count")+ggtitle(years_txt)+
    theme_minimal()
  
  ggsave(paste("./slope/dists/Slope_dist1_", years_txt, "_.jpg"), device="jpg", width=7, height=5)
  
  ggplot(sample_df,aes(x=slope))+geom_histogram(bins=30)+
    labs(x="Slope (degrees)", y="Count")+ggtitle(years_txt)+
    facet_wrap(~elev_class, ncol=3)+theme_bw()
  
  ggsave(paste("./slope/dists/Slope_dist2_", years_txt, "_.jpg"), device="jpg", width=7, height=5)
  
}

warnings()

#version for one DEM

setwd("D:/Dropbox/aeolian_landscapes/eguModels/One-sided_highKmidLA_4/og_surf6")
#for ESRI ascii dem
dem1 = rast('148.0elevation_Brady.txt')
demname = "148.0elevation_Brady"
crs(dem1)<-'EPSG:26914'
#make a temporary tiff

setwd("D:/Dropbox/aeolian_landscapes/GIS_working/10m_DEMs")
writeRaster(dem1, "temp.tif", overwrite=TRUE)
dem2<-rast("temp.tif")
plot(dem2)

#for dem in tif format
setwd("D:/Dropbox/aeolian_landscapes/GIS_working/10m_DEMs")
#change to filename minus .tif
demname<-"Bignell"
tifname<-paste0(demname, ".tif")
dem2<-rast(tifname)

#qgis_configure(use_cached_data = TRUE)
hillshade <- qgis_run_algorithm(
  "wbt:Hillshade",
  dem = dem2,
  azimuth = 135.0,
  altitude = 30.0,
  zfactor = 3.0
)

hshd2 <- qgis_as_terra(qgis_extract_output(hillshade))

slope_colors=colorRampPalette(c('#2c7bb6','#abd9e9','#ffffbf','#fdae61','#d7191c'))
slp<-terrain(dem2, v="slope", neighbors=8,unit="degrees")
#slp2<-terrain(dem2, v="slope", neighbors=8,unit="radians")
#asp<-terrain(dem2, v="aspect", neighbors=8,unit="radians")
#hshd<-shade(slp2, asp)
#filename<-paste0("./slope_maps/slope_",demname,".png")

#png(filename)
plot(hshd2, 
     col=grey(0:100/100), 
     legend=FALSE, 
     mar=c(3,3,3,7),
     pax=list(cex.axis=2.1, xat=c(364000, 366000, 368000), yat=c(4539000, 4541000, 4543000)))
plot(slp, range=c(0.0, 40.0), 
     col=slope_colors(100),
     plg=list(cex=2.0),
     mar=c(3,3,3,7),
     pax=list(ticks=FALSE, labels=FALSE),
     alpha=0.8,
     add=TRUE)
    
dev.off()

