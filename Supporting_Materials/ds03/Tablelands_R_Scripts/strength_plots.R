library(ggplot2)
library(cowplot)

# Set working directory
setwd("")

#read input, subset as needed
strength<-read.csv("Strength2.csv", header=TRUE, sep=',')
strength
TV_strength<- strength[ which(strength$Method=='TV'), ]
TV_strength
PP_strength<- strength[ which(strength$Method=='PP'), ]
PP_strength

#plots
#change the number inside rel() to adjust font size
#change legend.position numbers to move legend
p1<-ggplot(TV_strength, aes(Fr_Water, Strength, colour=Unit, shape=Horizon)) +
  geom_point(size = 4, show.legend=FALSE)+
  scale_colour_brewer(palette='Dark2')+
  scale_x_continuous(labels = scales::percent)+
  labs(x="Gravimetric Water Content", y=bquote("Shear Strength"~(kg~cm^2)))+
  theme(aspect.ratio = 0.7,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        #panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.2), angle = 90),
        axis.title.x = element_text(size = rel(1.2)),
        axis.text = element_text(size = rel(1.2)))
        #legend.position=c(1.15, 0.5),
        #legend.key.width=unit(1,"cm"),
        #legend.key =element_rect(fill="transparent"),
        #legend.box.background = element_rect(color = 'black'),
        #legend.box.margin = margin(t = 1, l = 1),
        #legend.text = element_text(size = rel(1.3)),
        #legend.title = element_text(size = rel(1.3)))
p1
#change the number inside rel() to adjust font size
#change legend.position numbers to move legend
p2<-ggplot(PP_strength, aes(Fr_Water, Strength, colour=Unit, shape=Horizon)) +
  geom_point(size = 4, show.legend=FALSE)+
  scale_colour_brewer(palette='Dark2')+
  scale_x_continuous(labels = scales::percent)+
  labs(x="Gravimetric Water Content", y=expression(paste("Unconf. Compr. Strength ",(kg~cm^-2))))+
  theme(aspect.ratio = 0.7,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        #panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.2), angle = 90),
        axis.title.x = element_text(size = rel(1.2)),
        axis.text = element_text(size = rel(1.2)))
        #legend.position=c(1.15, 0.5),
        #legend.key.width=unit(1,"cm"),
        #legend.key =element_rect(fill="transparent"),
        #legend.box.background = element_rect(color = 'black'),
        #legend.box.margin = margin(t = 1, l = 1),
        #legend.text = element_text(size = rel(1.2)),
        #legend.title = element_text(size = rel(1.2)))
p2

TV_strength2<-TV_strength[-13,]
TV_strength2$PP_Strength <-PP_strength$Strength
TV_strength2

p3<-ggplot(TV_strength2, aes(Strength, PP_Strength, colour=Unit, shape=Horizon)) +
  geom_point(size = 4)+
  geom_segment(aes(x=0, y=0, xend=1.75, yend=3.5), colour="gray", linetype=1, linewidth=1)+
  scale_colour_brewer(palette='Dark2')+
  labs(x=expression(paste("Shear Strength ",(kg~cm^-2))), 
       y=expression(paste("Unconf. Compr. Strength ",(kg~cm^-2))))+
  theme(aspect.ratio = 0.7,
        panel.background=element_rect(fill="white", colour="black"),
        panel.grid.major=element_line(colour="gray"),
        #panel.grid.minor=element_line(colour="gray"),
        axis.title.y = element_text(size = rel(1.2), angle = 90),
        axis.title.x = element_text(size = rel(1.2)),
        axis.text = element_text(size = rel(1.2)),
        legend.position=c(1.7, 0.5),
        legend.key.width=unit(1,"cm"),
        legend.key =element_rect(fill="transparent"),
        #legend.box.background = element_rect(color = 'black'),
        legend.box.margin = margin(t = 1, l = 1),
        legend.text = element_text(size = rel(1.2)),
        legend.title = element_text(size = rel(1.2)))+
  guides(color = guide_legend(ncol = 2))
p3

#combined plot
aligned_plots <- align_plots(p1, p2, p3, align="hv")

ggdraw() +
  draw_plot(aligned_plots[[1]], x = 0, y = 0.48, width = 0.45, height = 0.45) +
  draw_plot(aligned_plots[[2]], x = 0.47, y = 0.48, width = 0.45, height = 0.45) +
  draw_plot(aligned_plots[[3]], x = -0.09, y = 0.04, width = 0.65, height = 0.45) +
  draw_plot_label(label = c("a", "b", "c"), size = 15,
                  x = c(0.082, 0.55, 0.082), y = c(0.96, 0.96, 0.525))  

#stats on data
#correlation of PP and TV
cor.test(TV_strength2$Strength, TV_strength2$PP_Strength, method=c("pearson", "kendall", "spearman"))

#normality tests
qqnorm(PP_strength$Strength)
qqline(PP_strength$Strength)
qqnorm(TV_strength$Strength)
qqline(TV_strength$Strength)
shapiro.test(PP_strength$Strength)
shapiro.test(TV_strength$Strength)

#kruskal-wallis, appropriate for PP and TV for units
#mann-whitney U, appropriate for PP and TV for horizons
PP_strength$Unit=as.factor(PP_strength$Unit)
levels(PP_strength$Unit)
PP_strength$Unit=ordered(PP_strength$Unit, levels=c("A", "B", "C", "D", "E", "F", "H"))
kruskal.test(Strength~Unit, PP_strength)

PP_strength$Horizon=as.factor(PP_strength$Horizon)
levels(PP_strength$Horizon)
PP_strength$Horizon=ordered(PP_strength$Horizon, levels=c("A or B", "C"))
kruskal.test(Strength~Horizon, PP_strength)
wilcox.test(Strength ~ Horizon, data=PP_strength, exact=FALSE) 

TV_strength$Unit=as.factor(TV_strength$Unit)
levels(TV_strength$Unit)
TV_strength$Unit=ordered(TV_strength$Unit, levels=c("A", "B", "C", "D", "E", "F", "H"))
kruskal.test(Strength~Unit, TV_strength)

TV_strength$Horizon=as.factor(TV_strength$Horizon)
levels(TV_strength$Horizon)
TV_strength$Horizon=ordered(TV_strength$Horizon, levels=c("A or B", "C"))
kruskal.test(Strength~Horizon, TV_strength)
wilcox.test(Strength ~ Horizon, data=TV_strength, exact=FALSE) 

