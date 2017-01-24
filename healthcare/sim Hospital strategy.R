#What if a hospital were willing to make comprehensive changes in how it 
#treats and interacts with patients? 

#read the strategy file for analysis
strategy <- read.csv("hospital.businessmodel.csv")

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
cols <- c("alternative care provider number of patients", "number of patients",
          "alternative care provider patient capacity", "patient capacity",
          "alternative care provider innovative services", "innovative services",
          "alternative care provider patient advocacy", "patient advocacy",
          "alternative care provider chronic care services", "chronic care services",
          "alternative care provider staff efficiency", "staff efficiency",
          "alternative care provider capital investment", "capital investment",
          "alternative care provider time to innovation", "time to innovation",
          "alternative care provider tech ecosystem innovation", "tech ecosystem innovation",
          "fitness",
          "alternative care provider advantage in number of patients",
          "alternative care provider advantage in patient capacity",
          "alternative care provider advantage in innovative features", 
          "alternative care provider advantage in patient advocacy",
          "alternative care provider advantage in chronic care services", 
          "alternative care provider advantage in staff efficiency",
          "alternative care provider advantage in capital investment", 
          "alternative care provider advantage in time to innovation",
          "alternative care provider advantage in tech ecosystem innovation")
colnames(strategy) <- cols

#discretize all values so that we can create association rules
ranges <- c("1-Very Low", "2-Low", "3-Medium", "4-High", "5-Very High")
for(i in 1:ncol(strategy)){
  strategy[,i] <- cut(strategy[,i], breaks=5, labels = ranges)
}

#overall is this a winning strategy?
barplot(table(strategy$fitness))

#write out the hospital strategy for additional analysis
write.csv(strategy, file="hospital.strategy.csv", row.names=FALSE)

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

#find winning strategies when the alternative healthcare provider has a high
#advantage in potential customers
strategy.scenario1 <- strategy[strategy$`alternative care provider advantage in patient capacity` == "5-Very High",]
strategy.scenario1$`alternative care provider advantage in patient capacity` <- NULL

#given the scenario, find the rules that lead to a win
rules <- apriori(strategy.scenario1, control = list(verbose=F),
                 parameter = list(minlen=2, supp=0.06, conf=0.9),
                 appearance = list(rhs=c("fitness=5-Very High"), 
                                   default="lhs"))

#sort the rules by lift
rules.sorted <- sort(rules, by="lift")

# find redundant rules
subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

# remove redundant rules
rules.pruned <- rules.sorted[!redundant]
inspect(rules.pruned)

#plot the rules
library(arulesViz)
plot(rules.pruned, method="paracoord", control=list(reorder=TRUE))
