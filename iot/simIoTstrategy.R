#can building a platform to enable smarter, more efficient household appliances
#be a winning business model strategy?

#read the businessmodel file for analysis
strategy <- read.csv("iot.businessmodel.csv")


#calculate the differences that represent competition in different areas
#of the business model
strategy$d.cns <- strategy$cns1 - strategy$cns2
strategy$d.pcn <- strategy$pcn1 - strategy$pcn2
strategy$d.inv <- strategy$inv1 - strategy$inv2
strategy$d.imt <- strategy$imt1 - strategy$imt2
strategy$d.ped <- strategy$ped1 - strategy$ped2
strategy$d.oe <- strategy$oe1 - strategy$oe2
strategy$d.cpex <- strategy$cpex1 - strategy$cpex2
strategy$d.pro <- strategy$pro1 - strategy$pro2
strategy$d.ikp <- strategy$ikp1 - strategy$ikp2

#rename the variables to correspond to the IoT platform strategy
cols <- c("competitor number of subscribers", "number of subscribers",
          "competitor potential subscribers", "potential subscribers",
          "competitor innovative features", "innovative features",
          "competitor subscriber ecosystem strength", "subscriber ecosystem strength",
          "competitor necessity to subscribers", "necessity to subscribers",
          "competitor platform scalability", "platform scalability",
          "competitor capital investment", "capital investment",
          "competitor feature release cycle time", "feature release cycle time",
          "competitor platform service provider capability", "platform service provider capability",
          "fitness",
          "competitor advantage in subscribers",
          "competitor advantage in potential subscribers",
          "competitor advantage in innovative features", 
          "competitor advantage in subscriber ecosystem strength",
          "competitor advantage in necessity to subscribers", 
          "competitor advantage in platform scalability",
          "competitor advantage in capital investment", 
          "competitor advantage in feature release cycle time",
          "competitor advantage in platform service provider capability")
colnames(strategy) <- cols

#discretize all values so that we can create association rules
ranges <- c("1-Very Low", "2-Low", "3-Medium", "4-High", "5-Very High")
for(i in 1:ncol(strategy)){
  strategy[,i] <- cut(strategy[,i], breaks=5, labels = ranges)
}

#write out the iot strategy for additional analysis
write.csv(strategy, file="iot.strategy.csv", row.names=FALSE)

#overall is this a winning strategy?
barplot(table(strategy$fitness))

#find circumstances that lead to a lossing strategy
library(arules)
strategy.lose.rules <- apriori(strategy, control = list(verbose=F),
                               parameter = list(minlen=2, supp=0.04, conf=0.85),
                               appearance = list(rhs=c("fitness=1-Very Low"),
                                                 default="lhs"))
#find redundant strategy rules
subset.matrix <- is.subset(strategy.lose.rules, strategy.lose.rules)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant strategy rules
strategy.lose.rules.pruned <- strategy.lose.rules[!redundant]
inspect(strategy.lose.rules.pruned)

#visualize observation rules
#install.packages("arulesViz")
library(arulesViz)
plot(strategy.lose.rules.pruned, method="graph", control=list(type="items"))

#find circumstances that lead to a winning strategy
strategy.win.rules <- apriori(strategy, control = list(verbose=F),
                               parameter = list(minlen=2, supp=0.04, conf=0.85),
                               appearance = list(rhs=c("fitness=5-Very High"),
                                                 default="lhs"))
#find redundant strategy rules
subset.matrix <- is.subset(strategy.win.rules, strategy.win.rules)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant strategy rules
strategy.win.rules.pruned <- strategy.win.rules[!redundant]
inspect(strategy.win.rules.pruned)

#viaualize strategy rules
plot(strategy.win.rules.pruned, method="graph", control=list(type="items"))
