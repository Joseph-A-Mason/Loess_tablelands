#Script to calculate and erosion rate and cumulative erosion from model
#output dems. Versions for model domain mean and point values.
#Fill in "" with directory and file paths as needed

#Requires QGIS installed, with Whitebox Tools add-in
library(terra)
library(ggplot2)
library(qgisprocess)

#Scenarios (change names as needed)
scenario1 <- "Bedrock-depressions"
scenario2 <- "Bedrock-drain"
scenario3 <- "Flat"
scenario4 <- "Flat3dep"

#Model setup
total_t <- 26000
loess1 <- c(0.0025, 10800)
loess1b <- c(0.00225, 12000)
loess2 <- c(0.00025, 15000)
loess2b <- c(0.00035, 16000)
loess3 <- c(0.0006, 26000)
dimensions <- c(626, 626)
cell_size<-100
num_cells <- dimensions[1]*dimensions[2]

#initial surfaces. Replace ... with the rest of the path
init_dem1<-rast('.../100.0elevation_Peoria.txt')
init_dem2<-rast('.../100.0elevation_Peoria.txt')
init_dem3<-rast('.../100.0elevation_Peoria.txt')
init_dem4<-rast('.../100.0elevation_Peoria.txt')

erosion_analysis <- function(scenario, init_dem, total_t, loess1, loess2, loess3, 
                             cell_size, num_cells){
  #create list of output erosion maps
  list_asc <- list.files(pattern='.erosion.', full=TRUE)
  num_steps<-length(list_asc)-1
  
  #create list of output elevation maps
  list_asc2 <- list.files(pattern='.elevation.', full=TRUE)
  num_steps<-length(list_asc2)-1
  
  time_per_step<-total_t/num_steps
  
  erosion<-matrix(nrow=num_steps, ncol=14)
  erosion[,1]<-scenario
  loess_total <- 0.0
  prev_loess_dep <- loess1[1]*time_per_step
  prev_erosion <- rast(list_asc[1])
  
  for (i in 2:(num_steps+1)) {
    years <- (i-1)*time_per_step
    erosion[(i-1), 2] <- years
    if (years <= loess1[2]) {
      loess_dep <- loess1[1]*time_per_step
    } else if (years <= loess1b[2]) {
      loess_dep <- (loess1[1]-((loess1b[1]/(loess1b[2]-loess1[2]))*(years-loess1[2])))*time_per_step
    } else if (years <= loess2[2]) {
      loess_dep <- loess2[1]*time_per_step
    } else if (years <= loess2b[2]) {
      loess_dep <- (loess2[1]+((loess2b[1]/(loess2b[2]-loess2[2]))*(years-loess2[2])))*time_per_step
    } else {
      loess_dep <- loess3[1]*time_per_step
    }
    loess_total <- loess_total + loess_dep
    erosion[(i-1), 3] <- loess_total
    localrast <- rast(list_asc[i])
    total_erosion_rast <- localrast+prev_erosion
    total_erosion_mean <- global(total_erosion_rast, fun="mean")
    total_erosion_min <- global(total_erosion_rast, fun="min")
    total_erosion_max <- global(total_erosion_rast, fun="max")
    erosion[(i-1), 4] <- total_erosion_mean$mean
    erosion[(i-1), 5] <- total_erosion_min$min
    erosion[(i-1), 6] <- total_erosion_max$max
    loess_eroded <- total_erosion_rast/loess_total
    loess_eroded_mean <- global(loess_eroded, fun="mean")
    loess_eroded_min <- global(loess_eroded, fun="min")
    loess_eroded_max <- global(loess_eroded, fun="max")
    erosion[(i-1), 7] <- loess_eroded_mean$mean
    erosion[(i-1), 8] <- loess_eroded_min$min
    erosion[(i-1), 9] <- loess_eroded_max$max
    erosion_rate_rast <- localrast*4
    tifname1<-paste0("./erosion_mapping/erosion_", i, ".tif")
    writeRaster(erosion_rate_rast, 
                tifname1, 
                overwrite=TRUE)
    elevation_rast <- rast(list_asc2[i])
    tifname2<-paste0("./erosion_mapping/elevation_", i, ".tif")
    writeRaster(elevation_rast, 
                tifname2, 
                overwrite=TRUE)
    erosion_rate_mean <- global(erosion_rate_rast, fun="mean")
    erosion_rate_min <- global(erosion_rate_rast, fun="min")
    erosion_rate_max <- global(erosion_rate_rast, fun="max")
    erosion[(i-1), 10] <- erosion_rate_mean$mean
    erosion[(i-1), 11] <- erosion_rate_min$min
    erosion[(i-1), 12] <- erosion_rate_max$max
    erosion[(i-1), 13] <- erosion_rate_mean$mean/1000
    erosion[(i-1), 14] <- (erosion_rate_mean$mean*num_cells*cell_size)/1000
    prev_erosion <- total_erosion_rast
    prev_loess_dep <- loess_dep
  }
  erosion_df<-as.data.frame(erosion)
  colnames(erosion_df)<-c('Scenario','Years','Loess_Deposited',
                          'Total_Erosion_Mean', 'Total_Erosion_Min', 
                          'Total_Erosion_Max', 'Mean_Fract_Loess_Eroded',
                          'Min_Fract_Loess_Eroded', 'Max_Fract_Loess_Eroded',
                          'Erosion_Per_1000yr_Mean','Erosion_Per_1000r_Min', 
                          'Erosion_Per_1000yr_Max','Mean_Erosion_Per_Year',
                          'Vol_Eroded_Per_Year')
  return(erosion_df)
}

