## get files in a draft zenodo record

get_files_in_draft_record <- function(my_zenodo_record)
{
  
  id <- my_zenodo_record$getId()
  timestamp <- my_zenodo_record$metadata$subjects[[4]]
  
  zenReq <- ZenodoRequest$new("https://zenodo.org/api",
                              "GET",
                              paste0("records/", id, "/draft"),
                              accept = "application/json",
                              token= zenodo$getToken(), 
                              logger = zenodo$loggerType)
  zenReq$execute()
  out <- zenReq$getResponse()
  
  if(out$status == 500)
  {
    res <- data.frame(id = id, timestamp = timestamp,
                      files = "error", sizes = "error")
    
    return(res)
  }
    
  if(out$status != 500) {
    files <- unlist(lapply(out$files,
                           function(x) x$key))
    sizes <- unlist(lapply(out$files,
                           function(x) x$size))
    res <- data.frame(id = id, timestamp = timestamp,
                      files = files, sizes = sizes)
    return(res)
  }
  
}

