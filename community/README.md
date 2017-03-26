# Simulating Smart Cities. How to Build A Better Community

## Overview
Can a corporation improve a community? Are there business models that could act as the catalyst for safer, heatlthier ways of living? This project contains files used in the O’Reilly Media Learning Path training video entitled Using Data Science for Business Model Innovation. In the project are two R scripts:

1. `simSmartCity.R` which requires `atussum_2015.csv`
2. `simSmartCitystrategy.R` which requires `smartcity.businessmodel.csv`

Start by running `simSmartCity.R`. We start by collecting real observations of community experiences. We search for opportunities to improve the key aspects of the community. We use real observations to generate simulated communities. We test the plausibility of the simulations by comparing them to real observations. We search the simulated community experiences for interesting patterns of safer, healthier living. We look for clusters of  communities where the people have found some unusual, but significant ways of improving their lives. 

Next, run `simSmartCitystrategy.R`. After finding an innovative way of improving a community, we search through business model simulations for an equally innovative way to make the idea profitable.


## Simulating the Business Model

The `smartcity.businessmodel.csv` file was created by a business model simulation algorithm. The algorithm’s design is described in the [A Prototype Business Model Simulator](https://blogs.csc.com/2015/04/29/a-prototype-business-model-simulator/) blog.

The following is a description of fields contained in the `smartcity.businessmodel.csv` file:

-	cns1, cns2: current consumers (millions) for the competitor’s business model and our business model innovation respectively. Range: 0-100
-	pcn1, pcn2: potential consumers (millions) for the competitor’s business model and our business model innovation respectively. Range: 0-100
-	inv1, inv2: coefficient of innovation for the competitor’s business model and our business model innovation respectively. Range: 0.01-0.10
-	imt1, imt2: coefficient of imitation for the competitor’s business model and our business model innovation respectively. Range: 0.1-1.0
-	ped1, ped2: price elasticity of demand for the competitor’s business model and our business model innovation respectively. Range: 0.5-1.5
-	oe1, oe2: output elasticity for the competitor’s business model and our business model innovation respectively. Range: 0-1
-	cpex1, cpex2: initial capital investment (in $millions) for the competitor’s business model and our business model innovation respectively. Range: 0-100
-	pro1, pro2: days required to make a working prototype for the competitor’s business model and our business model innovation respectively. Range: 14-1000
-	ikp1, ikp2: improvement rate of key partners for the competitor’s business model and our business model innovation respectively. Range: 0.1-0.9

The strategy is modeled after the open business model. the idea is to build brand taping into social networks interested in public service. This strategy increases both the reach of the brand and the network effect of the consumers. We model the strategy with the assumption of higher potential consumers and high coefficients of imitation. We selected on those records where pcn2 > 65 and imt2 > 0.75

