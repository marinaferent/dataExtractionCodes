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
setwd("E:/BNR data example")


#- extracting the exchange rates Euro_Ron and Usd_Ron, quarterly, average
#connecting to the HTML page containing the table with the exchange rates
	#to identify the HTML page with all the historical data: https://www.bnro.ro/Baza-de-date-interactiva-604.aspx 
		#then select the data you want-> click on "Genereaza statistica" -> at the bottom of the page select "Toate datele disponibile"
		#then select "HTML" from "Selectati formatul" 
			#copy-paste the generated link below
exchangeRate_avg=read_html("https://www.bnro.ro/StatisticsReportHTML.aspx?icid=800&table=1627&column=3573,27658,27669")
	#!before running the code, copy-paste the HTML ling above in your browser to quickly check that the table is the one that you want
exchangeRate_avg=exchangeRate_avg %>%
  html_elements("table") %>%
  html_table() %>%
  extract2(1) #selects the table; in thie case there is just one table on the HTML page, so it takes the first table

colnames(exchangeRate_avg)=c("Time", "Euro_Ron", "Usd_Ron") #changes the colnames for easier use throughout the cleaning below
exchangeRate_avg=exchangeRate_avg[-1,] #delets the codes row

#the quarters in column "Time" are written as "Sep2024" "Jun2024" "Mar2024" "Dec2023" etc.
	##below we transform them into "2024-Q3" "2024-Q2" "2024-Q1" "2023-Q4" etc.
exchangeRate_avg= exchangeRate_avg %>%
  mutate(
    Year = substr(Time, 4, 7), #constructs the column "Year" from the 4th to the 7th character in the column "Time"
    Month = substr(Time, 1, 3), #constructs the column "Month" from the 1st to the 3rd character in the column "Time"
    Quarter = sapply(Month, month_to_quarter), #constructs the column "Quarter" based on the month in column "Month"
    Time = paste0(Year, "-", Quarter) #column "Time" is re-written as Year-Quarter
  ) %>%
  select(-Year, -Month, -Quarter) #delets the "Year", "Month", and "Quarter" columns



#export the data to a .csv file
write.csv(exchangeRate_avg, "Quarterly exchage rate.csv", row.names=FALSE, na="na")