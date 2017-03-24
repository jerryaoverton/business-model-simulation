#is creating new, innovative breeds of iris a winning strategy?

#read the strategy file for analysis
strategy <- read.csv("iris.businessmodel.csv")

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

#rename the variables to correspond to the iris strategy
cols <- c("competitor number of customers", "number of customers",
          "competitor potential customers", "potential customers",
          "competitor innovation", "innovation",
          "competitor organic growth", "organic growth",
          "competitor flowers replacability", "flowers replacability",
          "competitor returns to scale", "returns to scale",
          "competitor capital investment", "capital investment",
          "competitor days to plant maturity", "days to plant maturity",
          "competitor floriculturist innovation", "floriculturist innovation",
          "fitness",
          "competitor advantage in customers",
          "competitor advantage in potential customers",
          "competitor advantage in innovation", 
          "competitor advantage in organic growth",
          "competitor advantage in flowers replacability", 
          "competitor advantage in returns to scale",
          "competitor advantage in capital investment", 
          "competitor advantage in days to plant maturity",
          "competitor advantage in floriculturist innovation")
colnames(strategy) <- cols

#assume that the difference in potential customers is small
#strategy <- strategy[strategy$`competitor advantage in potential customers` < 2,]
#strategy <- strategy[strategy$`competitor advantage in potential customers` > -2,]

#discretize all values so that we can create association rules
ranges <- c("1-Very Low", "2-Low", "3-Medium", "4-High", "5-Very High")
for(i in 1:ncol(strategy)){
  strategy[,i] <- cut(strategy[,i], breaks=5, labels = ranges)
}

#write out the strategy for additional analysis
write.csv(strategy, file="iris.strategy.csv", row.names=FALSE)

#overall is this a winning strategy?
barplot(table(strategy$fitness))

#find association rules that result in low or very low fitness
library(arules)
strategy.rules <- apriori(strategy, control = list(verbose=F),
                          parameter = list(minlen=2, supp=0.05, conf=0.60),
                          appearance = list(rhs=c("fitness=1-Very Low"),
                                            default="lhs"))
inspect(strategy.rules)

#find redundant association rules
subset.matrix <- is.subset(strategy.rules, strategy.rules)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant observation rules
strategy.rules.pruned <- strategy.rules[!redundant]
inspect(strategy.rules.pruned)

#viaualize observation rules
#install.packages("arulesViz")
library(arulesViz)
plot(strategy.rules.pruned, method="paracoord", control=list(reorder=TRUE))
