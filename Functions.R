#INSTALL PACKAGES
install.packages('Rcrawler')
install.packages('rlist')
install.packages('xml2')
install.packages('rvest')
install.packages('dplyr')
install.packages('stringr')
install.packages('XML')
#LOAD LIBRARIES
library(Rcrawler)
library(rlist)
library(xml2)
library(rvest)
library(dplyr)
library(stringr)
library(XML)

#Get list of all article links
all_links <- function(site_url) {
  print("Collecting all Article URLS...")
  collect_start = Sys.time()
  site_html <- readLines(site_url)
  browse_url <- paste(site_url,substr(grep('Browse all', site_html, value = TRUE)[1], 26, 37), sep='')
  
  browse_html <- readLines(browse_url)
  all_url <- paste(site_url,substr(grep('All issues', browse_html, value = TRUE),50,63), sep = '')
  
  all_url_links <- LinkExtractor(all_url)
  year_links <- grep("gbe/issue-archive", all_url_links[[2]], value = TRUE)
  
  volume_links = NULL
  for (i in 1:length(year_links)) {
    print(paste("Obtaining volumes list: ",i,' / ', length(year_links), sep=''))
    x <- LinkExtractor(year_links[i])  
    volume_links <- list.append(volume_links, grep('/gbe/issue', x[[2]], value = TRUE))
    flush.console()
  }
  volumes <- unique(volume_links)[-1]
  
  links = NULL
  for (j in 1:length(volumes)) {
    print(paste("Parsing Volumes: ",j,' / ', length(volumes), sep=''))
    pg <- read_html(volumes[j])
    all_links <- html_attr(html_nodes(pg, "a"), "href")
    links <- list.append(links, grep("https://doi.org/", all_links, value = TRUE))
    flush.console()
  }
  print("Done collecting URLS!")
  print("Article Collection time taken:")
  print(Sys.time() - collect_start)
  return (links)
}


#Get DOI from article
getDOI <- function(html) {
  info <- html %>% html_node(".ww-citation-primary") %>% html_text
  if (is.na(info) == FALSE | length(info) != 0) {
    start <- gregexpr(pattern = 'doi.org', info)
    DOI <- substr(info, start[[1]]+8, nchar(info))
    return (DOI)  
  } else {
    return (NA)
  }
}

#Get Title from article
getTitle <- function(html) {
  title <- html %>% html_node(".article-title-main") %>% html_text %>% trimws(which = c("both"))
  if (is.na(title) == FALSE | length(title) != 0) {
    return (title)  
  } else {
    return (NA)
  }
}

#Get Publication Date from article
getDate <- function(html) {
  date <- html %>% html_node(".citation-date") %>% html_text
  if (is.na(date) == FALSE | length(date) != 0) {
    return (date)
  } else {
    return (NA)
  }
}

#Get Author Affiliations
getAuthorAffil <- function(html) {
  affil <- html %>% html_nodes('.aff')%>% html_text()
  if (length(affil) != 0) {
    aff <- paste(affil, collapse = "; ")
    return (aff)  
  } else {
    return (NA)
  }
}
#Get Keyworkds from article
getKwds <- function(html) {
  kwds <- html %>% html_node(".kwd-group") %>% html_text
  if (is.na(kwds) == FALSE | length(kwds) != 0) {
    return (kwds)  
  } else {
    return (NA)
  }
}

#Get abstract from article
getAbstract <- function(html) {
  abstract <- html %>% html_nodes(xpath = '//section[@class="abstract"]/p')%>% html_text()
  if (length(abstract) != 0) {
    abstract <- paste(abstract, collapse = " ")
    return (abstract)  
  } else {
    return (NA)
  }
}

#Get text from article
getText <- function(html) {
  full_text <- html %>% html_nodes(xpath = '//div[@class="widget-items"]')%>% html_text()
  if (is.na(full_text[2]) == TRUE | length(full_text[2]) == 0) {
    return (NA)
  } else {
    text <- gsub('[\r\n]', ' ', full_text[2])
    return (text)
  }
}

#Extract data from article into row
collectInfo <- function(url) {
  link_html <- read_html(url)
  
  #Get all column info
  doi = getDOI(link_html)
  title = getTitle(link_html)
  author_INFO = getAuthorInfo(link_html)
  authors = author_INFO[1]
  corr = author_INFO[2]
  corr_email = author_INFO[3]
  authoraffil = getAuthorAffil(link_html)
  date = getDate(link_html)
  kwds = getKwds(link_html)
  abstract = getAbstract(link_html)
  text = getText(link_html)
  
  extract_row <- data.frame(DOI = doi, Title = title, Authors = authors, "Author Affiliations" = authoraffil,
                            "Corresponding Author" = corr, "Corresponding Author Email" = corr_email, 
                            "Published Date" = date, Keywords = kwds, Abstract = abstract, "Full Text" = text)
  
  return (extract_row)
}

#Extract Authors, Corresponding authors, Corresponding Author emails
getAuthorInfo <- function(html) {
  author_list <- grep('Editor', html %>% html_nodes(xpath = '//div/div[@class="name-role-wrap"]') 
                      %>% html_text() %>%trimws(which = c("both")), value = TRUE, invert = TRUE)
  authors <- paste(author_list, collapse=', ')
  corresponding_locations <- grep("E-mail|Email", html %>% html_nodes(xpath = '//div[@class="info-card-author"]')
                                  %>% html_text())
  str_replace(corresponding_locations, ' ', ':')
  corr <- author_list[corresponding_locations]
  corresponding_author <- paste(corr, collapse=', ')
  email <- html %>% html_nodes(xpath = '//div[@class="info-author-correspondence"]') %>% html_text() %>% trimws(which = c("both"))
  email <- unique(email)
  email <- paste(email, collapse = '; ')
  emails <- gsub('Corresponding author:|Corresponding authors:|E-mails:|E-mail|Email|Emails|:|[.]$', '', email)
  if (length(authors) == 0) {
    authors = NA
  }
  if (nchar(corresponding_author) == 0) {
    corresponding_author = NA
  }
  if (nchar(emails) == 0) {
    emails = NA
  }
  
  return (c(authors,corresponding_author,emails))
}

download_link <- function(link_url, dir_name) {
  file_name <- paste(dir_name,'/', gsub('/', '', paste(substr(link_url, 17, nchar(link_url)), '.html', sep=''))
                     , sep = '')
  download_xml(link_url, file = file_name) 
}
