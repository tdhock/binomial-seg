works_with_R("3.1.2",
             "hadley/tidyr@3de52c46f12d0d4cba603aa4e63e39f2370a9cfd",
             "tdhock/ggplot2@aac38b6c48c016c88123208d497d896864e74bd7",
             "tdhock/animint@150bb744e3aab96c43a3ff9e996ec241d44a6bd5",
             data.table="1.9.4",
             BinomSeg="2015.1.5")

load("public.small.RData")

from <- 840000
to <- 960000

from <- 870000
to <- 910000

some.sites <-
  public.small$sites[from < chromStart &
                     chromStart < to, ]
some.sites[, percent.methylated := methylated/total * 100]

some.regions <-
  public.small$regions[from < chromStart &
                       chromStart < to, ]

fit <- with(some.sites, {
  BinomSeg_(methylated, unmethylated, rep(1, length(methylated)), 
            Kmax=20L)
})
end.mat <- getPath(fit)

some.tall <- 
  gather(some.sites, read.type, count,
         percent.methylated, total)

ggplot()+
  geom_point(aes(136, 0))+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    fill=annotation),
                data=public.small$regions)

percent.total <- 
ggplot()+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    fill=annotation),
                data=some.regions,
                color="grey",
                alpha=0.5)+
  scale_x_continuous("position on chr1 (kilo bases = kb)")+
  ylab("")+
  geom_point(aes(chromStart/1e3, count),
             data=some.tall,
             pch=1)+
  geom_line(aes(chromStart/1e3, count),
            data=some.tall)+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(read.type ~ ., scales="free")

pdf("figure-public-small-data.pdf")
print(percent.total)
dev.off()

seg.list <- list()
brk.list <- list()
models <- 1:nrow(end.mat)
models <- c(10, 15, 20)
for(model.i in models){
  ends <- end.mat[model.i, 1:model.i]
  breaks <- ends[-length(ends)]
  starts <- c(1, breaks+1)
  for(segment.i in 1:model.i){
    start <- starts[[segment.i]]
    end <- ends[[segment.i]]
    seg.data <- some.sites[start:end, ]
    seg.prop <- with(seg.data, sum(methylated)/sum(total))
    seg.list[[paste(model.i, segment.i)]] <-
      data.table(model.i, segment.i, seg.prop,
                 start,
                 end,
                 chromStart=seg.data$chromStart[1],
                 chromEnd=seg.data$chromEnd[nrow(seg.data)])
  }
  if(length(breaks)){
    brk.list[[paste(model.i)]] <-
      data.table(model.i, break.is.before=breaks,
                 chromStart=some.sites$chromEnd[breaks-1],
                 chromEnd=some.sites$chromStart[breaks])
  }
}
segs <- do.call(rbind, seg.list)
brks <- do.call(rbind, brk.list)

modelsPlot <- 
ggplot()+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    fill=annotation),
                data=some.regions,
                color="grey",
                alpha=0.5)+
  scale_x_continuous("position on chr1 (kilo bases = kb)")+
  ylab("")+
  geom_point(aes(chromStart/1e3, percent.methylated),
             data=some.sites,
             color="grey50",
             pch=1)+
  geom_line(aes(chromStart/1e3, percent.methylated),
            color="grey50",
            data=some.sites)+
  geom_segment(aes(chromStart/1e3, seg.prop * 100,
                   xend=chromEnd/1e3, yend=seg.prop * 100),
               data=segs)+
  geom_vline(aes(xintercept=(chromStart+chromEnd)/2/1e3),
             data=brks, linetype="dashed")+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(model.i ~ .)

pdf("figure-public-small.pdf")
print(modelsPlot)
dev.off()

