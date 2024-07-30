## upload to zenodo the level3 rrd of LEEF1

## LEEF1 RRD is stored in a sqlite database.
## It is around 200 GB so it too big for one zenodo record (limit 50 GB)
## The database has 25 tables, but only two of these are responsible
## for the majority of the size:
## "flowcam__algae_traits"
## "flowcytometer__flowcytometer_traits"
## To allow these to be split up, we convert them into parquet data files, one for each timestamp
## We also put each of the other smaller tables into a parquet of its own

## It turns out that conversion of the sqlite into parquet reduced the size to less than 50 GB.
## Hence one zenodo record could contain all of the LEEF1 level3 data 

## Here is information about working with partitioned parquet datasets
## https://arrow.apache.org/docs/r/articles/dataset.html


#devtools::install_github("LEEF-UZH/LEEF.analysis")

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


## location of LEEF1 RRD database
db <- ("/Volumes/Groups/LEEF/RRD.Reclassification_final/LEEF.RRD.v1.8.5_final_vacuumed.sqlite")
## Open connection
con <- DBI::dbConnect(RSQLite::SQLite(),
                      db,
                      flags = RSQLite::SQLITE_RO)
tables <- dbListTables(con)
length(tables)
tables

## convert to parquet
#this_table <- "flowcam__algae_traits"
this_table <- "flowcytometer__flowcytometer_traits"
partitions <- get_partitions(con, table = this_table, column = "timestamp")
#timestamp <- partitions[1]
#timestamp
# loop over the partitions
for (timestamp in partitions) {
  path_to_parquet <- here("parquet", this_table)
  #file.info(path_to_parquet)$isdir
  dir.create(path_to_parquet, recursive = TRUE)
  dbi_to_parquet(
    conn = con,
    # use glue_sql to create the query filtering the partition
    sql_query = glue::glue_sql("SELECT * FROM {this_table} where Timestamp = {timestamp}",
                               .con = con),
    # add the partition name in the output dir to respect parquet partition schema
    path_to_parquet = file.path(path_to_parquet, paste0("timestamp_", timestamp, ".parquet"))
    #max_memory = 2 / 1024,
  )
}

## for the remaining tables just convert to non-partitioned parquet
tables <- dbListTables(con)
dont_do_these <- c("flowcam__algae_traits", "flowcytometer__flowcytometer_traits")
tables_to_use <- tables[!(tables %in% dont_do_these)]
path_to_parquet <- here("parquet")

table_oi <- tables_to_use[1]
for(table_oi in tables_to_use) 
  dbi_to_parquet(
    conn = con,
    # use glue_sql to create the query filtering the partition
    sql_query = glue::glue_sql("SELECT * FROM {table_oi}",
                               .con = con),
    # add the partition name in the output dir to respect parquet partition schema
    path_to_parquet = file.path(path_to_parquet, paste0(table_oi, ".parquet"))
    #max_memory = 2 / 1024,
  )
  

## At this point we compressed the folder and all subfolders into a single zip file for upload to zenodo.
## This compression step was not done in this script.


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
rec <- leef1_rrd_create_new_record_and_add_metadata(zenodo)

## upload data files
zip_file <- here("LEEF1_level3_data_parquet.zip")
zenodo$uploadFile(zip_file, rec)
