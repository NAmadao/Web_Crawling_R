#rm(list=ls())
#Run Functions.R file to load all libraries and functions required
source("Functions.R")

#Site Name
site_url = "https://academic.oup.com/gbe" #Journal homepage
dir_name = "article_htmls" #HTML saved to this folder
options(warn=-1)
dir.create(dir_name)

#Get all the article links
article_links <- all_links(site_url)

#Extract data from articles into extracted_DF  and download the HTML into dir_name folder

extracted_DF = data.frame(DOI=c(), Title=c(), Authors=c(), "Author Affiliations"=c(), "Corresponding Author"=c(), 
                          "Corresponding Author Email"=c(), "Published Date"=c(), Keywords=c(), Abstract=c(), 
                          "Full Text"=c())
  
print("Extracting data...")
print(paste("Total number of articles:",length(article_links)), sep='')
extract_start = Sys.time()
for (i in 1:length(article_links)) {
  print(paste("Extracting Article: ",i,' / ', length(article_links), sep=''))
  extracted_DF = rbind(extracted_DF, collectInfo(article_links[i]))
  download_link(article_links[i], dir_name)
  flush.console()
}
print("Extraction time taken")
print(Sys.time() - extract_start)

#Write extracted data into 
dput(extracted_DF, "Genome Biology and Evolution.txt")
