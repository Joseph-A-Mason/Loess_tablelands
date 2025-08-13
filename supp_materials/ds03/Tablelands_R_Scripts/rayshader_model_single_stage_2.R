library(terra)
library(hillshader)
library(rayshader)
library(raster)
library(rayrender)
library(av)
library(sf)

#Set working directory. Create one and put the model output .txt files in it
setwd('')

localrast = raster::raster("184.0elevation_Bignell.txt")
local_mat = raster_to_matrix(localrast)

sample_points = st_read("sample_pts_og_surf4.shp")
#sample_points = sample_points |> 
#  st_transform(st_crs(localtif1))
sample_coords = st_coordinates(sample_points)
sample_coords<-sample_coords[,-3]

local_mat %>%
  # Create hillshade layer using
  #ray-tracing
  ray_shade() %>%
  # Add ambient shading
  add_shadow_2d(
    ambient_shade(
      heightmap = local_mat
    )
  )
local_mat %>%
  height_shade(texture = (grDevices::colorRampPalette(c("#008771","#f5f5f5",'#de7b5c', "#a2320d")))(256)) %>%
  add_shadow(ray_shade(local_mat, zscale = 1), 0.5) %>%
  add_shadow(ambient_shade(local_mat), 0) %>%

plot_3d(local_mat, zscale = 1.0, theta = 150, phi=30,zoom= 0.65, fov= 56, windowsize = c(1000, 800))
render_points(lat=sample_coords[,2], long=sample_coords[,1], extent = localrast, 
              heightmap = local_mat, color="yellow",
              size = 20, zscale=1.0, offset = 0, clear_previous = TRUE)
render_snapshot(filename = "yr21000.png", overwrite=TRUE)


rgl::rgl.close()
