#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Call the database connection module
  mod_db_server("db_1")
  
  observe({
    # Check if the database connection has been established
    req(!is.null(atlas_env$con)) # Subsequent code is only executed once connection has been established
    
    ## Remaining app logic can go here ##
  })
}
