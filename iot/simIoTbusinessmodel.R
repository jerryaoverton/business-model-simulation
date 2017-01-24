#can building a platform to enable smarter, more efficient household appliances
#be a winning business model strategy?

#read the universe of simulated business models
models <- read.csv("sim1.csv")

#select a subset of the models that corresponds to the strategy of
#building a platform for enabling smarter, more efficient household appliances

#the strategy is modeled after the multi-sided platform pattern. the idea
#is to connect home automation customers with utility customers. the biggest
#benefit of the multi-sided platform model is the network effect that comes
#from bringing together new customer segments. we model our strategy based on
#the assumption of a high network effect
businessmodel <- models[models$imt2 > .7,]

#we also assume that the platform is designed specifically to optimize the
#energy consumption of the appliances. this allows us to position the application
#as an energy product which increases the application's elasticity of demand.
#that is, because we are optimizing something as important as energy consumption
#we assume that consumers will be tolerant to a higher degree of price increase
businessmodel <- businessmodel[businessmodel$ped2 > 1.4,]

#remove the unnecessary id column
businessmodel$X <- NULL

#store the strategy file for subsequent analysis
write.csv(businessmodel, file="iot.businessmodel.csv", row.names=FALSE)
