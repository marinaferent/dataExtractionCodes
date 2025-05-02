#install packages
#install.packages("eurostat")

#load eurostat library
library(eurostat)

#download list of indicators and store it externaly
indicatorsNUTS1=search_eurostat("NUTS 1")
#View(indicatorsNUTS1)
write.csv(indicatorsNUTS1, "E:/Eurostat - download list of available variables example/NUTS1 Eurostat list of indicators.csv")

#download list of indicators and store it externaly
indicatorsNUTS2=search_eurostat("NUTS 2")
#View(indicatorsNUTS2)
write.csv(indicatorsNUTS2, "E:/Eurostat - download list of available variables example/NUTS2 Eurostat list of indicators.csv")