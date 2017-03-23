#simulate new possibilites for a smarter city

#read observed citizen behavior data
citizen <- read.csv("atussum_2015.csv")
activities <- citizen[,25:411]

#find only those features important to high levels of volunteerism
library(FSelector)
att.scores <- information.gain(t159999 ~ ., activities)
features <- cutoff.k(att.scores, 7)
features

#narrow down the columns to contain only important features
cols <- c(features, "t159999")
activities.sub <- activities[,cols]

#create a correlation matrix that will be used to guide simulation
activities.cor <- cor(activities.sub)

#start the simulation as a set of random, guaussian variable 
#correlated according to the matrix
require(mvtnorm)
simulation_runs = 1000000 #1 million people
number_of_features = 8
feature_means <- rep(0,number_of_features)
activities.sub.sim <- rmvnorm(mean=feature_means,sig=activities.cor,n=simulation_runs)

#rename the simulation variables to match the observations
colnames(activities.sub.sim) <- colnames(activities.sub)

#convert the simulation variables to a uniform distribution
activities.sub.sim <- pnorm(activities.sub.sim)
activities.sub.sim <- as.data.frame(activities.sub.sim)

#determine the distribution of each observed variable
#install.packages("fitdistrplus")
library(fitdistrplus)
descdist(activities.sub[,1], discrete = FALSE) #beta
descdist(activities.sub[,2], discrete = FALSE) #beta
descdist(activities.sub[,3], discrete = FALSE) #beta
descdist(activities.sub[,4], discrete = FALSE) #beta
descdist(activities.sub[,5], discrete = FALSE) #beta
descdist(activities.sub[,6], discrete = FALSE) #beta
descdist(activities.sub[,7], discrete = FALSE) #beta
descdist(activities.sub[,8], discrete = FALSE) #beta

#fit all simulated activities to a beta distribution
library(scales)
for (i in 1: ncol(activities.sub.sim)){
  parm <- fitdist(rescale(activities.sub[,i],c(0.01,.99)),"beta")
  activities.sub.sim[,i] <- qbeta(activities.sub.sim[,i],
                              shape1 = parm$estimate[1],
                              shape2 = parm$estimate[2])
  #rescale the simulation data to match the scale of the observations
  activities.sub.sim[,i] <- rescale(activities.sub.sim[,i],
                                c(min(activities.sub[,i]),
                                  max(activities.sub[,i]))
  )
}

#compare the distributions of observed activities to simulated activities
hist(activities.sub[,5])
hist(activities.sub.sim[,5])

hist(activities.sub[,2])
hist(activities.sub.sim[,2])

hist(activities.sub[,6])
hist(activities.sub.sim[,6])

#discretize observed and simulated activities so that we can create association rules
#for both
ranges <- c("Very Low", "Low", "Medium", "High", "Very High")
for(i in 1:ncol(activities.sub)){
  activities.sub[,i] <- cut(activities.sub[,i], breaks=5, labels = ranges)
  activities.sub.sim[,i] <- cut(activities.sub.sim[,i], breaks=5, labels = ranges)
}

#find observation association rules that result in high volunteerism
library(arules)
rules.obs <- apriori(activities.sub, control = list(verbose=F),
                 parameter = list(minlen=2, supp=0.001, conf=0.001), 
                 appearance = list(rhs=c("t159999=Medium"), 
                                   default="lhs"))
inspect(rules.obs)

#find redundant observation rules
subset.matrix <- is.subset(rules.obs, rules.obs)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant observation rules
rules.obs.pruned <- rules.obs[!redundant]

#visualize simulation rules
#install.packages("arulesViz")
library(arulesViz)
plot(rules.obs.pruned, method="graph")

#find simulation association rules that result in high volunteerism
rules.sim <- apriori(activities.sub.sim, control = list(verbose=F),
                     parameter = list(minlen=2, supp=0.001, conf=0.001), 
                     appearance = list(rhs=c("t159999=Medium"), 
                                       default="lhs"))
inspect(rules.sim)

#find redundant simulation rules
subset.matrix <- is.subset(rules.sim, rules.sim)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant simulation rules
rules.sim.pruned <- rules.sim[!redundant]

#visualize simulation rules
plot(rules.sim.pruned, method="graph")
