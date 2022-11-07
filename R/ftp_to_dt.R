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

# Unnest these columns: (https://cran.r-project.org/web/packages/tidyr/vignettes/rectangle.html)
unlisted_1 <- unnest_wider(articles_data, col = )



# Collection of links and code:



# https://rud.is/rpubs/xml2power/ - approach:
xtrct <- function(doc, target) { xml_find_all(doc, target) %>% xml_text() %>% trimws() }

xtrct_df <- function(doc, top) {
  xml_find_first(doc, sprintf(".//%s", top)) %>%
    xml_children() %>%
    xml_name() %>%
    purrr::map(~{
      xtrct(doc, sprintf(".//%s/%s", top, .x)) %>%
        list() %>%
        set_names(tolower(.x))
    }, .name_repair = "unique")
  # %>%
  #   purrr::flatten_df() %>%
  #   readr::type_convert()
}

authorlist_df <- xtrct_df(dat, "AuthorList")


# Promising links for xml2
# xml2: https://www.robwiederstein.org/2021/03/05/xml-to-dataframe/
# https://stackoverflow.com/questions/33446888/r-convert-xml-data-to-data-frame





# XML:
# Misc bookmarks:

# https://link.springer.com/content/pdf/10.1007/978-1-4614-7900-0_3.pdf
# https://link.springer.com/content/pdf/10.1007/978-1-4614-7900-0_4.pdf

# https://www.geeksforgeeks.org/working-with-xml-files-in-r-programming/

# From here, xlm -> data.table should be easy with xmlToDataFrame(), but the nested structure derails it:
doc <- xmlParse(local_xml)

root <- xmlRoot(doc)
xmlName(root) # "PubmedArticleSet"
xmlSize(root) # 30000! children nodes

# Explore contents of what we need in the first entry:
root[["PubmedArticle"]][["MedlineCitation"]][["Article"]]


nm <- getNodeSet(doc, "/PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal")

nm <- getNodeSet(doc, "//[starts-with(name(), 'Author')]")

df <-
  xmlToDataFrame(doc, nodes = nm)



journal_entries <- root[[1]][["MedlineCitation"]][["Article"]]
journal_entries <- root["PubmedArticle"]
journal_entries[[]]
df <- xmlToDataFrame(journal_entries)

# We only need the data from
# PubmedArticleSet/PubmedArticle/MedlineCitation/Article

# Unnesting name space: XML-package approach (not the same issue):
# Approach from https://stackoverflow.com/questions/47254923/nested-xml-to-data-frame-in-r


# xmlconvert approach (seems promising, but can't make it work: https://www.r-bloggers.com/2020/11/converting-xml-data-to-r-dataframes-with-xmlconvert/)
df2 <-
  xml_to_df(text = local_xml, field.names = "/PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal", no.hierarchy = T)



