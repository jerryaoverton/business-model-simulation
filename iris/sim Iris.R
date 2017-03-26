#Can we generate revenue growth by breeding new species of iris?

#Hypothesis:
#cross breeding existing species of iris will lead to the creation of new
#species. assuming the new species are considered innovative by the market
#we can build a business model that competes based on the innovative
#features of the new flowers

require(mvtnorm)

#use the iris data
iris.data <- iris[,1:4]
iris.cmatrix <- cor(iris.data)

#start the simulation as a set of random, guaussian variable 
#correlated according to the matrix
simulation_runs = 10000 #10 thousand flowers
number_of_features = 4
feature_means <- rep(0,number_of_features)
iris.sim <- rmvnorm(mean=feature_means,sig=iris.cmatrix,n=simulation_runs)

#rename the simulation variables to match the observations
colnames(iris.sim) <- colnames(iris.data)

#convert the simulation variables to a uniform distribution
iris.sim <- pnorm(iris.sim)
iris.sim <- as.data.frame(iris.sim)

#determine the distribution of each observed variable
#install.packages("fitdistrplus")
library(fitdistrplus)
descdist(iris$Sepal.Length, discrete = FALSE) #beta
descdist(iris$Sepal.Width, discrete = FALSE) #lognormal
descdist(iris$Petal.Length, discrete = FALSE) #beta
descdist(iris$Petal.Width, discrete = FALSE) #uniform

#convert the simulated variables to distributions
#that match observation

#fit sepal length to a beta distribution
library(scales)
parm <- fitdist(rescale(iris.data$Sepal.Length,c(0.01,.99)),"beta")
iris.sim$Sepal.Length <- qbeta(iris.sim$Sepal.Length,
                               shape1 = parm$estimate[1],
                               shape2 = parm$estimate[2])
descdist(iris.sim$Sepal.Length, discrete = FALSE)

#fit sepal width to a lognormal distribution
parm <- fitdist(iris.data$Sepal.Width,"lnorm")
iris.sim$Sepal.Width <- qlnorm(iris.sim$Sepal.Width,meanlog = parm$estimate[1], sdlog = parm$estimate[2])
descdist(iris.sim$Sepal.Width, discrete = FALSE)

#fit petal length to a beta distribution
parm <- fitdist(rescale(iris.data$Petal.Length,c(0.01,.99)),"beta")
iris.sim$Petal.Length <- qbeta(iris.sim$Petal.Length,
                               shape1 = parm$estimate[1],
                               shape2 = parm$estimate[2])
descdist(iris.sim$Petal.Length, discrete = FALSE)

#leave petal width as a uniform disribution
descdist(iris.sim$Petal.Width, discrete = FALSE)

#place simulated variables into the proper scale
iris.sim$Sepal.Length <- rescale(iris.sim$Sepal.Length, 
                                 c(min(iris.data$Sepal.Length), 
                                   max(iris.data$Sepal.Length)))

iris.sim$Sepal.Width <- rescale(iris.sim$Sepal.Width, 
                                 c(min(iris$Sepal.Width), 
                                   max(iris$Sepal.Width)))

iris.sim$Petal.Length <- rescale(iris.sim$Petal.Length, 
                                c(min(iris$Petal.Length), 
                                  max(iris$Petal.Length)))

iris.sim$Petal.Width <- rescale(iris.sim$Petal.Width, 
                                 c(min(iris$Petal.Width), 
                                   max(iris$Petal.Width)))

#compare the statistical properties of the simulated data to the observations
summary(iris.data)
summary(iris.sim)

#compare the correlations of the simulated data to the observations
iris.sim.cmatrix <- cor(iris.sim)

iris.cmatrix
iris.sim.cmatrix

#create a data set needed to show the real and simulated data on 
#the same plot
plotdata.sim <- iris.sim
plotdata.sim$Source <- "Simulation"

plotdata.obs <- iris.data
plotdata.obs$Source <- "Observation"

plotdata <- rbind(plotdata.sim,plotdata.obs)

#show the real and simulated data on the same plot
library(ggplot2)
s1.petal <- qplot(Petal.Width, Petal.Length, data = plotdata,
                  colour = factor(Source),
                  geom = c("point", "smooth"),
                  alpha = I(1/15))
s1.sepal <- qplot(Petal.Length, Sepal.Length, data = plotdata,
                  colour = factor(Source),
                  geom = c("point", "smooth"),
                  alpha = I(1/15))
library(gridExtra)
grid.arrange(s1.petal, s1.sepal, ncol=2, nrow=1)

#create plots to compare the disributions of the observed and simulated data
p1.sim <- qplot(iris.sim$Sepal.Length, geom="histogram", 
                binwidth=.25, col="red", main = "Simulated Sepal Length", 
                xlab = "Sepal Length")
p1.obs <- qplot(iris.data$Sepal.Length, geom="histogram", 
                binwidth=.25, col="red", main = "Observed Sepal Length", 
                xlab = "Sepal Length")

p2.sim <- qplot(iris.sim$Sepal.Width, geom="histogram", 
                binwidth=.25, col="red", main = "Simulated Sepal Width", 
                xlab = "Sepal Width")
p2.obs <- qplot(iris.data$Sepal.Width, geom="histogram", 
                binwidth=.25, col="red", main = "Observed Sepal Width", 
                xlab = "Sepal Width")

p3.sim <- qplot(iris.sim$Petal.Length, geom="histogram", 
                binwidth=.25, col="red", main = "Simulated Petal Length", 
                xlab = "Petal Length")
p3.obs <- qplot(iris.data$Petal.Length, geom="histogram", 
                binwidth=.25, col="red", main = "Observed Petal Length", 
                xlab = "Petal Length")

p4.sim <- qplot(iris.sim$Petal.Width, geom="histogram", 
                binwidth=.25, col="red", main = "Simulated Petal Width", 
                xlab = "Petal Length")
p4.obs <- qplot(iris.data$Petal.Width, geom="histogram", 
                binwidth=.25, col="red", main = "Observed Sepal Width", 
                xlab = "Sepal Length")

#show the plot comparing the distributions
library(gridExtra)
grid.arrange(p1.obs, p2.obs, p3.obs, p4.obs,
             p1.sim, p2.sim, p3.sim, p4.sim,
             ncol=4, nrow=2)

#create and plot clusters that represent the observied iris species
kmeans.result <- kmeans(iris.data, 3)
goodness <- kmeans.result$betweenss/kmeans.result$totss
goodness
plot(iris.data[c("Petal.Length", "Petal.Width")], col = kmeans.result$cluster)
points(kmeans.result$centers[,c("Petal.Length", "Petal.Width")], 
       col = 1:3, pch = 8, cex=2)

#create and plot clusters that represent the simulated iris species
kmeans.result <- kmeans(iris.sim, 5)
goodness <- kmeans.result$betweenss/kmeans.result$totss
goodness
plot(iris.sim[c("Petal.Length", "Petal.Width")], col = kmeans.result$cluster)
