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

model.list <- list()
for(model.i in 1:nrow(end.mat)){
  for(segment.i in 1:model.i){
    model.list[[paste(model.i, segment.i)]] <-
      data.table(model.i, segment.i)
  }
}

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

ggplot()+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    fill=annotation),
                data=some.regions,
                color="grey",
                alpha=0.5)+
  scale_x_continuous("position on chr1 (kilo bases = kb)")+
  ylab("")+
  geom_point(aes(chromStart/1e3, count, group=read.type),
             data=some.tall,
             pch=1)+
  geom_line(aes(chromStart/1e3, count, group=read.type),
            data=some.tall)
