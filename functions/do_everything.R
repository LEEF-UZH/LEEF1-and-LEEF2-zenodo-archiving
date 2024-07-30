## do everything

do_for_one_timestamp <- function(all_timestamps,
                                 timestamp_todo,
                                 level1_archives_to_compress,
                                 level2_archives_to_compress,
                                 dir_for_compressed_files,
                                 zenodo)
{
  #print(counter)
  counter <- which(all_timestamps == timestamp_todo)
  
  rec <- create_new_record_and_add_metadata(
    timestamp_todo,
    dir_for_compressed_files,
    zenodo)
  
  #sample_date_number <- 1 # for example
  datapath <- get(paste0("local_data_location_", "level1"))
  files <- level1_archives_to_compress[[counter]]$files
  zipfile <- level1_archives_to_compress[[counter]]$zipfile
  compress_helper(datapath, files, zipfile) 
  
  datapath <- get(paste0("local_data_location_", "level2"))
  files <- level2_archives_to_compress[[counter]]$files
  zipfile <- level2_archives_to_compress[[counter]]$zipfile
  compress_helper(datapath, files, zipfile) 
  
  upload_data(
    "level1",
    rec,
    timestamp_todo,
    dir_for_compressed_files,
    zenodo,
    delete_local_file = TRUE)

  upload_data(
    "level2",
    rec,
    timestamp_todo,
    dir_for_compressed_files,
    zenodo,
    delete_local_file = FALSE)

}