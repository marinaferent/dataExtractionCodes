#installing the required packages
#https://github.com/MarianNecula/TEMPO/blob/master/doc/TEMPO.pdf
#install_github("MarianNecula/TEMPO")


#loading the required packages
library(TEMPO)

listIndicators=tempo_toc(full_description=FALSE)
write.csv(listIndicators, "E:/INS download list of indicators example/List of available INS indicators.csv")
