# Download and unzip the xml files:
library(R.utils)
library(methods)

ftp_path <- "https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/pubmed22n0001.xml.gz"

local_path <- here("downloads", gsub(".*pubmed", "", ftp_path))

download.file(ftp_path, local_path)
closeAllConnections()

gunzip(local_path, remove= TRUE)

# XML package approach:
library(XML)

# From here, xlm -> data.table should be easy with xmlToDataFrame(), but the nested structure derails it:
doc <- xmlParse(sub(".gz", "", local_path),useInternalNodes = TRUE)
df <- xmlToDataFrame(sub(".gz", "", local_path))

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
# Should work, but needs more code
library(xml2)

xml_list <- as_list(read_xml(sub(".gz", "", local_path)))



# Misc: https://www.geeksforgeeks.org/working-with-xml-files-in-r-programming/
