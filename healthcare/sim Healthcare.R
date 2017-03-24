#read healthcare data
health <- read.csv("data.health.csv")

#remove the features that impede subsequent analysis
health$Address <- NULL
health$Hospital.Name <- NULL
health$ZIP.Code <- NULL
health$Location <- NULL
health$City <- NULL
health$Overall.Rating.of.Hospital.Dimension.Score <- NULL
health$County.Name <- NULL
health$HCAHPS.Base.Score <- NULL
health$HCAHPS.Consistency.Score <- NULL
health$State <- NULL
health$Provider.Number <- NULL
health$Overall.Rating.of.Hospital.Improvement.Points <- NULL
health$Communication.with.Nurses.Dimension.Score <- NULL
health$Pain.Management.Dimension.Score <- NULL
health$Cleanliness.and.Quietness.of.Hospital.Environment.Dimension.Score <- NULL
health$Communication.about.Medicines.Dimension.Score <- NULL
health$Discharge.Information.Dimension.Score <- NULL
health$Responsiveness.of.Hospital.Staff.Dimension.Score <- NULL
health$Communication.with.Doctors.Dimension.Score <- NULL


#Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.8.0_121')
#library(rJava)

#find only those features important to high levels of overall healthcare satisfaction
#install.packages("FSelector")
library(FSelector)
att.scores <- information.gain(Overall..Rating.of.Hospital.Achievement.Points ~ ., health)
features <- cutoff.k(att.scores, 7)
features

#narrow down the columns to contain only important features
cols <- c(features, "Overall..Rating.of.Hospital.Achievement.Points")
xp <- health[,cols]

#rename the columns so that they display better
cols <- c("Nurse.Communication","Pain.Management","Medicine.Communication",
          "Hospital.Cleanliness.and.Quietness","Hospital.Staff.Responsiveness",
          "Doctor.Communication","Discharge.Information","Overall.Rating")
colnames(xp) <- cols

#create a correlation matrix that will be used to guide simulation
xp.cor <- cor(xp)

#start the simulation as a set of random, guaussian variable 
#correlated according to the matrix
require(mvtnorm)
simulation_runs = 3000
number_of_features = 8
feature_means <- rep(0,number_of_features)
xp.sim <- rmvnorm(mean=feature_means,sig=xp.cor,n=simulation_runs)

#rename the simulation variables to match the observations
colnames(xp.sim) <- cols

#convert the simulation variables to a uniform distribution
xp.sim <- pnorm(xp.sim)
xp.sim <- as.data.frame(xp.sim)

#determine the distribution of each observed variable
#install.packages("fitdistrplus")
library(fitdistrplus)
descdist(xp[,1], discrete = FALSE) #beta
descdist(xp[,2], discrete = FALSE) #beta
descdist(xp[,3], discrete = FALSE) #beta
descdist(xp[,4], discrete = FALSE) #beta
descdist(xp[,5], discrete = FALSE) #beta
descdist(xp[,6], discrete = FALSE) #beta
descdist(xp[,7], discrete = FALSE) #beta
descdist(xp[,8], discrete = FALSE) #beta

#fit all simulated activities to a beta distribution
library(scales)
for (i in 1: ncol(xp.sim)){
  parm <- fitdist(rescale(xp[,i],c(0.01,.99)),"beta")
  xp.sim[,i] <- qbeta(xp.sim[,i],
                      shape1 = parm$estimate[1],
                      shape2 = parm$estimate[2])
  #rescale the simulation data to match the scale of the observations
  xp.sim[,i] <- rescale(xp.sim[,i],c(min(xp[,i]),max(xp[,i]))
  )
}

#compare the distributions of the observed healthcare experiences to the simulations
hist(xp$Doctor.Communication)
hist(xp.sim$Doctor.Communication)

hist(xp$Nurse.Communication)
hist(xp.sim$Nurse.Communication)

hist(xp$Hospital.Cleanliness.and.Quietness)
hist(xp.sim$Hospital.Cleanliness.and.Quietness)

#discretize observed and simulated activities so that we can create association rules
#for both
ranges <- c("Poor", "Acceptable", "Great")
for(i in 1:ncol(xp)){
  xp[,i] <- cut(xp[,i], breaks=3, labels = ranges)
  xp.sim[,i] <- cut(xp.sim[,i], breaks=3, labels = ranges)
}

#write the simulations to file for further analysis
write.csv(xp.sim, file="healthcare.sim.csv", row.names=FALSE)

#build a decision tree and use it to predict the factors that lead to positive experiences in both
#the observations and in simulation
library(party)
formula <- Overall.Rating ~ .
xp.tree <- ctree(formula, controls = ctree_control(maxdepth = 3), data=xp)
xp.sim.tree  <- ctree(formula, controls = ctree_control(maxdepth = 3),data=xp.sim)

#plot the tree
plot(xp.tree)
plot(xp.sim.tree)
