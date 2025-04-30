## The bulk download facility is accessible at: http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing
## The directory [dat] conatins all the tables available in a tsv compressed format (e.g.'lfsa_ugad.tsv.gz' contains the lfsa_ugad table with info on unemployment duration)
## The directory [dic] contains all the dictionaries, e.g. the correspondence table between a dimension-variable code and its equivalent hunam-radable label.
## For instance, 'geo.dic') contains the lables for all the geographical levels present in ESTAT (countries, NUTS2, NUTS3, non EU-members, etc.)
## Also very useful is 'table_dic.dic', which contains a list and a description for all the tables available in the download facility.
#rm(list=ls())

#in order to save the raw dataset run line 54(Rdata) and/or line 58/60 (separate .csv files)

#needed for running the code: 

##1.estat_ref_table.csv with: 
###the codes of the ESTAT tables to be downloaded*
####*BUG: in order to be able to download the full description with get_eurostat_dic -lines 31-36- the ESTAT codes have to be written in uppercase
###their full name 
###the name of the indicators to be extracted from that table 
###an internal code for that indicator

##2.datasetEurostat with:
###country column (keep the name as country)
###time column (keep the name as time)


#load the eurostat and plyr packages
library(eurostat)
library(plyr)
library(mFilter)
#set the working directory
setwd("E:/Faculty/PhD/Thesis/Employment rate - Flexicurity/Data/Eurostat data/Inputs")
#clean the cache
clean_eurostat_cache()
#define the list of indicators to be downloaded from the estat_ref_table.csv
tDown=read.csv("estat_ref_table.csv")
dic=get_eurostat_dic("table_dic")
tDown_dic=join(tDown,dic,by="code_name",type="left")
tDown[,2]=tDown_dic$full_name
colnames(tDown)[2]=c("full_name")
write.csv(tDown,"tDown.csv", na="na", row.names=FALSE)

#tDown=read.csv("E:/Faculty/PhD/Thesis/Employment rate - Flexicurity/Data/Eurostat data/Inputs/tDown.csv")
#select the tables to be downloaded
#estatCode<-levels(factor(tDown$code_name, exclude=NA)) #in case indicators do not have estat codes (eg. combination of other indicators), the space for the estatCode will be filled with NA
estatCode=levels(tDown$code_name)
#download data and store it into a list
eurostatData=list()
eurostatDataFullDescription=list()
for (i in 1:length(estatCode)){
	eurostatData[[i]]=get_eurostat(tolower(estatCode[i]),time_format="num")
	
	#get the countries' full name
	eurostatDataFullDescription[[i]]=label_eurostat(eurostatData[[i]],eu_order=TRUE, fix_duplicated = TRUE)
	
	#add the full country name to the eurostatData table
	eurostatData[[i]][,(ncol(eurostatData[[i]])+1)]=eurostatDataFullDescription[[i]]$geo
	colnames(eurostatData[[i]])[ncol(eurostatData[[i]])]=c("country")
}

#assign the name of the corresponding ESTAT table to all the different tables downloaded and grouped into the list
names(eurostatData)=estatCode

#might be useful to store the name and number of each data frame in the list for easily appending it at the latter stage
#namesEurostatData=names(eurostatData)
#write.csv(namesEurostatData, "D:/JRC/Expert/Data/Eurostat data/Outputs/namesEurostatData.csv")


#View(eurostatData[[2]])

save(eurostatData,file="E:/Faculty/PhD/Thesis/Employment rate - Flexicurity/Data/Eurostat data/Outputs/eurostatData.RData")
#attach("E:/Faculty/PhD/Thesis/Employment rate - Flexicurity/Data/Eurostat data/Outputs/eurostatData.RData")

#save each data frame from the list as a separate .csv file named as the indicator
#for (i in seq_along(estatCode)) write.csv(eurostatData[[i]], file=paste0("D:/JRC/Expert/Data/Eurostat data/Outputs/",estatCode[i], ".csv"))

#read the final template
datasetFinal=read.csv("datasetEurostat.csv")



#########################################################################################################################
#FOLLOWING SECTION IS AN EXAMPLE OF THE WAY TO PROCEED WHEN SUBSETTING EACH INDICATOR AND ADDING INTO THE FINAL TEMPLATE#				
#########################################################################################################################
#create the indicators following STRICTLY the order in the fourth column in the list tDown (checked by ind_count)
ind_count=1

############################total employment rate
#define the vector of ages
age=c("Y15-64")

