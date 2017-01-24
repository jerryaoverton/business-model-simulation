#Can a corporation improve a community?

#read the strategy file for analysis
strategy <- read.csv("smartcity.businessmodel.csv")

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
cols <- c("competitor number of consumers", "number of consumers",
          "competitor potential consumers", "potential consumers",
          "competitor product innovation", "product innovation",
          "competitor consumer advocacy", "consumer advocacy",
          "competitor necessity to consumers", "necessity to consumers",
          "competitor operational efficiency", "operational efficiency",
          "competitor capital investment", "capital investment",
          "competitor time to innovation", "time to innovation",
          "competitor key partner efficiency", "key partner efficiency",
          "fitness",
          "competitor advantage in number of consumers",
          "competitor advantage in potential consumers",
          "competitor advantage in product innovation", 
          "competitor advantage in consumer advocacy",
          "competitor advantage in necessity to consumers", 
          "competitor advantage in operational efficiency",
          "competitor advantage in capital investment", 
          "competitor advantage in time to innovation",
          "competitor advantage in key partner efficiency")
colnames(strategy) <- cols

#discretize all values so that we can create association rules
ranges <- c("1-Very Low", "2-Low", "3-Medium", "4-High", "5-Very High")
for(i in 1:ncol(strategy)){
  strategy[,i] <- cut(strategy[,i], breaks=5, labels = ranges)
}

#write out the smart city strategy for additional analysis
write.csv(strategy, file="smartcity.strategy.csv", row.names=FALSE)

#overall is this a winning strategy?
barplot(table(strategy$fitness))

#find circumstances that lead to a losing strategy
library(arules)
strategy.lose.rules <- apriori(strategy, control = list(verbose=F),
                               parameter = list(minlen=2, supp=0.04, conf=0.45),
                               appearance = list(rhs=c("fitness=1-Very Low"),
                                                 default="lhs"))
inspect(strategy.lose.rules)

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
plot(strategy.lose.rules.pruned, method="paracoord")

#find winning strategies when the competitor potential consumers and advantage in
#potential consumers is high
strategy.scenario1 <- strategy[strategy$`competitor potential consumers` == "4-High",]
strategy.scenario1 <- strategy.scenario1[strategy.scenario1$`competitor advantage in potential consumers` == "4-High",]

#given the scenario, find the strategies that lead to a win
library(party)
formula <- fitness ~ .
dtree <- ctree(formula, data=strategy.scenario1, controls = ctree_control(maxdepth = 2))
plot(dtree)
