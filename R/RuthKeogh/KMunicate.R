###############
#Ruth Keogh, 10 JUly 2020
#Creates a Kaplan-Meier plot with accompanying table
###############

#------
#packages
library(survival)
library(ggplot2)
library(pammtools)
library(grid)

#------
#pbc data
dat=pbc

dat=pbc[!is.na(pbc$trt),]#exclude those who were not randomized

dat$time=dat$time/365.25 #measure time in years

dat$status=ifelse(dat$status==2,1,dat$status) 
#status at endpoint, 0/1/2 for censored, transplant, dead
#combined transplant and death

#------
#standard Kaplan-Meier analysis and basic plot
km=survfit(Surv(time,status)~trt,data=dat)
plot(km)

#------
#list of unique event and censoring times
utime=c(0,sort(unique(dat$time))) #302 unique times

#------
#Kaplan-Meier analysis: to get data in form for plot.
#trt=1: active treatment, trt=2: placebo

#KM for events
km.0=survfit(Surv(time,status)~1,data=dat[dat$trt==2,])
km.1=survfit(Surv(time,status)~1,data=dat[dat$trt==1,])
kmsumm.0=summary(km.0,times=utime,extend=T)
kmsumm.1=summary(km.1,times=utime,extend=T)

#data used to create plot
kmplot.dat=data.frame(time=utime,surv.0=kmsumm.0$surv,surv.1=kmsumm.1$surv,
                      ci0.lower=kmsumm.0$lower,ci0.upper=kmsumm.0$upper,
                      ci1.lower=kmsumm.1$lower,ci1.upper=kmsumm.1$upper)

#-------
#numbers for table to go underneath the plot

display.times=seq(0,12,1)

kmtable.dat=data.frame(time=display.times,
                       nrisk.0=sapply(display.times,FUN=function(x){sum(dat$time[dat$trt==2]>=x)}),
                       nrisk.1=sapply(display.times,FUN=function(x){sum(dat$time[dat$trt==1]>=x)}),
                       ncens.0=sapply(display.times,FUN=function(x){sum(dat$time[dat$trt==2 & dat$status==0]<x)}),
                       ncens.1=sapply(display.times,FUN=function(x){sum(dat$time[dat$trt==1 & dat$status==0]<x)}),
                       nevent.0=sapply(display.times,FUN=function(x){sum(dat$time[dat$trt==2 & dat$status==1]<x)}),
                       nevent.1=sapply(display.times,FUN=function(x){sum(dat$time[dat$trt==1 & dat$status==1]<x)}))

#------
#kaplan-meier plot using ggplot

#first define fuctions used to add lines and CIs to plot
addlinetoplot.lty <- function(dataset, varx, vary,vcol,vline) { 
  list(
    geom_step(data=dataset, aes_string(x=varx, y=vary,colour=vcol,linetype=vline),size=1) 
  )
}

addribbontoplot <- function(dataset, varymin, varymax,vcolour,valpha) { 
  list(
    geom_stepribbon(data=dataset, aes_string(ymin=varymin, ymax=varymax),fill=vcolour,alpha=valpha)
  )
}

cols=c("research"="blue","control"="red")
lines=c("research"="solid","control"="dashed")

