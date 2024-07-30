

create_archive_filestructure <- function(timestamps,
                                         level_oi,
                                         dir_for_compressed_files) {
  
  dirs_to_compress <- list.dirs(get(paste0("local_data_location_", level_oi)),
                                full.names = FALSE, recursive = FALSE)
  
  archives_filestructure <- pbmcapply::pbmclapply(
    timestamps,
    function(x) {
      list(
        level = level_oi,
        timestamp = x,
        zipfile = file.path(
          dir_for_compressed_files,
          paste0(
            "data", "_",
            level_oi, "_",
            x, ".",
            "zip"
          )
        ),
        files = grep(pattern = x,
                     x = dirs_to_compress,
                     value = TRUE)
      )
    },
    mc.cores = cores
  )
  archives_filestructure
}




compress_helper <- function(datapath, files, zipfile) {
  
  olddir <- getwd()
  result <- NULL
  on.exit({
    setwd(olddir)
    if (is.null(result)) {
      unlink(zipfile)
    }
    return(result)
  })
  
  #dir.create(dirname(zipfile), showWarnings = FALSE, recursive = TRUE)
  
  setwd(file.path(datapath))
  
  utils::zip(
    zipfile = zipfile,
    extras = "-q",
    files = files
  )
  result <- zipfile
}

compress_multi <- function(archives_to_compress) {
  
  message("\nProcessing ", nrow(archives_to_compress), " directories - this will take some time!\n")
  result <- pbmcapply::pbmclapply(
    archives_to_compress,
    function(x) {
      compress_helper(
        datapath = get(paste0("local_data_location_", x$level)),
        files = x$files,
        zipfile = x$zipfile
      )
    },
    mc.cores = cores
  )
  result
}
