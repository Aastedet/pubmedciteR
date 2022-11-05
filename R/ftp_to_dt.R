# Download and unzip the xml files:
library(R.utils)
library(methods)
library(here)
library(XML)
library(data.table)

# Download and unzip:
ftp_gz <- "https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/pubmed22n0001.xml.gz"
local_gz <- here("downloads", gsub(".*pubmed", "", ftp_gz))
local_xml <- sub(".gz", "", local_gz)

download.file(ftp_gz, local_gz)
closeAllConnections()

gunzip(local_path, remove= TRUE)

# XML package approach:


# From here, xlm -> data.table should be easy with xmlToDataFrame(), but the nested structure derails it:
doc <- xmlParse(local_xml)

root <- xmlRoot(doc)
xmlName(root) # "PubmedArticleSet"
xmlSize(root) # 30000! children nodes

nm <- getNodeSet(doc, "/PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal")

df <-
  xmlToDataFrame(doc, nodes = nm)
setDT(df)

# flatxml approach
library(flatxml)
df2 <- fxml_importXMLFlat(local_xml)

# xmlconvert approach (seems promising, but can't make it work: https://www.r-bloggers.com/2020/11/converting-xml-data-to-r-dataframes-with-xmlconvert/)
df2 <-
  xml_to_df(text = local_xml, field.names = "/PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal", no.hierarchy = T)

child1 <- root[["PubmedArticle"]][["MedlineCitation"]][["Article"]]
journal_entries <- root[[1]][["MedlineCitation"]][["Article"]]
journal_entries <- root["PubmedArticle"]
journal_entries[[]]
df <- xmlToDataFrame(journal_entries)

# Returns a two-column dataframe:
names(df) # "MedlineCitation" "PubmedData"

# We can ignore the PubmedData part, as we only need the data from
# PubmedArticleSet/PubmedArticle/MedlineCitation/Article

# Unnesting name space: XML-package approach:
# Approach from https://stackoverflow.com/questions/47254923/nested-xml-to-data-frame-in-r
df <-
  xmlToDataFrame(doc,
                 nodes = getNodeSet(
                   doc,
                   "//nm:PubmedArticleSet/PubmedArticle/MedlineCitation/Article",
                   namespaces=c(nm="urn:HM-schema")
                 ))





# xml2 package-approach: https://urbandatapalette.com/post/2021-03-xml-dataframe-r/
# Should work, but needs more code & memory=slow
library(xml2)

xml_3 <- xml_find_all(read_xml(local_xml), ".//Journal", flatten = FALSE)

xml_list <- as_list(read_xml(local_xml))



# Misc bookmarks:

# https://link.springer.com/content/pdf/10.1007/978-1-4614-7900-0_3.pdf
# https://link.springer.com/content/pdf/10.1007/978-1-4614-7900-0_4.pdf

# https://www.geeksforgeeks.org/working-with-xml-files-in-r-programming/


# xml2: https://www.robwiederstein.org/2021/03/05/xml-to-dataframe/
# https://stackoverflow.com/questions/33446888/r-convert-xml-data-to-data-frame
# https://rud.is/rpubs/xml2power/
