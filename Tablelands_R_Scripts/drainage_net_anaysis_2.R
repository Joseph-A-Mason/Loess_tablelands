#Script for stochastic depression analysis and flowpath generation
#Requires QGIS installed with GRASS (including r.watershed) and Whitebox Tools add-ins
#Can either plot results from this script or save results and make maps in QGIS
#qgisprocess will produce lots of error messages even when it works properly
#You can generally ignore these if you get the maps to plot and nothing looks
#strange about them

library(terra)
library(qgisprocess)
library(sf)
library(rgrass)
library(RColorBrewer)

setwd("")

#Name of table
TableName <- "tallinn"
tifname<-(paste0(TableName,".tif"))

#import dem to terra
dem <- rast(tifname)

#Optional, configure and enable plugins and find algorithm needed
# qgis_configure(use_cached_data = TRUE)
# qgis_enable_plugins()
# qgis_search_algorithms("StochasticDepressionAnalysis")
# qgis_get_argument_specs("wbt:StochasticDepressionAnalysis")

#Map depressions
depr <- qgis_run_algorithm(
  "wbt:StochasticDepressionAnalysis",
  dem = dem,
  rmse = 0.5,
  range = 100.0
)
depr_r <- qgis_as_terra(qgis_extract_output(depr))
depr_r <- subst(depr_r, 0, NA, others=NULL)

#Map streams with GRASS GIS r.watershed tool
r_watershed_strm <- qgis_run_algorithm(
  "grass7:r.watershed",
  elevation = dem,
  threshold=1000
)

#Use to plot result of stream tool if needed
# strm <- qgis_as_terra(qgis_extract_output(r_watershed_strm))
# plot(strm)

#vectorize r.watershed results
thinned <- qgis_run_algorithm(
  "grass7:r.thin",
  input = qgis_as_terra(qgis_extract_output(r_watershed_strm, "stream")),
)

r_watershed_vect <- qgis_run_algorithm(
  "grass7:r.to.vect",
  input = qgis_as_terra(qgis_extract_output(thinned)),
  type = "line"
)

#create hillshade
hillshade <- qgis_run_algorithm(
  "wbt:Hillshade",
  dem = dem,
  azimuth = 135.0,
  altitude = 30.0,
  zfactor = 2.0
)

hshd2 <- qgis_as_terra(qgis_extract_output(hillshade))

#make a map
rwshd_vect<-st_as_sf(r_watershed_vect)
plot(hshd2,col=grey(1:100/100), legend=FALSE)
plot(depr_r, col=brewer.pal(5, "OrRd"), add=TRUE)
plot(rwshd_vect, col="blue", add=TRUE)

#Save depression map and stream map
depr_tifname<-(paste0(TableName,"_depr.tif"))
writeRaster(depr_r, depr_tifname, overwrite=TRUE)
r_watershed_strm_name<-(paste0(TableName,"_rwshd.shp"))
rwshd_vector<-vect(rwshd_vect)
writeVector(rwshd_vector, r_watershed_strm_name, overwrite=TRUE)

#Alternative flowpath analysis: Whitebox Tools
breached <- qgis_run_algorithm(
  "wbt:BreachDepressions",
  dem = dem,
  fill_pits=TRUE
)

flow_acc <- qgis_run_algorithm(
  "wbt:DInfFlowAccumulation",
  input = qgis_as_terra(qgis_extract_output(breached))
)

pntr <- qgis_run_algorithm(
  "wbt:D8Pointer",
  dem = qgis_as_terra(qgis_extract_output(breached))
)

streams <- qgis_run_algorithm(
  "wbt:ExtractStreams",
  flow_accum = qgis_as_terra(qgis_extract_output(flow_acc)),
  threshold = 1000
)

wbt_vect_name<-(paste0("C:/Users/mason/Dropbox/aeolian_landscapes/GIS_working/",
  TableName,"_wbt.shp"))
streams_vect <- qgis_run_algorithm(
  "wbt:RasterStreamsToVector",
  streams = qgis_as_terra(qgis_extract_output(streams)),
  d8_pntr = qgis_as_terra(qgis_extract_output(pntr)),
  output = wbt_vect_name
)
streams_vect2<-vect(wbt_vect_name)

#Make a map with WBT results
plot(hshd2,col=grey(1:100/100), legend=FALSE)
plot(depr_r, col=brewer.pal(5, "OrRd"), add=TRUE)
plot(streams_vect2, col="blue", add=TRUE)

