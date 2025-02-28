# .onLoad function and environment definition

.onLoad <- function(libname, pkgname){
  
  opcats_path <- system.file(
    "extdata", 
    "OperationalCatchments.csv",
    package = pkgname
  )
  
  env_setup()
  
  if (file.exists(opcats_path)) {
    atlas_env$opcats_all <- data.table::fread(opcats_path)
  }
  
}

# Create package environment with placeholders for required variables
atlas_env <- new.env(parent = emptyenv())