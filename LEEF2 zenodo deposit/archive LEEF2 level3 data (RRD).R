## upload to zenodo the RRD

## LEEF2 RRD is stored in parquet files.
## It is around 200 GB so it too big for one zenodo record (limit 50 GB)
## The database has 25 tables, but only two of these are responsible
## for the majority of the size:
## "flowcam__algae_traits" - 12 GB
## "flowcytometer__flowcytometer_traits" -- 127 GB
## We'll zip up everything apart from the flowcyt traits.
## We'll make three zips of the flowcyt traits.

## Here is information about working with partitioned parquet datasets
## https://arrow.apache.org/docs/r/articles/dataset.html


#devtools::install_github("LEEF-UZH/LEEF.analysis")

## This version of the data was used: parquet_v2.3.8-LEEF-2_20240314_renamed

rm(list = ls())
library(plyr)
library(tidyverse)
library(ggplot2)
library(here)
#library(cowplot)
library(DBI)
library(RSQLite)
library(LEEF.analysis)
library(parquetize)


## Prepare zenodo
library(zen4R)
#library(deposits)
files.sources = list.files(file.path("..", "functions"), full.names = TRUE)
sapply(files.sources, source)
#parallel::detectCores()
cores <- 1
zenodo_sandbox_token <- "..."
zenodo_token <- "..."

sandbox <- FALSE
if (sandbox) {
  url_z <- "https://sandbox.zenodo.org/api"
  zenodo <- zen4R::ZenodoManager$new(
    url = url_z,
    token = zenodo_sandbox_token,
    logger = "INFO")
} else {
  url_z <- "https://zenodo.org/api"
  zenodo <- zen4R::ZenodoManager$new(
    url = url_z,
    token = zenodo_token,
    logger = "INFO"
  )
}

## create a new rrd (level3 data) record
rec <- leef2_rrd_create_new_record_and_add_metadata(zenodo)
zip_file <- here("upload_zenodo/majority.zip")
zenodo$uploadFile(zip_file, rec)


rec <- leef2_rrd_create_new_record_and_add_metadata(zenodo)
zip_file <-here("upload_zenodo/flowcytometer_traits_batch1.zip")
zenodo$uploadFile(zip_file, rec)  

rec <- leef2_rrd_create_new_record_and_add_metadata(zenodo)
zip_file <-here("upload_zenodo/flowcytometer_traits_batch2.zip")
zenodo$uploadFile(zip_file, rec)  

rec <- leef2_rrd_create_new_record_and_add_metadata(zenodo)
zip_file <-here("upload_zenodo/flowcytometer_traits_batch3.zip")
zenodo$uploadFile(zip_file, rec)  
