# Archiving datasets from two experiments conducted at the University of Zurich

The two experiments are named LEEF1 and LEEF2. Each has four levels of data:

-   level0: raw, unprocessed, e.g., cxd files from the video microscopy system. This will not be archived--it will be lost.
-   level1: same information as level0 data, but file formats loss-less converted to open format and compressed, with some aggregation.
-   level2: contains information extracted from level1 data; information becomes more useful for data analysis; level1 to level2 involves loss of information.
-   level3: also termed "research ready". For example contains time series of population abundances.

levels 1, 2, and 3 are archived on zenodo. Total file size is greater than the max allowed by one zenodo record, so we split data across multiple records.

Scripts and functions for the data preparation, zenodo record creation, bibliographic metadata, and data file upload are in this repository / zenodo record. There are also scripts for finding the zenodo records and for downloading data files (in the level1 and level2 archiving qmd file).

Running the scripts may require addition of tokens for access to zenodo.

Other repositories associated with the LEEF experiments can be found with this search: https://zenodo.org/search?q=LEEF%20AND%20UZH&l=list&p=1&s=10&sort=bestmatch 