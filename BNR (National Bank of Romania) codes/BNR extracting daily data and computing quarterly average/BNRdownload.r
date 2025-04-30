#loading the functions used throughout the code
month_to_quarter = function(month) #to attribute month to quarter
{
  if (month %in% c("Jan", "Feb", "Mar")) 
  {
    return("Q1")
  } else if (month %in% c("Apr", "May", "Jun")) {
    return("Q2")
  } else if (month %in% c("Jul", "Aug", "Sep")) {
    return("Q3")
  } else if (month %in% c("Oct", "Nov", "Dec")) {
    return("Q4")
  }
}

#installing and loading the packages

#install.packages("rvest")
#install.packages("dplyr")
#install.packages("xml2") 
#install.packages("magrittr")

library(rvest)
library(dplyr)
library(xml2)
library(magrittr)

#setting the working directory
setwd("E:/BNR extracting daily data and computing quarterly average")

#- extracting the robor 3M daily and computing the daily 3M ROBOR  
#connecting to the HTML page containing the table with the exchange rates
	#to identify the HTML page with all the historical data: https://www.bnro.ro/Baza-de-date-interactiva-604.aspx 
		#then select the data you want-> click on "Genereaza statistica" -> at the bottom of the page select "Toate datele disponibile"
		#then select "HTML" from "Selectati formatul" 
			#copy-paste the generated link below
robor3M_daily=read_html("https://www.bnro.ro/StatisticsReportHTML.aspx?icid=800&table=642&column=3573")
		#!before running the code, copy-paste the HTML ling above in your browser to quickly check that the table is the one that you want
robor3M_daily=robor3M_daily %>%
  html_elements("table") %>%
  html_table() %>%
  extract2(1) #selects the table; in thie case there is just one table on the HTML page, so it takes the first table

colnames(robor3M_daily)=c("Time", "ROBOR_3M_daily") #changes the colnames for easier use throughout the cleaning below
robor3M_daily=robor3M_daily[-1,] #delets the codes row


#compute the average quarterly ROBOR
robor3M_daily = robor3M_daily %>%
  mutate(
	Year = substr(Time, 7, 10), #constructs the column "Year" from the 7th to the 10th character in the column "Time"
    Month = substr(Time, 4, 6), #constructs the column "Month" from the 4th to the 6th character in the column "Time"
	Day = substr(Time, 1, 2), #constructs the column "Day" from the 1st to the 2nd character in the column "Time"
    Quarter = sapply(Month, month_to_quarter), #constructs the column "Quarter" based on the month in column "Month"
    Time = paste0(Year, "-", Quarter) #column "Time" is re-written as Year-Quarter
  )

robor3M_quarterly = robor3M_daily %>%
  group_by(Time) %>%
	summarise(ROBOR_3M = mean(as.numeric(ROBOR_3M_daily)))

colnames(robor3M_quarterly)=c("Time", "ROBOR 3M %")

#export the data to a .csv file
write.csv(robor3M_quarterly, "ROBOR quarterly data.csv", row.names=FALSE, na="na")