#now make the plot
survplot=ggplot(kmplot.dat,aes(x=time,y=surv.0))+
  ylab("Estimated survival")+xlab("Time in years")+
  scale_x_continuous(breaks=seq(0,12,1),limits=c(0,12.5),expand = c(0.01, 0))+
  #scale_y_continuous(breaks=seq(0,1,0.2),limits=c(0,1),expand = c(0, 0.1))+
  scale_y_continuous(breaks=c(0,0.001,0.2,0.4,0.6,0.8,1),limits=c(0,1),expand = c(0, 0.1),
                     labels = c(0.0,"Research",0.2,0.4,0.6,0.8,1))+
  addlinetoplot.lty(kmplot.dat,"time","surv.0",vcol='"control"',vline='"control"')+
  addlinetoplot.lty(kmplot.dat,"time","surv.1",vcol='"research"',vline='"research"')+
  addribbontoplot(kmplot.dat,varymin="ci0.lower",varymax="ci0.upper",vcolour="red", valpha=0.2)+
  addribbontoplot(kmplot.dat,varymin="ci1.lower",varymax="ci1.upper",vcolour="blue", valpha=0.2)+
  scale_colour_manual(NULL,values=cols,labels=c(control="Control",research="Research"),breaks=c("control","research"))+
  scale_linetype_manual(NULL,values=lines,labels=c(control="Control",research="Research"),breaks=c("control","research"))+
  theme(axis.text.x = element_text(size = 10),
        axis.title.x = element_text(size = 10),axis.title.y = element_text(size = 10),legend.text=element_text(size = 10))+
  theme(legend.position=c(0.8,0.85))+
  theme(panel.border = element_blank(),panel.grid.major.x = element_blank(), panel.grid.major.y = element_line(colour="grey", size=0.3),panel.background = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_blank(),
        axis.ticks=element_blank())+
  theme(legend.key.width = unit(1, "cm"))+
  theme(legend.key = element_rect(colour = "transparent", fill = "transparent"),
        legend.background =element_rect(fill = "transparent") )+
  theme(axis.text.y = element_text(size=10, face=c("plain","bold","plain","plain","plain","plain","plain"), 
                                   colour = c("black","transparent","black","black","black","black","black")))+
  theme(axis.title.y = element_text(vjust = -5))
  
#------
#table to put underneath KM plot

survtable=ggplot(kmplot.dat,aes(x=time,y=surv.0))+
  ylab("")+xlab("")+
  scale_x_continuous(breaks=seq(0,12,1),limits=c(0,12.5),expand = c(0.01, 0))+
  # scale_y_continuous(breaks=seq(0,1,0.2),limits=c(0,1),expand = c(0, 0.1))+
  scale_y_continuous(breaks=seq(0,0.7,0.1),limits=c(0,0.7),expand = c(0, 0.1),
                     labels = c("Events","Censored","At risk","Research",
                                "Events","Censored","At risk","Control"))+
  theme(panel.border = element_blank(),panel.grid.major = element_blank(),panel.background = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_blank(),
        axis.ticks=element_blank(),axis.text.x=element_text(colour = "transparent"),
        axis.text.y = element_text(size=8, face=c("plain","plain","plain","bold"), colour = "black"))+
  annotate("text", x = display.times+0.15, y = 0.6, label = paste(kmtable.dat$nrisk.0),size=3)+
  annotate("text", x = display.times+0.15, y = 0.5, label = paste(kmtable.dat$ncens.0),size=3)+
  annotate("text", x = display.times+0.15, y = 0.4, label = paste(kmtable.dat$nevent.0),size=3)+
  annotate("text", x = display.times+0.15, y = 0.2, label = paste(kmtable.dat$nrisk.1),size=3)+
  annotate("text", x = display.times+0.15, y = 0.1, label = paste(kmtable.dat$ncens.1),size=3)+
  annotate("text", x = display.times+0.15, y = 0, label = paste(kmtable.dat$nevent.1),size=3)
  
#-----
#combine plot and table

Layout <- grid.layout(nrow = 2, ncol = 1, heights = unit(c(1.5, 1), c("null", "null")))

grid.show.layout(Layout)

vplayout <- function() {
  grid.newpage()
  pushViewport(viewport(layout = Layout))
}

subplot <- function(x, y) viewport(layout.pos.row = x,layout.pos.col = y)

mmplot <- function(a, b) {
  vplayout()
  print(a, vp = subplot(1, 1))
  print(b, vp = subplot(2, 1))
}

windows(7,5)
mmplot(survplot, survtable)