employmentTotal=subset(eurostatData$LFSA_ERGAED, unit=="PC" & sex=="T" & age=="Y15-64" & isced11=="TOTAL", c(country,time,values))
datasetFinal=join(datasetFinal, employmentTotal, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentTotal",age[1])
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################unemployment rate
#define the vector of ages
age=c("Y15-64")

unemploymentTotal=subset(eurostatData$UNE_RT_A, age=="Y15-74" & unit=="PC_ACT" & sex=="T", c(country,time,values))
datasetFinal=join(datasetFinal, unemploymentTotal, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("unemploymentTotal",age[1])
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################flows into employment

employmentInflows=subset(eurostatData$ILC_LVHL30, trans1y=="TO_EMP" & wstatus=="UNE" & sex=="T", c(country,time,values))
datasetFinal=join(datasetFinal, employmentInflows, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentInflows")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into unemployment

employmentOutflows=subset(eurostatData$ILC_LVHL30, trans1y=="TO_UNE" & wstatus=="EMP" & sex=="T", c(country,time,values))
datasetFinal=join(datasetFinal, employmentOutflows, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentOutflows")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into employment from inactivity
employmentInflows=subset(eurostatData$ILC_LVHL30, trans1y=="TO_EMP" & wstatus=="INAC" & sex=="T", c(country,time,values))
datasetFinal=join(datasetFinal, employmentInflows, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("toEmployment_inac")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into inactivity from employment

employmentOutflows=subset(eurostatData$ILC_LVHL30, trans1y=="TO_INAC" & wstatus=="EMP" & sex=="T", c(country,time,values))
datasetFinal=join(datasetFinal, employmentOutflows, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("toInac_employment")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into employment from unemployment male

employmentInflows1=subset(eurostatData$ILC_LVHL30, trans1y=="TO_EMP" & wstatus=="UNE" & sex=="M", c(country,time,values))
datasetFinal=join(datasetFinal, employmentInflows1, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentInflows_male")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into unemployment from employment male

employmentOutflows2=subset(eurostatData$ILC_LVHL30, trans1y=="TO_UNE" & wstatus=="EMP" & sex=="M", c(country,time,values))
datasetFinal=join(datasetFinal, employmentOutflows2, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentOutflows_male")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################flows into employment from inactivity male
employmentInflows3=subset(eurostatData$ILC_LVHL30, trans1y=="TO_EMP" & wstatus=="INAC" & sex=="M", c(country,time,values))
datasetFinal=join(datasetFinal, employmentInflows3, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("toEmployment_inac_male")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into inactivity from employment male

employmentOutflows4=subset(eurostatData$ILC_LVHL30, trans1y=="TO_INAC" & wstatus=="EMP" & sex=="M", c(country,time,values))
datasetFinal=join(datasetFinal, employmentOutflows4, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("toInac_employment_male")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################flows into employment from unemployment female

employmentInflows5=subset(eurostatData$ILC_LVHL30, trans1y=="TO_EMP" & wstatus=="UNE" & sex=="F", c(country,time,values))
datasetFinal=join(datasetFinal, employmentInflows5, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentInflows_female")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into unemployment from employment female

employmentOutflows6=subset(eurostatData$ILC_LVHL30, trans1y=="TO_UNE" & wstatus=="EMP" & sex=="F", c(country,time,values))
datasetFinal=join(datasetFinal, employmentOutflows6, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentOutflows_female")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################flows into employment from inactivity female
employmentInflows7=subset(eurostatData$ILC_LVHL30, trans1y=="TO_EMP" & wstatus=="INAC" & sex=="F", c(country,time,values))
datasetFinal=join(datasetFinal, employmentInflows7, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("toEmployment_inac_female")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################flows into inactivity from employment female

employmentOutflows8=subset(eurostatData$ILC_LVHL30, trans1y=="TO_INAC" & wstatus=="EMP" & sex=="F", c(country,time,values))
datasetFinal=join(datasetFinal, employmentOutflows8, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("toInac_employment_female")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1



############################long-term unemployment

unemploymentLT=subset(eurostatData$UNE_LTU_A, indic_em=="LTU" & age=="Y20-64" & sex=="T" & unit=="PC_UNE", c(country,time,values))
datasetFinal=join(datasetFinal, unemploymentLT, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("unemploymentLT")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1



############################youth unemployment 15-24

unemploymentYouth1524=subset(eurostatData$YTH_EMPL_010, sex=="T" & age=="Y15-24" & unit=="PC" & isced11=="TOTAL", c(country,time,values))
datasetFinal=join(datasetFinal, unemploymentYouth1524, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("unemploymentYouth1524")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################youth employment 15-29

unemploymentYouth1529=subset(eurostatData$YTH_EMPL_010, sex=="T" & age=="Y15-29" & unit=="PC" & isced11=="TOTAL", c(country,time,values))
datasetFinal=join(datasetFinal, unemploymentYouth1529, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("unemploymentYouth1529")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################women employment

employmentWomen=subset(eurostatData$LFSA_ERGAED, unit=="PC" & sex=="T" & age=="Y15-64" & isced11=="TOTAL", c(country,time,values))
datasetFinal=join(datasetFinal, employmentWomen, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("employmentWomen")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################NEET 15-24

NEET=subset(eurostatData$LFSI_NEET_A, sex=="T" & age=="Y15-24" & unit=="PC_POP", c(country,time,values))
datasetFinal=join(datasetFinal, NEET, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("NEET 15-24")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################NEET 15-29

NEET=subset(eurostatData$LFSI_NEET_A, sex=="T" & age=="Y15-29" & unit=="PC_POP", c(country,time,values))
datasetFinal=join(datasetFinal, NEET, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("NEET 15-24")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


############################job vacancy rate

jobVacancy=subset(eurostatData$JVS_A_RATE_R2, nace_r2=="B-S" & sizeclas=="TOTAL" & unit=="AVG_A", c(country,time,values))
datasetFinal=join(datasetFinal, jobVacancy, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("jobVacancy")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################GDP per capita

GDPcapita=subset(eurostatData$PRC_PPP_IND, na_item=="VI_PPS_EU28_HAB" & ppp_cat=="GDP", c(country,time,values))
datasetFinal=join(datasetFinal, GDPcapita, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("GDPcapita")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################inflation rate

inflation=subset(eurostatData$PRC_HICP_AIND, unit=="INX_A_AVG" & coicop =="CP00", c(country,time,values))
datasetFinal=join(datasetFinal, inflation, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("inflation")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################minimum wage (%of mean wage)

minWage1=subset(eurostatData$EARN_MW_AVGR1, unit=="PC" & nace_r1=="C-K" & indic_se=="MMW_MEAN_ME_PP", c(country,time,values))
datasetFinal=join(datasetFinal, minWage1, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("minWage1")

minWage2=subset(eurostatData$EARN_MW_AVGR2, unit=="PC" & nace_r2=="B-S" & indic_se=="MMW_MEAN_ME_PP", c(country,time,values))
datasetFinal=join(datasetFinal, minWage2, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("minWage2")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+2

############################minimum wage (%of median wage)

minWage1=subset(eurostatData$EARN_MW_AVGR1, unit=="PC" & nace_r1=="C-K" & indic_se=="MMW_MED_ME_PP", c(country,time,values))
datasetFinal=join(datasetFinal, minWage1, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("minWageMedian1")

minWage2=subset(eurostatData$EARN_MW_AVGR2, unit=="PC" & nace_r2=="B-S" & indic_se=="MMW_MED_ME_PP", c(country,time,values))
datasetFinal=join(datasetFinal, minWage2, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("minWageMedian2")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

#ind_count=ind_count+2

############################imports

imports=subset(eurostatData$NAMA_10_GDP, unit=="CP_MEUR" & na_item=="P7", c(country,time,values))
datasetFinal=join(datasetFinal, imports, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("imports")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

############################exports

exports=subset(eurostatData$NAMA_10_GDP, unit=="CP_MEUR" & na_item=="P6", c(country,time,values))
datasetFinal=join(datasetFinal, exports, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("exports")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1

##########################GDP

GDP=subset(eurostatData$NAMA_10_GDP, unit=="CP_MEUR" & na_item=="B1GQ", c(country,time,values))
datasetFinal=join(datasetFinal, GDP, by = c("country", "time"), type = "left")
colnames(datasetFinal)[ncol(datasetFinal)]=paste0("GDP")
#datasetFinal[1,ncol(datasetFinal)]=as.character(tDown[ind_count,4])

ind_count=ind_count+1


write.csv(datasetFinal, "E:/Faculty/PhD/Thesis/Employment rate - Flexicurity/Data/Eurostat data/Outputs/datasetFinal.csv",row.names=FALSE, na="na")
