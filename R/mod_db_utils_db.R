# Function to check username is valid
validate_username <- function(username) {
  
  if(file.exists(paste0('C:/users/', username, '/University of Exeter/Exe Atlas - Documents/sw/InteractiveMap/ExeAtlas_db.db'))){
    return(TRUE)
  } else{
    if(dir.exists(paste0('C:/users/', username, '/University of Exeter/Exe Atlas - Documents'))){
      return(TRUE)  
    } else{
      return(FALSE)
    }
  }
}