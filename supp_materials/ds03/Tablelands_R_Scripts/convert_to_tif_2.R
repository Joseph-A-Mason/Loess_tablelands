library(terra)

#change to full path for your directory
setwd("")

#change .asc$ to .txt$ if needed
list_asc <- list.files(pattern='\\.txt$', full=TRUE)
list_tif <- gsub("\\.txt$", ".tif", list_asc)

#converts to tif and writes to same directory
for (i in 1:length(list_asc)) {
  r <- rast(list_asc[i])
  r <- writeRaster(r, list_tif[i])
}
