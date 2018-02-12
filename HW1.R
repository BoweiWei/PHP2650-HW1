

library(XML)
library(RCurl)
library(httr)
library(dplyr)
library(RSelenium)
library(stringr)
## input the S&P 100 list
tables <- GET("http://en.wikipedia.org/wiki/S%26P_100")
tables <- readHTMLTable(rawToChar(tables$content))
SPList <- head(tables[3])
SPList <- SPList[[1]]
symSP <- SPList$Symbol

## input the yahoo finance data
#URLlist <- NULL
#for (i in 1:length(symSP)) {
#    URLlist[i] <- paste("https://finance.yahoo.com/quote/", symSP[[i]], "/history?p=", symSP[[i]], sep = "")
#}


downloadHPYahoo <- function(symbol) {
  Sys.sleep(10+runif(1)*20)
  rsc$navigate(paste0("https://finance.yahoo.com/quote/", symbol, "/history?p=", symbol))
  hpcsv <- rsc$findElement("xpath", "//a[contains(@download, 'csv')]")
  hpcsv$clickElement()
}

for (s in 1:length(symSP)) {
  downloadHPYahoo(symSP[s])
}

## Question 2
df2 <- read.csv("NIHHarvard.csv", header = TRUE, sep = ",")
for (i in 1: nrow(df2)) {
  filter(substring(as.character(df2$Activity[i]),1,1) = c("T", "F")) {
    df2 <- df2[-i]
  }
}

df2 %>%
  filter(substring(as.character(Activity),1,1) != "T" & substring(as.character(Activity),1,1) != "F") -> df3

df3 <- as.data.frame(df3)

namelist <- unique(df3$Contact.PI...Project.Leader)
namelist.n <- lapply(namelist, str_replace_all, fixed("   "), "   ")
#namelist.exp <- as.data.frame(namelist, stringsAsFactors = FALSE)
#namelist.exp <- droplevels(namelist.exp)
namelist.s <- word(namelist, 1,2, sep=" ")
namelist.s <- lapply(namelist.s, str_replace_all, fixed(","), "+")
namelist.s <- lapply(namelist.s, str_replace_all, fixed(" "), "")


## approaches 
library(xml2)                           # another XML package
library(httr)                           # another one for getting web data with advanced features 
#html <- htmlParse( content( GET(url) , as="parsed")  )

getGS <- function(aname, affli, bname) {
  re <- NULL
  topicname <- paste0(aname, "[Author]", affli, "[Affiliation]") 
      url <- paste0("https://www.ncbi.nlm.nih.gov/pubmed/?term=", topicname)
    html <- htmlParse(getURL(url), encoding="UTF-8")
    anum <- xpathSApply(html, "//*[@class='title_and_pager']", xmlValue)
    anum <- toString(anum)
    anum <- str_replace_all(anum, fixed("  "), "")
    if (str_count(anum, "\\S+") > 4) {
    anum <- gsub("[^0-9\\.]", "", word(anum,7)) 
    re <- c("searchname" = aname, "Number of Publications" = anum, "Contact.PI...Project.Leader" = bname)
    } else {
      anum <- gsub("[^0-9\\.]", "", word(anum,3))
      re <- c("searchname" = aname, "Number of Publications" = anum, "Contact.PI...Project.Leader" = bname)
    }
    #Sys.sleep(10+runif(1)*20)       #random pause to fake human clicking or downloading
  return(re)
}

## loop 
re <- mapply(function(x, y) {getGS(x, "Harvard", y)}, x = namelist.s, y = namelist.n)

## join the data frame
re.new <- as.data.frame(re, stringsAsFactors = FALSE)
re.new <- as.data.frame(t(re.new))
final <- left_join(df2, re.new, by = "Contact.PI...Project.Leader")
final[, "searchname"] <- list(NULL)

## export the csv file from data frame
write.csv(final, "Mod.NIHHarvard.csv")

