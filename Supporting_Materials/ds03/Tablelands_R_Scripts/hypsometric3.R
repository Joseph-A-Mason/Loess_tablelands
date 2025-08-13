library(terra)
library(ggplot2)

elev_range <- c(1185,1240)
elev_list = list(seq(from=elev_range[1], to=elev_range[2], by=0.5))
elev_v<-unlist(elev_list)
ecdf_matrix<-matrix(nrow=length(elev_v), ncol=13)
ecdf_matrix[,1]<-elev_v

filenames<-c("100.0elevation_Peoria.tif","124.0elevation_Peoria.tif",
             "148.0elevation_Brady.tif","164.0elevation_Bignell.tif",
             "180.0elevation_Bignell.tif", "203.0elevation_Bignell.tif")

#Fill in "" with your working directory
#First scenario
scenario_name1<-"Bedrock-Depressions"
setwd('')
# #use if first scenario is og-surf4
for (i in 1:6){
  dem_df <- (rast(filenames[i])+10) |>
    as.data.frame()
  ecdf1<-ecdf(dem_df[,1])
  ecdf_matrix[,i+1]<-ecdf1(ecdf_matrix[,1])
}
# #use otherwise
# for (i in 1:6){
#   dem_df <- rast(filenames[i]) |>
#     as.data.frame()
#   ecdf1<-ecdf(dem_df[,1])
#   ecdf_matrix[,i+1]<-ecdf1(ecdf_matrix[,1])
# }
#Second scenario
scenario_name2<-"Bedrock-Drain"

setwd('')

for (i in 8:13){
  dem_df2 <- rast(filenames[i-7]) |>
    as.data.frame()
  ecdf2<-ecdf(dem_df2[,1])
  ecdf_matrix[,i]<-ecdf2(ecdf_matrix[,1])
}


hyps_df<-as.data.frame(ecdf_matrix)
column_names<-c("Elevation", "S1_Initial", "S1_6000", 
                "S1_12000", "S1_16000", "S1_20000", "S1_26000",
                "S2_Initial", "S2_6000", 
                "S2_12000", "S2_16000", "S2_20000", "S2_26000")
colnames(hyps_df)<-column_names

write.csv(hyps_df, "../hyps_flat_flat3dep.csv")

ggplot(data = hyps_df, aes(y = Elevation)) + 
  geom_line(aes(x=S1_12000, colour = "12,000", linetype=scenario_name1), size=1)+
  geom_line(aes(x=S1_20000, colour = "20,000", linetype=scenario_name1), size=1)+
  geom_line(aes(x=S1_26000, colour = "26,000", linetype=scenario_name1), size=1)+
  geom_line(aes(x=S2_12000, colour = "12,000", linetype=scenario_name2), size=1)+
  geom_line(aes(x=S2_20000, colour = "20,000", linetype=scenario_name2), size=1)+
  geom_line(aes(x=S2_26000, colour = "26,000", linetype=scenario_name2), size=1)+
  scale_color_manual("Years", breaks = c("12,000", "20,000", "26,000"),
                     values = c("#67001f","#d6604d", "#4393c3"))+
  scale_linetype_manual("Scenario", breaks = c(scenario_name1,scenario_name2),
                        values = c("solid", "dashed"))+
  labs(x="Fractional Area Below Elevation", y="Elevation(m)")+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        plot.title=element_text(size=14),
        axis.title=element_text(size=14),
        axis.text=element_text(size=14),
        legend.position=("right"),
        legend.text=element_text(size = 11),
        legend.key = element_rect(fill = "white", color="white"),
        legend.key.width = unit(3, "line"))

