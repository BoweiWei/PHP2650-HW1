install.packages("XML")
install.packages("RCurl")
install.packages("httr")
install.packages("RSelenium")

library(XML)
library(RCurl)
library(httr)
library(RSelenium)

#read S&P 100

#theurl="http://en.wikipedia.org/wiki/S%26P_100"
#tables=readHTMLTable(theurl)
#SPList=head(tables[3])
#SPList=SPList[[1]]
#symSP=SPList$Symbol

#tables <- GET("http://en.wikipedia.org/wiki/S%26P_100")
#tables <- readHTMLTable(rawToChar(tables$content))
#SPList <- head(tables[3])
#symSP <- SPList$Symbol


tables <- GET("http://en.wikipedia.org/wiki/S%26P_100")
tables <- readHTMLTable(rawToChar(tables$content))
SPList=head(tables[3])
SPList=SPList[[1]]
symSP=as.character(SPList$Symbol)
symSP[symSP == 'BRK.B'] <-'BRK-B'

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

downloadHPYahoo <- function(symbol) {
  Sys.sleep(10+runif(1)*20)
  rsc$navigate(paste0("https://finance.yahoo.com/quote/", symbol, "/history?p=", symbol))
  hpcsv <- rsc$findElement("xpath", "//a[contains(@download, 'csv')]")
  hpcsv$clickElement()
}

newtable = list()
filename = c()

for (j in 1:3){
  downloadHPYahoo(symSP[j])
}
downloadHPYahoo(symSP[1])
for (j in 1:1){
  filename = paste(symSP[j],".csv",sep="")
  newtable[[1]]=read.csv(filename)
  repet=dim(newtable[[1]])[1]
  newtable[[1]]$symbol=rep(symSP[j],repet)
  newtb<- newtable[[1]][, c(dim(newtable[[1]])[2], 1:(dim(newtable[[1]])[2]-1))]
  write.csv(newtb,filename)
}



 

