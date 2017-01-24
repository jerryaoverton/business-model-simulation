#Simulate collective power consumption by household devices

#read real household power consumption data
iot <- read.csv("household_power_consumption.csv", sep = ";")

#remove missing values
iot <- iot[complete.cases(iot),]

#refine the column names
names(iot)[names(iot)=="Sub_metering_1"] <- "kitchen_appliances"
names(iot)[names(iot)=="Sub_metering_2"] <- "laundry_room_appliances"
names(iot)[names(iot)=="Sub_metering_3"] <- "water_heater"


#convert the time field to an integer that counts seconds past midnight 
iot$Time <- as.numeric(
  as.POSIXct(iot$Time ,format="%H:%M:%S") - 
    as.POSIXct("00:00:00",format="%H:%M:%S")
)

#We won't need the date field for the analysis
iot$Date <- NULL

#convert all fields to numeric and create a correlation matrix from the data
iot <- as.data.frame(sapply(iot, as.numeric))
iot.cor <- cor(iot)

#start the simulation as a set of random, guaussian variable 
#correlated according to the matrix
#install.packages("mvtnorm")
require(mvtnorm)
simulation_runs = 2250000
number_of_features = 8
feature_means <- rep(0,number_of_features)
iot.sim <- rmvnorm(mean=feature_means,sig=iot.cor,n=simulation_runs)

#rename the simulation variables to match the observations
colnames(iot.sim) <- colnames(iot)

#convert the simulation variables to a uniform distribution
iot.sim <- pnorm(iot.sim)
iot.sim <- as.data.frame(iot.sim)

#determine the distribution of each observed variable
#install.packages("fitdistrplus")
library(fitdistrplus)
descdist(iot$Time, discrete = FALSE) #uniform
descdist(iot$Global_active_power, discrete = FALSE) #beta
descdist(iot$Global_reactive_power, discrete = FALSE) #gamma
descdist(iot$Voltage, discrete = FALSE) #normal
descdist(iot$Global_intensity, discrete = FALSE) #beta
descdist(iot$kitchen_appliances, discrete = FALSE) #beta
descdist(iot$laundry_room_appliances, discrete = FALSE) #beta
descdist(iot$water_heater, discrete = FALSE) #beta

#fit global active power to a beta distribution
#install.packages("scales")
library(scales)
parm <- fitdist(rescale(iot$Global_active_power,c(0.01,.99)),"beta")
iot.sim$Global_active_power <- qbeta(iot.sim$Global_active_power,
                                     shape1 = parm$estimate[1],
                                     shape2 = parm$estimate[2])
#rescale the simulation data to match the scale of the observations
iot.sim$Global_active_power <- rescale(iot.sim$Global_active_power, 
                                       c(min(iot$Global_active_power),
                                         max(iot$Global_active_power))
                                       )
#compare the simulated data to the observed data
hist(iot$Global_active_power)
hist(iot.sim$Global_active_power)

#fit global reactive power to a gamma distribution
parm <- fitdist(iot$Global_reactive_power,"gamma")
iot.sim$Global_reactive_power <- qgamma(iot.sim$Global_reactive_power,
                                        shape = parm$estimate[1],
                                        rate = parm$estimate[2])
#compare the simulated data to the observed data
hist(iot$Global_reactive_power)
hist(iot.sim$Global_reactive_power)

#fit voltage to a normal distribution
parm <- fitdist(iot$Voltage,"norm")
iot.sim$Voltage <- qnorm(iot.sim$Voltage,
                          mean = parm$estimate[1],
                          sd = parm$estimate[2])
#compare the simulated data to the observed data
hist(iot$Voltage)
hist(iot.sim$Voltage)

#fit global intensity to a beta distribution
parm <- fitdist(rescale(iot$Global_intensity,c(0.01,.99)),"beta")
iot.sim$Global_intensity <- qbeta(iot.sim$Global_intensity,
                                  shape1 = parm$estimate[1],
                                  shape2 = parm$estimate[2])
#rescale the simulation data to match the scale of the observations
iot.sim$Global_intensity <- rescale(iot.sim$Global_intensity,
                                    c(min(iot$Global_intensity),
                                      max(iot$Global_intensity))
)
#compare the simulated data to the observed data
hist(iot$Global_intensity)
hist(iot.sim$Global_intensity)

#fit kitchen appliance to a beta distribution
parm <- fitdist(rescale(iot$kitchen_appliances,c(0.01,.99)),"beta")
iot.sim$kitchen_appliances <- qbeta(iot.sim$kitchen_appliances,
                                    shape1 = parm$estimate[1],
                                    shape2 = parm$estimate[2])
#rescale the simulation data to match the scale of the observations
iot.sim$kitchen_appliances <- rescale(iot.sim$kitchen_appliances,
                                    c(min(iot$kitchen_appliances),
                                      max(iot$kitchen_appliances))
)
#compare the simulated data to the observed data
hist(iot$kitchen_appliances)
hist(iot.sim$kitchen_appliances)

