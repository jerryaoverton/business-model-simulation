#can a corporation improve a community?


#read the universe of simulated business models
models <- read.csv("sim1.csv")

#select a subset of the models that corresponds to the strategy of
#using existing social networks to accelareate the creation of a brand

#the strategy is modeled after the open business model. the idea is to
#build brand taping into social networks interested in public service.
#this strategy increases both the reach of the brand and the network
#effect of the consumers. We model the strategy with the assumption of
#higher potential consumers and high coefficients of imitation

businessmodel <- models[models$pcn2 > 65,]
businessmodel <- businessmodel[businessmodel$imt2 > .75,]

#remove the unnecessary id column
businessmodel$X <- NULL

#store the strategy file for subsequent analysis
write.csv(businessmodel, file="smartcity.businessmodel.csv", row.names=FALSE)
