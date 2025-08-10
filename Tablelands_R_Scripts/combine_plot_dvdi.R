library(ggplot2)

scenarios <- c("og_surf4",
               "og_surf6",
               "flat",
               "flat3dep")

ScenarioNames <- c("4.Bedrock-Depressions", 
                   "3.Bedrock-Drain", 
                   "1.Flat", 
                   "2.Flat-Depressions")

setups<-c("K0004D05",
          "K0008D05",
          "K0008D05SP0",
          "K0012D01",
          "K0012D05",
          "K0012D05SP0001",
          "K0012D10",
          "K0012D50",
          "K0016D05",
          "noBrady")

setwd('')

for (i in 1:10) {
      df1<-read.csv(paste0("./", setups[i], "/",scenarios[1],"_DVDI.csv"), header = TRUE)
      df1$Scenario<-scenarios[1]
      df2<-read.csv(paste0("./", setups[i], "/",scenarios[2],"_DVDI.csv"), header = TRUE)
      df2$Scenario<-scenarios[2]
      df3<-read.csv(paste0("./", setups[i], "/",scenarios[3],"_DVDI.csv"), header = TRUE)
      df3$Scenario<-scenarios[3]
      df4<-read.csv(paste0("./", setups[i], "/",scenarios[4],"_DVDI.csv"), header = TRUE)
      df4$Scenario<-scenarios[4]
      dvdi_df<-rbind(df1, df2, df3, df4)
      write.csv(dvdi_df, paste0(setups[i],"_DVDI.csv"))
}

setups
setup_number = 2
setups[setup_number]

dvdi_all_df<-read.csv(paste0("C:/Users/mason/Dropbox/aeolian_landscapes/eguModels/sensitivity/",
                             setups[setup_number], "_DVDI.csv"), header=TRUE)

dvdi_all_df$Scenario <- replace(dvdi_all_df$Scenario, dvdi_all_df$Scenario == scenarios[1], ScenarioNames[1])
dvdi_all_df$Scenario <- replace(dvdi_all_df$Scenario, dvdi_all_df$Scenario == scenarios[2], ScenarioNames[2])
dvdi_all_df$Scenario <- replace(dvdi_all_df$Scenario, dvdi_all_df$Scenario == scenarios[3], ScenarioNames[3])
dvdi_all_df$Scenario <- replace(dvdi_all_df$Scenario, dvdi_all_df$Scenario == scenarios[4], ScenarioNames[4])

ggplot(dvdi_all_df, aes(Year, DVDI, colour = Scenario)) + 
  geom_line()

ggplot(dvdi_all_df, aes(Year, DVDI, color=Scenario, linetype = Scenario)) +
  geom_line(linewidth=1.2)+
  #change palette using https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
  scale_color_discrete(type= c("#b2182b","#b2182b", "#4393c3","#4393c3"))+
  scale_linetype_manual("Scenario", values = c("dashed", "solid", "dashed", "solid"))+
  scale_y_continuous(limits=c(0, 0.15))+
  labs(title= "K=0.0008, D=0.05, SPcrit=0.001", 
       x="Years", y="Domain Valley Density Index")+
  geom_segment(aes(x = 1000, y = 0.0584, xend = 1000, yend = 0.1118), 
               linewidth=1.5, colour="#26B543", show.legend=FALSE)+
  theme(aspect.ratio = 1,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        panel.grid.minor=element_line(colour="gray"),
        plot.title=element_text(size=12),
        axis.title=element_text(size=12),
        axis.text=element_text(size=12),
        legend.position=("right"),
        legend.text=element_text(size = 12),
        legend.key = element_rect(fill = "white", color="white"),
        legend.key.width = unit(3, "line")
  )
p + geom_segment(aes(x = 1000, y = 0.0584, xend = 1000, yend = 0.1118), linewidth=1.5, colour="darkgreen", show.legend={'color': False})
