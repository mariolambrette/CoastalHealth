## Utility functions


#' Quit app
#' 
#' @description
#' Function to clean up database connection and quit app
#' 
#' @return None
#' 
#' @importFrom RSQLite dbDisconnect
#' @importFrom shiny stopApp
#' 

QuitApp <- function(){
  # Disconnect database
  if (!is.null(atlas_env$con)) {
    RSQLite::dbDisconnect(atlas_env$con)
  }
  
  # Quit app
  shiny::stopApp()
}