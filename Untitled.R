install.packages("XML")
install.packages("RCurl")
install.packages("httr")

library(XML)
library(RCurl)
library(httr)
## input the S&P 100 list
tables <- GET("http://en.wikipedia.org/wiki/S%26P_100")
tables <- readHTMLTable(rawToChar(tables$content))
SPList <- head(tables[3])
symSP <- SPList$Symbol
symSP
str(SPList)

## input the yahoo finance data
URLlist <- c()
URLlistinput <- for (i in 1:length(SPList)) {
    URLlist[i] <- print(paste("https://finance.yahoo.com/quote/", SPList[i], "/history?p=", SPList[i]))
  }
}

URLlistinput(SPList)