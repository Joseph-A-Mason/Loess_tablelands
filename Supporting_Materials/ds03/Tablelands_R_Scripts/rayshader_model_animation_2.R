library(terra)
library(hillshader)
library(rayshader)
library(raster)
library(rayrender)
library(av)

#Set working directory. Need to have a folder within it named "3D_animation"
setwd('')

#create list of output dems (change "elevation" to "erosion" to get erosion maps)
list_asc <- list.files(pattern='.elevation.', full=TRUE)
#check if list is in correct order
list_asc

#loop creates 3D model from each output dem and captures an image of it from one perspective
for (i in 1:length(list_asc)) {
  localrast = raster::raster(list_asc[i])
  local_mat = raster_to_matrix(localrast)
  local_mat %>%
    # Create hillshade layer using
    # ray-tracing
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
  render_snapshot(filename = sprintf("./3D_animation/og_surf6_%i.png", i))
}

av::av_encode_video(sprintf("./3D_animation/og_surf6_%i.png",seq(1,105,by=1)), framerate = 3.0,
                    output = "og_surf6.mp4")

rgl::rgl.close()
