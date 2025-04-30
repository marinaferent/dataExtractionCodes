#Installing and loading packages
#install.packages("readxl")
#install.packages("dplyr")
#install.packages("xlsx")
#install.packages("tidyr")
#install.packages("stringr")

##if errors with xlsx due to Java: after install, manually update the path in R-e.g.: 
Sys.setenv(JAVA_HOME='C:/Program Files/Eclipse Adoptium/jdk-21.0.5.11-hotspot')

library(readxl)
library(dplyr)
library(xlsx)
library(tidyr)
library(stringr)

#Set working directory
setwd("E:/ONRC data/All Excel files")


month=c("ianuarie", "februarie", "martie", 
			"aprilie", "mai", "iunie",
			"iulie", "august", "septembrie",
			"octombrie", "noiembrie", "decembrie")

###A.Cleansing the inmatriculari files
#1.Extract all tables from ianuarie2018 onwards
#2.Join all tables based on Denumire sectiune CAEN (keep all denumire)
excelLuna=read_excel(path="Inmatriculari ianuarie2018.xls", sheet = 2, skip = 2)
datasetFinal=excelLuna[,c(1)]

for(year in 2018:2024)
{
	for(i in 1:length(month))
	{
		if(year==2024 & i>=7)
		{
			excelLuna=read_excel(path=paste0("Inmatriculari ", month[i], year,".xlsx"), sheet = 2, skip = 1)#starting with july 2024, all the files are stored as .xlsx and have only 1 row above the colnames
			excelLuna=excelLuna[,c(1,ncol(excelLuna))]
			datasetFinal=full_join(datasetFinal, excelLuna, by=setNames(colnames(excelLuna)[1], colnames(datasetFinal)[1]))
			colnames(datasetFinal)[ncol(datasetFinal)]=paste0(month[i],year)
		} else {
			excelLuna=read_excel(path=paste0("Inmatriculari ", month[i], year,".xls"), sheet = 2, skip = 2)
			if(i==1) #for january the values are on the 2rd column, not on the last one
			{
				excelLuna=excelLuna[,c(1,2)]
				datasetFinal=full_join(datasetFinal, excelLuna,by=setNames(colnames(excelLuna)[1], colnames(datasetFinal)[1]))
				colnames(datasetFinal)[ncol(datasetFinal)]=paste0(month[i],year)
			} else {
				excelLuna=excelLuna[,c(1,ncol(excelLuna))]
				datasetFinal=full_join(datasetFinal, excelLuna,by=setNames(colnames(excelLuna)[1], colnames(datasetFinal)[1]))
				colnames(datasetFinal)[ncol(datasetFinal)]=paste0(month[i],year)
			}
		}
	}
}

datasetFinal=datasetFinal %>% replace(is.na(.), 0)

#the Total is the second last row => to move it to the last position:
datasetFinal[23,]=datasetFinal[21,]
datasetFinal=datasetFinal[-21,]


#3.Compute based on same period previous year
datasetYoY=datasetFinal[,1]
for(year in 2019:2024)
{
	for(i in 1:length(month))
	{
		datasetYoY[[paste0(month[i], year)]]=(datasetFinal[[paste0(month[i], year)]]-datasetFinal[[paste0(month[i], year-1)]])/datasetFinal[[paste0(month[i], year-1)]]*100
	}
}



datasetFinal=t(datasetFinal)
datasetYoY=t(datasetYoY)

write.xlsx(as.data.frame(datasetFinal), file="Inmatriculari.xlsx", sheetName="Inmatriculari (nr.)", row.names=TRUE)
write.xlsx(as.data.frame(datasetYoY), file="Inmatriculari.xlsx", sheetName="Inmatriculari (YoY)", append=TRUE, row.names=TRUE)