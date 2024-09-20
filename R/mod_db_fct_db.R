#' Create SharePoint Database connection
#'
#' @description
#' Takes a UoE username as an input and connects to the temporary SQL database
#' on the ExeAtlas SharePoint. This is a temporary function until the database is
#' moved to a more permanent location.
#'
#'
#' @param user UoE username to construct filepath
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#'   con <- CreateConnection('ml673')
#' }
#' 
#' @importFrom RSQLite dbConnect SQLite

CreateConnection <- function(user){
  path <- paste0('C:/users/', user, '/University of Exeter/Exe Atlas - Documents/sw/InteractiveMap/ExeAtlas_db.db')
  
  con <- RSQLite::dbConnect(
    RSQLite::SQLite(),
    path
  )
  
  return(con)
}