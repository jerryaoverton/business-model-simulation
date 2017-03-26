# Simulating People: How to Build Better Healthcare

## Overview
What if a hospital were willing to make comprehensive changes in how it treats and interacts with patients? Could a hospital improve the quality of patient care by changing its operations? This project contains files used in the O’Reilly Media Learning Path training video entitled Using Data Science for Business Model Innovation. In the project are two R scripts:

1. `simSmartCity.R` which requires `atussum_2015.csv`
2. `simSmartCitystrategy.R` which requires `smartcity.businessmodel.csv`

This project contains files used in the O’Reilly Media Learning Path training video entitled Using Data Science for Business Model Innovation. In the project are two R scripts:
•	simSmartCity.R which requires household_power_consumption.csv
•	simSmartCitystrategy.R which requires iot.businessmodel.csv

The healthcare.businessmodel.csv file

The healthcare.businessmodel.csv file was created by a business model simulation algorithm. The algorithm’s design is described in this blog:
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

The strategy is modeled after the long-tail platform pattern. The idea is to use consumer-grade communication technology to allow patients to interact with nurses and doctors. this allows hospitals to provide personalized care to a large population of patients. We model the strategy with the assumption of high returns to scale and large customer potential. We selected only those records where oe2 > 0.7 and pcn2 > 75
