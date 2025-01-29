library(terra)

#change to full path for your directory
setwd("")

#change .asc$ to .txt$ if needed
list_tif <- list.files(pattern='\\.tif$', full=TRUE)
list_asc <- gsub("\\.tif$", ".asc", list_tif)

#converts to tif and writes to same directory
for (i in 1:length(list_tif)) {
  r <- rast(list_tif[i])
  r <- writeRaster(r, list_asc[i])
}
