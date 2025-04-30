#installing and loading the needed packages
#install.packages("httr")
#install.packages("readxl")
library(httr)
library(readxl)

month=c("ianuarie", "februarie", "martie", 
			"aprilie", "mai", "iunie",
			"iulie", "august", "septembrie",
			"octombrie", "noiembrie", "decembrie")

#Downloading the inmatriculari files

corrupted_files=list()		

for(year in 2018:2024)
{
	for(i in 1:length(month))
	{
	urlPath=paste0("https://www.onrc.ro/statistici/",year,"/",month[i],"/inmatricul%C4%83ri%20de%20persoane%20fizice%20%C5%9Fi%20juridice%20",year,".xls")
	destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xls")
	GET(urlPath, write_disk(destination, overwrite = TRUE))

	#checking if the file is corrupted
	file_info=file.info(destination)
    if(file_info$size < 1000) 
	{ #assuming files smaller than 1000 bytes might be corrupted
	  urlPath=paste0("https://www.onrc.ro/statistici/",year,"/",month[i],"/inmatriculari%20de%20persoane%20fizice%20si%20juridice%20",year,".xls")
	  GET(urlPath, write_disk(destination, overwrite = TRUE))
	  file_info=file.info(destination)
	  if(file_info$size < 1000)
	  {
		urlPath=paste0("https://www.onrc.ro/statistici/", year, "/",month[i],"/inmatriculari%20de%20persoane%20fizice%20si%20juridice%20",year-1,".xls")
	    GET(urlPath, write_disk(destination, overwrite = TRUE))
		file_info=file.info(destination)
		if(file_info$size < 1000)
		{
			urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/inmatriculari%20persoane%20fizice%20si%20juridice%2031.0", i, ".", year, ".xlsx")
			destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
			GET(urlPath, write_disk(destination, overwrite = TRUE))
			file_info=file.info(destination)
			if(file_info$size < 1000)
			{
				urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/inmatriculari%20persoane%20fizice%20si%20juridice%2030.0", i, ".", year, ".xlsx")
				destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
				GET(urlPath, write_disk(destination, overwrite = TRUE))
				file_info=file.info(destination)
				if(file_info$size < 1000)
				{
					urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/inmatriculari%20persoane%20fizice%20si%20juridice.xlsx")
					destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
					GET(urlPath, write_disk(destination, overwrite = TRUE))
					file_info=file.info(destination)
					if(file_info$size < 1000)
					{
						urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/Inmatriculari%20persoane%20fizice%20si%20juridice%20", month[i],"%20", year, ".xlsx")
						destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
						GET(urlPath, write_disk(destination, overwrite = TRUE))
						file_info=file.info(destination)
						if(file_info$size < 1000)
						{
							urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/inmatriculari%20de%20persoane%20fizice%20si%20juridice%2031.0", i, ".", year, ".xlsx")
							destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
							GET(urlPath, write_disk(destination, overwrite = TRUE))
							file_info=file.info(destination)
							if(file_info$size < 1000)
							{
								urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/inmatriculari%20de%20persoane%20fizice%20si%20juridice%2030.0", i, ".", year, ".xlsx")
								destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
								GET(urlPath, write_disk(destination, overwrite = TRUE))
								file_info=file.info(destination)
								if(file_info$size < 1000)
								{
									urlPath=paste0("https://www.onrc.ro/statistici/", year, "/", month[i], "/inmatriculari%20persoane%20fizice%20si%20juridice%2031.", i, ".", year, ".xlsx")
									destination=paste0("E:/ONRC data extraction example/All Excel files/Inmatriculari ", month[i], year, ".xlsx")
									GET(urlPath, write_disk(destination, overwrite = TRUE))
									file_info=file.info(destination)
									if(file_info$size < 1000)
									{
										corrupted_files=c(corrupted_files, destination)
									}
								}
							}
						}
					}
				}
			}
		}
	  }
    } 
  }
}



#print the list of corrupted files
if(length(corrupted_files) > 0)
{
  cat("The following files are corrupted:\n")
  print(corrupted_files)
} else {
  cat("No corrupted files found.\n")
}