setwd('')
erosion_df1<-erosion_analysis(scenario1, init_dem1, total_t,
                 loess1, loess2, loess3, cell_size, num_cells)

setwd('')
erosion_df2<-erosion_analysis(scenario2, init_dem2, total_t,
                 loess1, loess2, loess3, cell_size, num_cells)

setwd('')
erosion_df3<-erosion_analysis(scenario3, init_dem3, total_t,
                 loess1, loess2, loess3, cell_size, num_cells)

setwd('')
erosion_df4<-erosion_analysis(scenario4, init_dem4, total_t,
                 loess1, loess2, loess3, cell_size, num_cells)

erosion_df_all<-rbind(erosion_df1, erosion_df2, erosion_df3, erosion_df4)

cols <- names(erosion_df_all)[2:14]
erosion_df_all[cols] <- lapply(erosion_df_all[cols], as.numeric)

ScenarioNames <- c("Flat", "Flat-Depressions","Bedrock-Depressions", "Bedrock-Drain")

ggplot(erosion_df_all, aes(Years, Total_Erosion_Mean, colour = Scenario)) + 
  geom_line()

ggplot(erosion_df_all, aes(Years, Total_Erosion_Mean, colour=Scenario)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Scenario", palette='Paired', 
                      labels=ScenarioNames[1:4])+
  #scale_x_continuous(limits=c(0, 26000))+
  labs(x="Years", y="Mean Cumulative Erosion (m)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(0.34, 0.8),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

ggplot(erosion_df_all, aes(Years, Mean_Erosion_Per_Year, colour=Scenario)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Scenario", palette='Paired', 
                      labels=ScenarioNames[1:4])+
  #scale_x_continuous(limits=c(0, 26000))+
  labs(x="Years", y="Mean Erosion Per Year (m)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(1.35, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

ggplot(erosion_df_all, aes(Years, Mean_Erosion_Per_Year*1400000, colour=Scenario)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Scenario", palette='Paired', 
                      labels=ScenarioNames[1:4])+
  #scale_x_continuous(limits=c(0, 26000))+
  labs(x="Years", y="Sediment Yield Per Year (tonne/km2)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(1.35, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

ggplot(erosion_df_all, aes(Years, Mean_Fract_Loess_Eroded, colour=Scenario)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Scenario", palette='Paired', 
                      labels=ScenarioNames[1:4])+
  #scale_x_continuous(limits=c(0, 26000))+
  labs(x="Years", y="Mean Fraction of Loess Eroded")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(1.35, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

#Version to extract point values from one scenario (change scenario number, working
#directory as needed)

#Use these steps to set up four sample points
setwd("")
r <- rast("139.0elevation_Peoria.txt")
plot(r)
sample_points <- rbind(c(500.0, 500.0),c(3000.0, 2300.0),c(5000.0,3500.0), c(4450.0, 5800.0))
sample_points_v<-vect(sample_points)
plot(r)
plot(sample_points_v,add=TRUE)

#export raster and shapefile if desired. Fill in file names in ""
writeRaster(r, 
            "", 
            overwrite=TRUE)
writeVector(sample_points_v, 
            "",
            overwrite=TRUE)

erosion_analysis2 <- function(scenario, init_dem, total_t, loess1, loess1b, 
                              loess2, loess2b, loess3, sample_points){
  #create list of output dems (change "elevation" to "erosion" to get erosion maps)
  list_asc <- list.files(pattern='.elevation.', full=TRUE)
  #check if list is in correct order
  num_steps<-length(list_asc)-1
  time_per_step<-total_t/num_steps
  
  erosion2<-matrix(nrow=num_steps, ncol=19)
  erosion2[,1]<-scenario
  prev_rast <- init_dem
  loess_total <- 0.0
  
  for (i in 2:(num_steps+1)) {
    years <- (i-1)*time_per_step
    erosion2[(i-1), 2] <- years
    if (years <= loess1[2]) {
      loess_dep <- loess1[1]*time_per_step
    } else if (years <= loess1b[2]) {
      loess_dep <- (loess1[1]-((loess1b[1]/(loess1b[2]-loess1[2]))*(years-loess1[2])))*time_per_step
    } else if (years <= loess2[2]) {
      loess_dep <- loess2[1]*time_per_step
    } else if (years <= loess2b[2]) {
      loess_dep <- (loess2[1]+((loess2b[1]/(loess2b[2]-loess2[2]))*(years-loess2[2])))*time_per_step
    } else {
      loess_dep <- loess3[1]*time_per_step
    }
    loess_total <- loess_total + loess_dep
    erosion2[(i-1), 3] <- loess_total
    localrast <- rast(list_asc[i])
    total_erosion_rast <- ((localrast - init_dem) - loess_total)*-1
    loess_remaining <- loess_total - total_erosion_rast
    loess_fract <- loess_remaining/loess_total
    step_erosion_rast <- ((localrast - prev_rast) - loess_dep)*-1
    extract1<-(extract(localrast, sample_points))
    colnames(extract1)<-'value'
    erosion2[(i-1), 4:7]<-extract1$value[1:4]
    extract2<-(extract(total_erosion_rast, sample_points))
    colnames(extract2)<-'value'
    erosion2[(i-1), 8:11]<-extract2$value[1:4]
    extract3<-(extract(loess_remaining, sample_points))
    colnames(extract3)<-'value'
    erosion2[(i-1), 12:15]<-extract3$value[1:4]
    extract4<-(extract(loess_fract, sample_points))
    colnames(extract4)<-'value'
    erosion2[(i-1), 16:19]<-extract4$value[1:4]
    prev_rast <- localrast
  }
  
  
  erosion2_df<-as.data.frame(erosion2)
  colnames(erosion2_df)<-c('Scenario','Years','Loess_total','Elevation.1', 'Elevation.2',
                            'Elevation.3', 'Elevation.4', 
                            'Erosion.1', 'Erosion.2',
                            'Erosion.3', 'Erosion.4',
                            'Loess_remaining.1','Loess_remaining.2',
                            'Loess_remaining.3', 'Loess_remaining.4',
                            'Loess_fract.1','Loess_fract.2',
                            'Loess_fract.3', 'Loess_fract.4')
  return(erosion2_df)
}

#set working directory as the scenario you want to look at; also insert correct 
#scenario number and initdem in erosion_analysis2 parameters.
setwd('')
erosion2_df2<-erosion_analysis2(scenario4, init_dem4, total_t,
                              loess1, loess1b, loess2, loess2b, loess3,
                              sample_points)

erosion2_df3<-reshape(erosion2_df2, varying = c('Elevation.1', 'Elevation.2',
                                              'Elevation.3', 'Elevation.4',
                                              'Erosion.1', 'Erosion.2',
                                              'Erosion.3', 'Erosion.4',
                                              'Loess_remaining.1', 'Loess_remaining.2',
                                              'Loess_remaining.3', 'Loess_remaining.4',
                                              'Loess_fract.1', 'Loess_fract.2',
                                              'Loess_fract.3', 'Loess_fract.4'),
                                              direction = 'long')
colnames(erosion2_df3)<-c('Scenario', 'Years', 'Loess_Total','Point', 'Elevation', 'Erosion',
                         'Loess_Remaining', 'Loess_Fraction')

erosion2_df3$Years<-as.numeric(as.character(erosion2_df3$Years))
erosion2_df3$Loess_Total<-as.numeric(as.character(erosion2_df3$Loess_Total))
erosion2_df3$Point<-as.character(erosion2_df3$Point)
erosion2_df3$Elevation<-as.numeric(as.character(erosion2_df3$Elevation))
erosion2_df3$Erosion<-as.numeric(as.character(erosion2_df3$Erosion))
erosion2_df3$Loess_Remaining<-as.numeric(as.character(erosion2_df3$Loess_Remaining))
erosion2_df3$Loess_Fraction<-as.numeric(as.character(erosion2_df3$Loess_Fraction))

write.table(erosion2_df3, scenario1, row.names = FALSE, col.names = TRUE)
PointNames <- c("1", "2","3", "4")


ggplot(erosion2_df3, aes(Years, Loess_Fraction, colour=Point)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Point", palette='Paired', 
                      labels=PointNames[1:4])+
  scale_x_continuous(limits=c(0, 26000))+
  scale_y_continuous(limits=c(0.0, 1.3))+
  labs(x="Years", y="Fraction of Loess Remaining")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(1.15, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

ggplot(erosion2_df3, aes(Years, Loess_Remaining, colour=Point)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Point", palette='Paired', 
                      labels=PointNames[1:4])+
  scale_x_continuous(limits=c(0, 26000))+
  scale_y_continuous(limits=c(-5, 37))+
  labs(x="Years", y="Loess Thickness (m)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(1.15, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

ggplot(erosion2_df3, aes(Years, Elevation, colour=Point)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Point", palette='Paired', 
                      labels=PointNames[1:4])+
  scale_x_continuous(limits=c(0, 26000))+
  scale_y_continuous(limits=c(1180, 1240))+
  labs(x="Years", y="Elevation (m)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(1.15, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

ggplot(erosion2_df3, aes(Years, Erosion, colour=Point)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_colour_brewer(name="Point", palette='Paired', 
                      labels=PointNames[1:4])+
  scale_x_continuous(limits=c(0, 26000))+
  scale_y_continuous(limits=c(-5, 40))+
  labs(x="Years", y="Cumulative Erosion (m)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.3), angle = 90),
        axis.title.x = element_text(size = rel(1.3)),
        axis.text = element_text(size = rel(1.3)),
        legend.position=c(0.2, 0.8),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        legend.text = element_text(size = rel(1.1)),
        legend.title = element_text(size = rel(1.1))
  )

#version for printing individual erosion maps
#for erosion_map and dem in tif format
setwd("")
#change to erosion map filename
tifname<-"erosion_104.tif"
erode_map<-rast(tifname)
#change to elevation map filename
tifname2<-"elevation_104.tif"
dem<-rast(tifname2)
#fake crs to avoid qgis whitebox tools error
crs(erode_map)<-'EPSG:26914'
crs(dem)<-'EPSG:26914'
setwd("")
writeRaster(erode_map, "temp.tif", overwrite=TRUE)
erode_map2<-rast("temp.tif")
writeRaster(dem, "temp2.tif", overwrite=TRUE)
dem2<-rast("temp2.tif")


#qgis_configure(use_cached_data = TRUE)
hillshade <- qgis_run_algorithm(
  "wbt:Hillshade",
  dem = dem2,
  azimuth = 135.0,
  altitude = 30.0,
  zfactor = 3.0
)

hshd <- qgis_as_terra(qgis_extract_output(hillshade))

erode_colors<-colorRampPalette(c('#2c7bb6','#abd9e9','#ffffbf','#fdae61','#d7191c'))
#set breaks
cuts<-c(-10.0,-0.1,0.1,5.0,10.0, 20.0)
leg.txt <- c("<-0.1", "-0.1-0.1", "0.1-5.0", "5.0-10.0", '10.0-20.0')

#png(filename)
plot(hshd, 
     col=grey(0:100/100), 
     legend=FALSE, 
     mar=c(3,3,3,7),
     pax=list(cex.axis=2.1, xat=c(1000, 3000, 5000), yat=c(1000, 3000, 5000)))
plot(erode_map2, 
     breaks=cuts, 
     col=erode_colors(5),
     plg=list(x=6300, y=4300, title="Erosion Rate \n(m/1000 yr)", legend=leg.txt, cex=2.7),
     mar=c(3,3,3,7),
     pax=list(ticks=FALSE, labels=FALSE),
     alpha=0.7,
     add=TRUE)

dev.off()