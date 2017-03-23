Overview

This project contains files used in the O’Reilly Media Learning Path training video entitled Using Data Science for Business Model Innovation. In the project are two R scripts:
•	simIris.R which requires household_power_consumption.csv
•	simIrisstrategy.R which requires iris.businessmodel.csv

The iris.businessmodel.csv file

The iris.businessmodel.csv file was created by a business model simulation algorithm. The algorithm’s design is described in this blog:
https://blogs.csc.com/2015/04/29/a-prototype-business-model-simulator/

 The following is a description of fields contained in the iot.businessmodel.csv file:
•	cns1, cns2: current consumers (millions) for the competitor’s business model and our business model innovation respectively. Range: 0-100
•	pcn1, pcn2: potential consumers (millions) for the competitor’s business model and our business model innovation respectively. Range: 0-100
•	inv1, inv2: coefficient of innovation for the competitor’s business model and our business model innovation respectively. Range: 0.01-0.10
•	imt1, imt2: coefficient of imitation for the competitor’s business model and our business model innovation respectively. Range: 0.1-1.0
•	ped1, ped2: price elasticity of demand for the competitor’s business model and our business model innovation respectively. Range: 0.5-1.5
•	oe1, oe2: output elasticity for the competitor’s business model and our business model innovation respectively. Range: 0-1
•	cpex1, cpex2: initial capital investment (in $millions) for the competitor’s business model and our business model innovation respectively. Range: 0-100
•	pro1, pro2: days required to make a working prototype for the competitor’s business model and our business model innovation respectively. Range: 14-1000
•	ikp1, ikp2: improvement rate of key partners for the competitor’s business model and our business model innovation respectively. Range: 0.1-0.9

Special modifications to the business model

The strategy is to use the novelty of the new iris breeds to attract new adopters through advertising and word of mouth. We model the strategy with the assumption of a high coefficient of innovation and imitation. We select only those records where: inv2 > .05 and imt2 > 0.5.
