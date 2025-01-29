#Script for geomorphons analysis of LEM output or other DEMs
#Requires that QGIS is installed on the computer and has GRASS tools turned on.
#Older QGIS versions may not work

library(terra)
library(qgisprocess)
library(sf)
library(rgrass)
library(RColorBrewer)

#version for multiple ESRI ascii DEMs in a folder

setwd("C:/Users/mason/Dropbox/aeolian_landscapes/eguModels/One-sided_lowKmidLA/og_surf6")

#create list of output dems
list_asc <- list.files(pattern='.elevation.', full=TRUE)
#check if list is in correct order
list_asc

#loop creates temp tiffs from ascii dems, runs geomorphon analysis, 
#and maps drainage density
for (i in 1:length(list_asc)) {
  dem1 = rast(list_asc[i])
  #add fake CRS, needed by QGIS plugins
  crs(dem1)<- "epsg:32614"
  #make a temporary tiff
  writeRaster(dem1, "temp.tif", overwrite=TRUE)
  dem2<-rast("temp.tif")
  geomorphon <- qgis_run_algorithm(
    "grass7:r.geomorphon",
    elevation = dem2,
  )
  geomorphon_map = qgis_as_terra(qgis_extract_output(geomorphon))
  filename<-paste0("./geomorphons/geomorphons_", i, ".png")
  png(filename, height=nrow(geomorphon_map), 
      width=ncol(geomorphon_map)) 
  plot(geomorphon_map, plg=list(cex=2), 
       mar=c(3,3,3,9),
       pax=list(cex.axis=2.2), 
       maxpixels=ncell(geomorphon_map))
  dev.off()
  valleys <- ifel(geomorphon_map==9, 1, 0, datatype = "INT2S")
  filename<-paste0("./valleys/valleys_", i, ".png")
  png(filename, height=nrow(valleys), 
      width=ncol(valleys)) 
  plot(valleys, plg=list(cex=2), 
       mar=c(3,3,3,7),
       pax=list(cex.axis=2.2),
       maxpixels=ncell(valleys))
  dev.off()
  valley_density <- focal(valleys, w=c(99, 101), fun="mean")
  filename<-paste0("./valley_density/valley_density_", i, ".png")
  png(filename, height=nrow(valley_density), 
      width=ncol(valley_density)) 
  plot(valley_density, range=c(0.0, 0.18), 
       plg=list(cex=2), 
       mar=c(3,3,3,7),
       pax=list(cex.axis=2.2),
       maxpixels=ncell(valley_density))
  dev.off()
}

#version for multiple DEMs in geotiff format in a folder

setwd("C:/Users/mason/Dropbox/aeolian_landscapes/eguModels/One-sided_highKmidLA_4/og_surf6")

#create list of output dems (change pattern to whatever is common to all of them)
list_tifs <- list.files(pattern='.elevation.', full=TRUE)
#check if list is in correct order
list_tifs

#loop creates temp tiffs from ascii dems, runs geomorphon analysis, 
#and maps drainage density
for (i in 1:length(list_tifs)) {
  dem2 = rast(list_tifs[i])
  #if needed add fake CRS, needed by QGIS plugins
  #crs(dem2)<- "epsg:32614"
  #make a temporary tiff
  writeRaster(dem1, "temp.tif", overwrite=TRUE)
  geomorphon <- qgis_run_algorithm(
    "grass7:r.geomorphon",
    elevation = dem2,
  )
  geomorphon_map = qgis_as_terra(qgis_extract_output(geomorphon))
  filename<-paste0("./geomorphons/geomorphons_", i, ".png")
  png(filename, height=nrow(geomorphon_map), 
      width=ncol(geomorphon_map)) 
  plot(geomorphon_map, plg=list(cex=2), 
       mar=c(3,3,3,9),
       pax=list(cex.axis=2.2), 
       maxpixels=ncell(geomorphon_map))
  dev.off()
  valleys <- ifel(geomorphon_map==9, 1, 0, datatype = "INT2S")
  filename<-paste0("./valleys/valleys_", i, ".png")
  png(filename, height=nrow(valleys), 
      width=ncol(valleys)) 
  plot(valleys, plg=list(cex=2), 
       mar=c(3,3,3,7),
       pax=list(cex.axis=2.2),
       maxpixels=ncell(valleys))
  dev.off()
  valley_density <- focal(valleys, w=c(99, 101), fun="mean")
  filename<-paste0("./valley_density/valley_density_", i, ".png")
  png(filename, height=nrow(valley_density), 
      width=ncol(valley_density)) 
  plot(valley_density, range=c(0.0, 0.18), 
       plg=list(cex=2), 
       mar=c(3,3,3,7),
       pax=list(cex.axis=2.2),
       maxpixels=ncell(valley_density))
  dev.off()
}

#version for one DEM

setwd("D:/Dropbox/aeolian_landscapes/eguModels/One-sided_highKmidLA_4/flat3dep")
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
demname<-"West_Table_S"
tifname<-paste0(demname, ".tif")
dem2<-rast(tifname)

#for either
geomorphon <- qgis_run_algorithm(
  "grass7:r.geomorphon",
  elevation = dem2,
)
geomorphon_map = qgis_as_terra(qgis_extract_output(geomorphon))
#filename<-paste0("./geomorphons/geomorphons_", demname,".png")
#png(filename, height=nrow(geomorphon_map), 
    #width=ncol(geomorphon_map)) 
plot(geomorphon_map, plg=list(cex=2), 
     mar=c(3,3,3,9),
     pax=list(cex.axis=2.2), 
     maxpixels=ncell(geomorphon_map))
#dev.off()
valleys <- ifel(geomorphon_map==9, 1, 0, datatype = "INT2S")
#filename<-paste0("./valleys/valleys_", demname, ".png")
#png(filename, height=nrow(valleys), 
    #width=ncol(valleys)) 
plot(valleys, plg=list(cex=2), 
     mar=c(3,3,3,7),
     pax=list(cex.axis=2.2),
     maxpixels=ncell(valleys))
#dev.off()
valley_density <- focal(valleys, w=c(99, 101), fun="mean")
#filename<-paste0("./valley_density/valley_density_", demname, ".png")
#png(filename, height=nrow(valley_density), 
    #width=ncol(valley_density)) 
plot(valley_density, range=c(0.0, 0.18), 
     plg=list(cex=2), 
     mar=c(3,3,3,7),
     pax=list(cex.axis=2.1, xat=c(428000, 430000, 432000), yat=c(4583000, 4585000, 4587000)),
     maxpixels=ncell(valley_density))
#dev.off()

writeRaster(valley_density, "VDI_west3.tif", overwrite=TRUE)
writeRaster(valleys, "valleys_west3.tif", overwrite=TRUE)
writeRaster(geomorphon_map, "gemorphons_west3.tif", overwrite=TRUE)
plot(valley_density)
