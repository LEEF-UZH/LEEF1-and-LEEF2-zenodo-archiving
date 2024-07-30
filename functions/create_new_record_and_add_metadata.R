#' Add bibliographic metadata to a `ZenodoRecord`
#'
#' @param metadata_bib an object of class `metadata_bib` as created by the
#'   function `new_metadata_bib()`.
#' @param rec an object of class `ZenodoRecord` s created by
#'   `zen4R::ZenodoRecord$new()`. If missing, a new one will be created.
#'
#' @return the object `rec` with the metadata in `metdata_bib` added.
#'
#' @md
#'
#' @import zen4R
#'
#' @export
#'
#' @examples
create_new_record_and_add_metadata <- function(
    #level_oi,
    timestamp_oi,
    dir_for_compressed_files,
    zenodo)
  {
  
  
  metadata_json <- jsonlite::read_json("metadata_LEEF1_sampledate_template.json")
  metadata_json <- metadata_json[grep("^_", names(metadata_json), invert = TRUE)]

  metadata_json$title <- paste0("LEEF1 data from ", as.Date(timestamp_oi, "%Y%m%d"))
  metadata_json$keywords <- c(
    #metadata_json$keywords,
    #level_oi,
    "LEEF1",
    "data",
    "Level1 and Level2 data",
    paste0("timestamp_", timestamp_oi)
  )
  # Create and populate records -------------------------------------------------
 # rec <- add_metadata_bib(metadata_json)
  
  rec = zen4R::ZenodoRecord$new()
  
  rec$setTitle(metadata_json$title)
  rec$setDescription(metadata_json$description)
  rec$setSubjects(metadata_json$keywords)
  #rec$addCommunities(metadata_json$communities)
  rec$setResourceType(metadata_json$upload_type)
  #rec$addCreator(metadata_json$creator)
  rec$setPublicationDate(Sys.Date())
  rec$setPublisher(metadata_json$publisher)
  
  #aut <- metadata_json$creator[[1]]
  #rec$addCreator(
  #  name = aut$name,
  #  ##firstname = aut$firstname,
  #  #lastname = aut$lastname,
  #  affiliations = aut$affiliations,
  #  orcid = aut$orcid
  #)
  
  lapply(
    metadata_json$creator,
    function(aut) {
      rec$addCreator(
        name = aut$name,
        ##firstname = aut$firstname,
        #lastname = aut$lastname,
        affiliations = aut$affiliation,
        orcid = aut$orcid
      )
    }
  )
  for(i in 1:length(metadata_json$creator))
    rec$metadata$creators[[i]]$affiliations <- metadata_json$creator[[i]]$affiliation
  
  
  
    rec$setVersion(metadata_json$version)
  rec$addLanguage(metadata_json$language)
  
  #print(metadata_json$embargo_active)
  rec$setAccessPolicyFiles(access = metadata_json$access_policy_files)
  rec$setAccessPolicyEmbargo(active = metadata_json$embargo_active,
                             until = as.Date(metadata_json$embargo_until),
                             reason = "")
  
  #rec$setAccessRight(metadata_json$access_right)
  #rec$setEmbargoDate(metadata_json$embargo_date)
  #rec$setLicense(metadata_json$license)
  lapply(
    metadata_json$contributor,
    function(con) {
      rec$addContributor(
        name = con$name,
        #firstname = con$firstname,
        #lastname = con$lastname,
        role = con$type,
        affiliations = con$affiliation,
        orcid = con$orcid
      )
    }
  )
  for(i in 1:length(metadata_json$contributor))
    rec$metadata$contributor[[i]]$affiliations <- metadata_json$contributor[[i]]$affiliation
  
  
  rec$setGrants(metadata_json$grants)

  
  # Upload records ----------------------------------------------------------
  rec <- zenodo$depositRecord(rec)
  #doi <- rec$getDOI()
  
    

  return(rec)
}


upload_data <- function(
  level_oi,
  rec,
  timestamp_oi,
  dir_for_compressed_files,
  zenodo,
  delete_local_file = FALSE)
{
  
  zip_file <- file.path(
    dir_for_compressed_files,
    paste0("data_", level_oi, "_", timestamp_oi, ".zip"))
  file.exists(zip_file)
  zenodo$uploadFile(zip_file, rec)

  if(delete_local_file)
    file.remove(zip_file)
  
  return(rec)
}