#fit laundry room appliance to a beta distribution
parm <- fitdist(rescale(iot$laundry_room_appliances,c(0.01,.99)),"beta")
iot.sim$laundry_room_appliances <- qbeta(iot.sim$laundry_room_appliances,
                                         shape1 = parm$estimate[1],
                                         shape2 = parm$estimate[2])
#rescale the simulation data to match the scale of the observations
iot.sim$laundry_room_appliances <- rescale(iot.sim$laundry_room_appliances,
                                           c(min(iot$laundry_room_appliances),
                                             max(iot$laundry_room_appliances))
)
#compare the simulated data to the observed data
hist(iot$laundry_room_appliances)
hist(iot.sim$laundry_room_appliances)

#fit water heater data to a beta distribution
parm <- fitdist(rescale(iot$water_heater,c(0.01,.99)),"beta")
iot.sim$water_heater <- qbeta(iot.sim$water_heater,
                              shape1 = parm$estimate[1],
                              shape2 = parm$estimate[2])
#rescale the simulation data to match the scale of the observations
iot.sim$water_heater <- rescale(iot.sim$water_heater,
                                c(min(iot$water_heater),
                                  max(iot$water_heater))
)
#compare the simulated data to the observed data
hist(iot$water_heater)
hist(iot.sim$water_heater)

#check the correlations of the observations and simulation
iot.sim.cor <- cor(iot.sim)
iot.cor
iot.sim.cor

#check the summary statistics of the observations and simulation
summary(iot)
summary(iot.sim)

#create a subset of the oberved and simulated data needed to generate
#association rules describing power consumption
cols <- c("Time", "Global_active_power",
          "kitchen_appliances", "laundry_room_appliances", 
          "water_heater")
iot <- iot[,cols]
iot.sim <- iot.sim[,cols]

#convert the numeric features into factors so that we can create association
#rules from the data

# discretize time
times_of_day <- c("Early Morning", "Morning", "After Noon", "Evening", 
                  "Night", "Late Night")
iot$Time <- cut(iot$Time, breaks = 6, labels = times_of_day)
iot.sim$Time  <- cut(iot.sim$Time, breaks = 6, labels = times_of_day)

#discretize global active power
ranges <- c("Very Low", "Low", "Medium", "High", "Very High")
iot$Global_active_power <- cut(iot$Global_active_power, breaks = 5, labels = ranges)
iot.sim$Global_active_power <- cut(iot.sim$Global_active_power, breaks = 5, labels = ranges)

#discretize kitchen appliances
iot$kitchen_appliances <- cut(iot$kitchen_appliances, breaks = 5, labels = ranges)
iot.sim$kitchen_appliances <- cut(iot.sim$kitchen_appliances, breaks = 5, labels = ranges)

#discretize laundry room appliances
iot$laundry_room_appliances <- cut(iot$laundry_room_appliances, breaks = 5, labels = ranges)
iot.sim$laundry_room_appliances <- cut(iot.sim$laundry_room_appliances, breaks = 5, labels = ranges)

#discretize water heater
iot$water_heater <- cut(iot$water_heater, breaks = 5, labels = ranges)
iot.sim$water_heater <- cut(iot.sim$water_heater, breaks = 5, labels = ranges)

#write the simulations to file for further analysis
write.csv(iot.sim, file="iot.sim.csv", row.names=FALSE)

#combine the simulations and observations into a single data set that can
#be analyzed for patterns
iot$source <- "observation"
iot.sim$source <- "sim"
iot.combined <- rbind(iot, iot.sim)
iot.combined$source <- as.factor(iot.combined$source)

#find association rules that result in low to medium power consumption. 
iot.combined.rules <- apriori(iot.combined, control = list(verbose=F),
                              parameter = list(minlen=3, supp=0.1, conf=0.95),
                              appearance = list(rhs=c("Global_active_power=Very Low", "Global_active_power=Low"),
                                                default="lhs"))
inspect(iot.combined.rules)

#sort the rules by lift
iot.combined.rules.sorted <- sort(iot.combined.rules, by="lift")

#find redundant simulation rules
subset.matrix <- is.subset(iot.combined.rules.sorted, iot.combined.rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant simulation rules
iot.combined.rules.pruned <- iot.combined.rules.sorted[!redundant]
inspect(iot.combined.rules.pruned)

#visualize simulation rules
plot(iot.combined.rules.pruned, method="grouped")

#....
iot.rules <- apriori(iot, control = list(verbose=F),
                     parameter = list(minlen=3, supp=0.1, conf=0.95),
                     appearance = list(rhs=c("Global_active_power=Very Low", "Global_active_power=Low"),
                                       default="lhs"))
inspect(iot.rules)

#sort the rules by lift
iot.rules.sorted <- sort(iot.combined.rules, by="lift")

#find redundant simulation rules
subset.matrix <- is.subset(iot.rules.sorted, iot.rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant simulation rules
iot.rules.pruned <- iot.rules.sorted[!redundant]
inspect(iot.rules.pruned)

#visualize simulation rules
plot(iot.rules.pruned, method="grouped")
