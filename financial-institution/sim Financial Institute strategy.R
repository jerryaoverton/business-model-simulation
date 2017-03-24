#What if a financial institution were willing to make comprehensive changes to 
#the services they provide to customers?

#read the strategy file for analysis
strategy <- read.csv("financial.institute.businessmodel.csv")

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

#rename the variables to correspond to the new offering strategy
cols <- c("competitor loan customers", "loan customers",
          "competitor potential loan customers", "potential loan customers",
          "competitor repayment options", "repayment options",
          "competitor customer advocacy", "customer advocacy",
          "competitor necessity to customers", "necessity to customers",
          "competitor returns to scale", "returns to scale",
          "competitor capital investment", "capital investment",
          "competitor time to new services", "time to new services",
          "competitor partner network efficiency", "employer network efficiency",
          "fitness",
          "competitor advantage in loan customers",
          "competitor advantage in potential loan customers",
          "competitor advantage in repayment options", 
          "competitor advantage in customer advocacy",
          "competitor advantage in necessity to customers", 
          "competitor advantage in returns to scale",
          "competitor advantage in capital investment", 
          "competitor advantage in time to new services",
          "competitor advantage in partner network efficiency")
colnames(strategy) <- cols

#discretize all values so that we can create association rules
ranges <- c("1-Very Low", "2-Low", "3-Medium", "4-High", "5-Very High")
for(i in 1:ncol(strategy)){
  strategy[,i] <- cut(strategy[,i], breaks=5, labels = ranges)
}

#write out the hospital strategy for additional analysis
write.csv(strategy, file="financial.institute.strategy.csv", row.names=FALSE)

#overall is this a winning strategy?
barplot(table(strategy$fitness))

#find circumstances that lead to a losing strategy
library(arules)
strategy.lose.rules <- apriori(strategy, control = list(verbose=F),
                               parameter = list(minlen=2, supp=0.035, conf=0.45),
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

#find winning strategies when the competitor advantage in potential consumers is high
strategy.scenario1 <- strategy[strategy$`competitor advantage in potential loan customers` == "4-High",]

#given the scenario, find the strategies that lead to a win
library(party)
formula <- fitness ~ .
dtree <- ctree(formula, data=strategy.scenario1, controls = ctree_control(maxdepth = 2))
plot(dtree)
