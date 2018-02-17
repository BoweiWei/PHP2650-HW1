library(XML)
library(RCurl)
library(httr)
library(dplyr)
library(RSelenium)
library(stringr)
library(rvest)
library(RDocumentation)
library(stringr)
## input the S&P 100 list
#tables <- GET("http://en.wikipedia.org/wiki/S%26P_100")
#tables <- readHTMLTable(rawToChar(tables$content))
#SPList <- head(tables[3])
#SPList <- SPList[[1]]
#SPList[17,1] <- 'BRK-B'
#symSP <- SPList$Symbol

url <- "https://en.wikipedia.org/wiki/S%26P_100"

SP100.table <- url %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="mw-content-text"]/div/table[3]') %>%
  html_table()

SP100.table <- SP100.table[[1]]

# Change BRK.B to BRK-B

SP100.table$Symbol[SP100.table$Symbol == 'BRK.B'] <- 'BRK-B'

## input the yahoo finance data
#URLlist <- NULL
#for (i in 1:length(symSP)) {
#    URLlist[i] <- paste("https://finance.yahoo.com/quote/", symSP[[i]], "/history?p=", symSP[[i]], sep = "")
#}

## Try the standard way for downloading webpages 
theurl <- "https://finance.yahoo.com/quote/XOM/history?p=XOM"
a <- getURL(theurl)
a <- readLines(tc <- textConnection(a)); close(tc)
fileConn<-file("output.html") # no download data button
writeLines(a, fileConn)
close(fileConn)

rs <- rsDriver(extraCapabilities = list(
  chromeOptions = 
    list(prefs = list(
      "profile.default_content_settings.popups" = 0L,
      "download.prompt_for_download" = FALSE,
      "download.default_directory" = "/Users/boweiwei/Documents/PHP2650-HW1/data"
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

## download the csv file in a loop
for (s in 1:length(SP100.table$Symbol)) {
  downloadHPYahoo(SP100.table$Symbol[s])
}

downloadHPYahoo("BRK-B")

## add a column into the csv file
add.col <- function(symbol) {
  df <- read.csv(past0(symbol, ".csv"), header = TRUE, sep = ",")
  df <- left_join()
}

## Question 2
## input data from csv file
df2 <- read.csv("NIHHarvard.csv", header = TRUE, sep = ",")

## remove the activity starting as T or F and save it as df3
df2 %>%
  filter(substring(as.character(Activity),1,1) != "T" & substring(as.character(Activity),1,1) != "F") -> df3
tailremoved <- sub("\\s+$", "", df3$Contact.PI...Project.Leader)
namelist <- unique(tailremoved)
namelist.n <- lapply(namelist, str_replace_all, fixed("   "), "   ")

## remove the middle name and modify the name for search url
#namelist.s <- for (i in 1: length(namelist)) {
#  if (length(gregexpr(namelist[1])[[1]]) +1 >= 3) {
##    namelist.s[i] <- gsub("\\s*\\w*$", "", namelist[i])
#  } else {namelist.s[i] <- namelist[i]}
#}
namelist.e <- regexec("^[A-z].*, [A-z]*", namelist)
names <- regmatches(namelist, namelist.e)

namelist.s <- gsub("\\s*\\w*$", "", namelist)
namelist.s <- lapply(namelist.s, str_replace_all, fixed(", "), "%2C+")
#namelist.s <- lapply(namelist.s, str_replace_all, fixed(" "), "+")


## approaches 
library(xml2)                           # another XML package
#html <- htmlParse( content( GET(url) , as="parsed")  )

getGS <- function(aname, affli, bname) {
  re <- NULL
  topicname <- paste0(aname, "%5Author%5D+AND+", affli, "%5Affiliation%5D") 
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

## point out the NA means only one passage and open the passage link directly, 
## so conclude this situation as 1
#re[is.na(re)] = 1

## join the data frame
re.new <- as.data.frame(re, stringsAsFactors = FALSE)
re.new <- as.data.frame(t(re.new))
final <- left_join(df3, re.new, by = "Contact.PI...Project.Leader")
final[, "searchname"] <- list(NULL)

## export the csv file from data frame
write.csv(final, "Mod.NIHHarvard.csv")

