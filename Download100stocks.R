install.packages("XML")
install.packages("RCurl")
install.packages("httr")
install.packages("RSelenium")
install.packages("data.table")
install.packages("dplyr")
install.packages("readr")
install.packages("plyr")

library(XML)
library(RCurl)
library(httr)
library(RSelenium)
library(data.table)
library(plyr)

#1. extract the symbols and company names from the webpage, read S&P 100
tables <- GET("http://en.wikipedia.org/wiki/S%26P_100")
tables <- readHTMLTable(rawToChar(tables$content))
SPList=head(tables[3])
SPList=SPList[[1]]
symSP=as.character(SPList$Symbol)
#2. change the symbol BRK.B to BRK-B
symSP[symSP == 'BRK.B'] <-'BRK-B'

#start connection
rs <- rsDriver(extraCapabilities = list(
  chromeOptions = 
    list(prefs = list(
      "profile.default_content_settings.popups" = 0L,
      "download.prompt_for_download" = FALSE,
      "download.default_directory" = "/Users/xluo/Downloads"
    )
    )
))
rsc <- rs$client

#function to click the download button
downloadHPYahoo <- function(symbol) {
  Sys.sleep(10+runif(1)*20)
  rsc$navigate(paste0("https://finance.yahoo.com/quote/", symbol, "/history?p=", symbol))
  hpcsv <- rsc$findElement("xpath", "//a[contains(@download, 'csv')]")
  hpcsv$clickElement()
}

##3. download the historical stock prices from Yahoo in csv format
for (i in c(symSP)){
  downloadHPYahoo(i)
}

#4. add a column of the corresponding symbol for each csv file
allfiles=list()
for (j in 1:length(symSP)){
  #read the files into a list
  allfiles[[j]]<-read.csv(paste0(symSP[j],".csv"))
  #create a coranlumn with content the name of the companies
  namec<-as.data.frame(as.vector(rep(symSP[j],length=dim(allfiles[[j]])[1])))
  #let the column have the name 'Symbol'
  colnames(namec)[1]<-"Symbol"
  #combine the created column with the corresponding file
  allfiles[[j]]<-cbind(namec,allfiles[[j]])
  #replace the original csv with the new csv
  write.csv(allfiles[[j]],file=paste0(symSP[j],".csv"))
}

#5. concatenate all the csv files and put into a combined csv file
df<-ldply(allfiles,data.frame)
write.csv(df,file="combined.csv")
 

