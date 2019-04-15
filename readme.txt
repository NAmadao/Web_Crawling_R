MainProgram.R - This is the main script that first runs the 'Functions.R' script. It then extracts all the article links into a list "article_links". Then it loops through the list and fills a dataframe "extracted_DF" where each row contains each articles DOI, Title, Authors, Author Affiliations, Corresponding Author, Corresponding Author's Email, Publication Date, Abstract, Keywords, Full Text (Textual format). As we loop through each article the script also downloads an html file for each article using download_link() function that we created in the functions.R script. After filling the dataframe we write to a txt file "Genome Biology and Evolution.txt".

Functions.R - This script contains a list of all the libraries that need to be installed and loaded. It also contains all the functions that we need to complete our task:

all_links() : This function goes from the homepage of the journal and creates a list of all the articles.
getDOI(): parse and return the DOI from the article page
getDate(): parse and return the published date from the article page
getAuthorAffil(): parse and return Author Affiliations for all the authors from the article page.
getKwds(): parse and return the keywords from the article page
getAbstract(): parse and return the abstract from the article page.
getText(): parse and return Full Text from the article page. This includes the abstarct too.
getAuthorInfo(): parse and returns a list of all the Authors, Corresponding Authors and Corresponding Author Emails
collectInfo(): Collects all the Information requried from the article page and returns a dataframe row.
download_link(): downloads the article and stores it by its DOI name.

This file requires around 2hours to collect all the data for all the articles. We have about 1978 articles.

ReadTxtFile.R - This script is used to read the "Genome Biology and Evolution.txt" into a dataframe "gbe_DF".