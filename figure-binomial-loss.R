works_with_R("3.1.2",
             "tdhock/ggplot2@aac38b6c48c016c88123208d497d896864e74bd7")

models <-
  data.frame(total.reads=c(10, 100, 10, 100),
             methylated.reads=c(5, 50, 3, 30))

loss <- function(prob, total, methylated){
  (methylated-total)*log(1-prob) - methylated*log(prob)
}  

curve.list <- list()
best.list <- list()
line.list <- list()
for(model.i in 1:nrow(models)){
  model <- models[model.i, ]
  methylation.probability <- seq(0, 1, l=201)
  binomial.loss <- with(model, {
    loss(methylation.probability, total.reads, methylated.reads)
  })
  estimated.probability <- with(model, methylated.reads/total.reads)
  best.loss <- with(model, {
    loss(estimated.probability, total.reads, methylated.reads)
  })
  meta <- data.frame(model, estimated.probability)
  best.list[[model.i]] <-
    data.frame(meta, best.loss)
  line.list[[model.i]] <- with(model, {
    data.frame(meta,
               binomial.loss=best.loss + methylated.reads * c(-1, 0, 1),
               intersection.points=factor(c("0", "1", "2"),
                 c("2", "1", "0")),
               row.names=NULL)
  })
  curve.list[[model.i]] <-
    data.frame(meta, binomial.loss,
               methylation.probability,
               row.names=NULL)
}

hlines <- do.call(rbind, line.list)
curves <- do.call(rbind, curve.list)
best <- do.call(rbind, best.list)

bloss <- 
ggplot()+
  geom_hline(aes(yintercept=binomial.loss, color=intersection.points),
             data=hlines, show_guide=TRUE)+
  scale_color_discrete("intersection\npoints")+
  geom_line(aes(methylation.probability, binomial.loss),
            data=curves)+
  geom_point(aes(estimated.probability, best.loss),
             data=best)+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(total.reads ~ estimated.probability,
             scales="free", labeller=label_both)

pdf("figure-binomial-loss.pdf", h=4)
print(bloss)
dev.off()
