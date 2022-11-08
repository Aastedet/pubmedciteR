# Download and unzip the xml files:
library(R.utils)
library(methods)
library(here)
library(xml2)
library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(data.table)
library(tictoc)

# Download and unzip:
ftp_gz <- "https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/pubmed22n0001.xml.gz"
local_gz <- here("downloads", gsub(".*pubmed", "", ftp_gz))
local_xml <- sub(".gz", "", local_gz)

download.file(ftp_gz, local_gz)
closeAllConnections()

gunzip(local_path, remove= TRUE)


# xml2 package-approach:
# https://lecy.github.io/Open-Data-for-Nonprofit-Research/Quick_Guide_to_XML_in_R.html
# https://urbandatapalette.com/post/2021-03-xml-dataframe-r/
# Read data
dat <- read_xml(local_xml)

# Use XML-package to look at contents:
# Root at PubmedArticleSet and nodes 30,000 entries!

doc <- XML::xmlParse(local_xml)
root <- XML::xmlRoot(doc)
xmlName(root) # "PubmedArticleSet"
xmlSize(root) # 30000! children nodes
# Explore contents of what we need in the first entry:
root[["PubmedArticle"]][["MedlineCitation"]][["Article"]]


xml_find_first(dat,
               "/PubmedArticleSet/PubmedArticle/MedlineCitation/Article")
# What we need is all contained within /PubmedArticleSet/PubmedArticle/MedlineCitation/Article/

xml_list <-
  as_list(xml_find_all(
    dat,
    "/PubmedArticleSet/PubmedArticle/MedlineCitation/Article"
  ))

articles <- tibble(article = xml_list) %>%
  unnest_wider(article)

# This leaves a messy tibble with a bunch of variables containing nested lists:

names(articles)

# Only a few variables are necessary:
articles_data <- articles[1:4]

# Clean up:
rm(articles, xml_list)

# Unnest these columns: (https://cran.r-project.org/web/packages/tidyr/vignettes/rectangle.html)

# Unnest articles_data, test timing with tictoc:

tic()
unnested_data <-
  suppressMessages(articles_data %>%
      unnest_wider(col = everything(), names_repair = "unique", names_sep = "") %>%
      unnest_wider(col = everything(), names_repair = "unique", names_sep = "") %>%
      unnest_wider(col = everything(), names_repair = "unique", names_sep = "") %>%
      unnest_wider(col = everything(), names_repair = "unique", names_sep = "")
  )
toc() # 7384.19 secs = 2 hours
# Save intermediate output for further prototyping:
saveRDS(unnested_data, sub(".xml", ".rds", local_xml)) # 2.3 MB disk space


# Should be fairly straight-forward from here on:

# 1: Convert to a data.table for faster wrangling
# 2: Create string variables corresponding to elements of a bibtex entry
# 3: Iterate over all .gz files in the ftp folder
# 4: Bind rows of all files into a single data.table

# 5: Save this data.table to disk
# 6: Create function to write a specific row from the data.table to a bibliography-file with sink():

# 7: User opens the data.table, runs the function on row(s) specified by ordinary filtering operations and writes bibliography on an as-needed basis.
