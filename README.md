# pubmedciteR
An R package for easier citation of pubmed articles in restricted virtual environments


## Aim

The aim of this package is to make life easier for anyone writing research articles within a restricted virtual environment, e.g. using `Rmarkdown` with the `rticles`-package on a remote server where the outside internet cannot be accessed and citation data cannot be downloaded. Hopefully, this project can provide an alternative to manually typing in every bibliography entry.

## Overview of planned features:

- Create functions to enable easy downloading of PubMed's annually updated baseline files and creating a local, easy-to-work-with copy of the citation data:
  - Download and and convert the gz-zipped xml files found at https://ftp.ncbi.nlm.nih.gov/pubmed/baseline/ into a keyed `data.table` object and save it locally.
    - The user's system admin must then be persuaded to either run these functions and download the baseline files (or download the `data.table` output created by the user) and make the output available within the restricted virtual environment.
- Create functions to quickly and easily search the `data.table` for citations and add them to a bibliography.

## Ideas


