check_record_files <- function(records, required_timestamps) {

  error_flag = FALSE
    
  res <- records
  
  ## get ids of records where the request returned an error
  error_ids <- res |>
    filter(files == "error")
  if(nrow(error_ids) != 0) {
    print("Some records resulted in the request returning an error; probably incomplete file upload. Delete these records. IDs are in returned list.")
  }
    
  
  res <- res |>
    filter(files != "error") |> 
    mutate(keyword_timestamp = str_sub(subject, 11, 18)) |> 
    mutate(file_timestamp = str_sub(files, 13, 20),
           timestamp_flag = file_timestamp == keyword_timestamp,
           data_level = parse_number(str_sub(files, 6, 11))) |>
  select(-subject) 
    
  
  error_flag = FALSE
  
  message1 <- "Message1, no error."
  if(!(nrow(res) == sum(res$timestamp_flag))) {
    message1 <- "Some timestamps in file names do not match keyword timestamp."; error_flag = TRUE
  }
  
  res <- res |>
    filter(timestamp_flag)
  
  summ_res <- res |>
    group_by(file_timestamp) |> 
    summarise(num_unique_files = length(unique(files)),
              num_level1_files = sum(data_level==1),
              num_level2_files = sum(data_level==2)) |> 
    mutate(correct_files_present = num_unique_files == 2 &
             num_level1_files == 1 &
             num_level2_files == 1)
  
  message2 <- "Message2, no error."
  if(!(nrow(summ_res) == sum(summ_res$correct_files_present))) {
    message2 <- "Some files missing."; error_flag = TRUE
  }
  
  duplicated_timestamps <- summ_res[duplicated(summ_res),]
  message3 <- "Message3, no error."
  if(nrow(duplicated_timestamps) != 0) {
    message3 <- "Some duplicate records."; error_flag = TRUE
  }
  
  if(!error_flag)
    print("No errors in records, no records missing.")
  if(error_flag)
    print("*** Errors present in records. Check error messages.")
  
  
  list(error_ids = error_ids,
       records = res,
       summ_records = summ_res,
       message1 = message1,
       message2 = message2,
       message3 = message3)
  
}