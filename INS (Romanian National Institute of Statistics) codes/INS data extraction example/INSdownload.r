#installing the required packages
#https://github.com/MarianNecula/TEMPO/blob/master/doc/TEMPO.pdf
#install_github("MarianNecula/TEMPO")
#install.packages("dplyr")
#install.packages("stringr")
#install.packages("tidyverse")


#loading the required packages
library(TEMPO)
library(dplyr)
library(stringr)
library(tidyverse)

setwd("E:/INS data extraction example")

tempo_bulk("IND104N")

IPIbrut=read.csv("IND104N.csv")
colnames(IPIbrut)=c("Activitate", "Data", "UM", "Valoare")
IPIbrut=IPIbrut %>%
	select(-UM)

IPIbrut=IPIbrut %>%
  mutate(Luna = str_extract(Data, " [a-z]+ "))%>%
  mutate(An = str_extract(Data, " [0-9]+"))%>%
  mutate(Luna = str_replace_all(Luna, " ", ""))%>%
  mutate(An = str_replace_all(An, " ", ""))
  
IPIbrut=IPIbrut %>%  
	mutate(Luna = recode(Luna,
			ianuarie = "01",
			februarie = "02",
			martie = "03",
			aprilie = "04",
			mai = "05",
			iunie = "06",
			iulie = "07",
			august = "08",
			septembrie = "09",
			octombrie = "10",
			noiembrie = "11",
			decembrie = "12"),
		Perioada = paste0(An, "-", Luna))%>%
	select(-Data, -Luna, -An)

IPIbrut=IPIbrut %>%    
	pivot_wider(names_from = Activitate, values_from = Valoare)
	
write.csv(IPIbrut, "IPI brut.csv", row.names=FALSE)

