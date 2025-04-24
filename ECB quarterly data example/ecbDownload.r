# ---- PART 1: Bulk download --------- #
# @ needed for running the code: 

# 1.ecb_ref_table.csv with: 
# 	-> the codes of the ecb tables to be downloaded (found through Google/ECB search - series key)
#	-> empty column
#	-> the name of the indicators to be extracted from that table 

# 2.datasetECB_annualData.csv with:
#	-> time column (keep the column name as "obstime")

#install and load packages

#install.packages("ecb")
#install.packages(c("plyr", "mFilter", "dplyr", "tidyverse"))

library(ecb)
library(plyr)
library(mFilter)
library(dplyr)
library(tidyverse)

#set the working directory
setwd("E:/ECB quarterly data example/Inputs")

#define the list of indicators to be downloaded from the ecb_ref_table.csv
tDown=read.csv("ecb_ref_table.csv")

#select the tables to be downloaded
ecbCode=tDown$code_name

#download data and store it into a list
ecbData=list()
for (i in 1:length(ecbCode)){
	ecbData[[i]]=get_data(ecbCode[i])	
}

#assign the name of the corresponding ESTAT table to all the different tables downloaded and grouped into the list
names(ecbData)=ecbCode

#save the ecbData list locally for future use
save(ecbData,file="E:/ECB quarterly data example/Outputs/ecbData.RData")
#once saved, to load the data in a future session attach the RData file as below
#attach("E:/ECB quarterly data example/Outputs/ecbData.RData")

# ----- PART 2: Filtering the needed data ----#

datasetFinal=read.csv("datasetECB_annualData.csv")

#transform datasetFinal to incorporate quarters
quarters=c("Q1", "Q2", "Q3", "Q4") #the quarterly ecb bulk download has the obstime as:
										##1995-Q1, 1995-Q2 etc.
datasetFinal=datasetFinal %>%
  crossing(quarter = quarters)
datasetFinal=datasetFinal %>%
  mutate(obstime = paste(obstime, quarter, sep = "-"))
datasetFinal=datasetFinal[,1]

#subset the ecb dataset based on the characteristics
i=1
Euribor=subset(ecbData$FM.Q.U2.EUR.RT.MM.EURIBOR3MD_.HSTA, freq == "Q" & ref_area == "U2" & currency == "EUR" & provider_fm == "RT" & instrument_fm == "MM" & provider_fm_id == "EURIBOR3MD_" & data_type_fm == "HSTA", c(obstime,obsvalue))
datasetFinal=join(datasetFinal, Euribor, by = c("obstime"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste(tDown$full_name[i])

i=i+1
Libor=subset(ecbData$FM.Q.GB.USD.RT.MM.USD3MFSR_.HSTA, freq == "Q" & ref_area == "GB" & currency == "USD" & provider_fm == "RT" & instrument_fm == "MM" & provider_fm_id == "USD3MFSR_" & data_type_fm == "HSTA", c(obstime,obsvalue))
datasetFinal=join(datasetFinal, Libor, by = c("obstime"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste(tDown$full_name[i])

#save datasetFinal locally as a .csv file
write.csv(datasetFinal, "E:/ECB quarterly data example/Outputs/Dataset final.csv",row.names=FALSE, na="na")