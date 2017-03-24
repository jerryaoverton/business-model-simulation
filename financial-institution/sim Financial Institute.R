#simulate new possibilities for a better financial institute

#read observed customer experiences
#experiences <- read.csv("consumer_complaints.csv")

#filter the observations down to only the necessary columns
#cols <- c("Product", "Sub.issue", "Company")
#experiences.sub <- experiences[,cols]

#filter the observations to include only student loans
#studentloans <- experiences.sub[experiences.sub$Product=="Student loan",]
#write.csv(file = "student_loan_complaints.csv",studentloans)

#read student loan complaints
studentloans <- read.csv("student_loan_complaints.csv")

#pivot the data to show complaints by company
#install.packages("reshape")
library(reshape)
complaints <- cast(studentloans, Company~Sub.issue, length, value = "X")

#now that the data is pivoted by company, the company name is no longer needed
#and interferes with subsequent analysis
complaints$Company <- NULL

#use the real complaints to create a set of simulated complaints
#start by creating a correlation matix of the observed complaints
complaints.cor <- cor(complaints)

#start the simulation as a set of random, guaussian variable 
#correlated according to the matrix
require(mvtnorm)
simulation_runs = 30000 #30k new complaints
number_of_features = 14
feature_means <- rep(0,number_of_features)
complaints.sim <- rmvnorm(mean=feature_means,sig=complaints.cor,n=simulation_runs)

#rename the simulation variables to match the observations
colnames(complaints.sim) <- colnames(complaints)

#convert the simulation variables to a uniform distribution
complaints.sim <- pnorm(complaints.sim)
complaints.sim <- as.data.frame(complaints.sim)

#determine the distribution of each observed variable
#install.packages("fitdistrplus")
library(fitdistrplus)
descdist(complaints[,1], discrete = FALSE) #beta
descdist(complaints[,2], discrete = FALSE) #beta
descdist(complaints[,3], discrete = FALSE) #beta
descdist(complaints[,4], discrete = FALSE) #beta
descdist(complaints[,5], discrete = FALSE) #beta
descdist(complaints[,6], discrete = FALSE) #beta
descdist(complaints[,7], discrete = FALSE) #beta
descdist(complaints[,8], discrete = FALSE) #beta
descdist(complaints[,9], discrete = FALSE) #beta
descdist(complaints[,10], discrete = FALSE) #beta
descdist(complaints[,11], discrete = FALSE) #beta
descdist(complaints[,12], discrete = FALSE) #beta
descdist(complaints[,13], discrete = FALSE) #beta
descdist(complaints[,14], discrete = FALSE) #beta

#fit all simulated activities to a beta distribution
library(scales)
for (i in 1: ncol(complaints.sim)){
  parm <- fitdist(rescale(complaints[,i],c(0.01,.99)),"beta")
  complaints.sim[,i] <- qbeta(complaints.sim[,i],
                                  shape1 = parm$estimate[1],
                                  shape2 = parm$estimate[2])
  #rescale the simulation data to match the scale of the observations
  complaints.sim[,i] <- rescale(complaints.sim[,i],
                                    c(min(complaints[,i]),
                                      max(complaints[,i]))
  )
}

#the minimum cluster performance threshold
threshold = .98

#by trial and error, determine the minimum number of clusters needed to reach a
#given performance threshold. then use that number to cluster the observed complaints

score = 0
num_clusters = 0
cluster_performance_below_threshold <- (score < threshold)

while(cluster_performance_below_threshold){
  num_clusters = num_clusters + 1
  clusters <- kmeans(complaints, num_clusters)
  
  score <- clusters$betweenss/clusters$totss
  cluster_performance_below_threshold <- (score < threshold)
}
complaints$cluster <- clusters$cluster

#by trial and error, determine the minimum number of clusters needed to reach a
#given performance threshold. then use that number to cluster the simulated complaints
score = 0
num_clusters = 0
cluster_performance_below_threshold <- (score < threshold)

while(cluster_performance_below_threshold){
  num_clusters = num_clusters + 1
  clusters <- kmeans(complaints.sim, num_clusters,iter.max=30)
  
  score <- clusters$betweenss/clusters$totss
  cluster_performance_below_threshold <- (score < threshold)
}
complaints.sim$cluster <- clusters$cluster

#visualize the distribution of complaint clusters
hist(complaints$cluster)
hist(complaints.sim$cluster)

#aggregate the observed and simulated complaints by cluster
complaints.agg <- aggregate(. ~ cluster, data=complaints, mean)
complaints.agg$Sum <- rowSums(complaints.agg)

complaints.sim.agg <- aggregate(. ~ cluster, data=complaints.sim, mean)
complaints.sim.agg$Sum <- rowSums(complaints.sim.agg)

#define the minum and maximum total number of complaints
complaints.min = 650
complaints.max = 750
complaints.sim.min = 450
complaints.sim.max = 550

#filter the observed and simulated clustered complaints to only those 
#below a particular threshold of total complaints
complaints.agg <- complaints.agg[complaints.agg$Sum > complaints.min,]
complaints.agg <- complaints.agg[complaints.agg$Sum < complaints.max,]

complaints.sim.agg <- complaints.sim.agg[complaints.sim.agg$Sum > complaints.sim.min,]
complaints.sim.agg <- complaints.sim.agg[complaints.sim.agg$Sum < complaints.sim.max,]

#format the aggregated observed and simulated complaints so that they can 
#be displayed using to radar chart
complaints.agg$Company <- NULL
complaints.agg$cluster <- NULL
complaints.agg$Sum <- NULL
labels <- colnames(complaints.agg)
complaints.agg <- as.data.frame(t(complaints.agg))

complaints.sim.agg$Company <- NULL
complaints.sim.agg$cluster <- NULL
complaints.sim.agg$Sum <- NULL
labels <- colnames(complaints.sim.agg)
complaints.sim.agg <- as.data.frame(t(complaints.sim.agg))

#display observations and simulations on a single radar chart

#name the column headings for the observed complaints
name <- rep("obs", ncol(complaints.agg))
number <- c(1:ncol(complaints.agg))
col_headings <- paste(name,number, sep = "-")
names(complaints.agg) <- col_headings

#name the column headings for the simulated complaints
name <- rep("sim", ncol(complaints.sim.agg))
number <- c(1:ncol(complaints.sim.agg))
col_headings <- paste(name,number, sep = "-")
names(complaints.sim.agg) <- col_headings

#combine and display both observed and simulated complaints
#install.packages("radarchart")
library(radarchart)
complaints.tot <- cbind(complaints.agg, complaints.sim.agg)
chartJSRadar(complaints.tot, maxScale = 170, labs = labels, showToolTipLabel=TRUE)
