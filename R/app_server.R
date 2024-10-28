#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @export
#' @noRd

app_server <- function(input, output, session) {
  
  # Prepare environment
  atlas_env$con <- NULL
  atlas_env$connection.ready <- shiny::reactiveVal(FALSE)
  atlas_env$polyID <- NULL
  atlas_env$DisplayLayers <- shiny::reactiveValues(
    mng   = NULL,
    lc    = NULL,
    point = NULL
  )
  atlas_env$LayerState <- shiny::reactiveValues(
    Time = NULL, # Becomes two element list - [[1]] min date, [[2]] max date
    Cat  = NULL  # List of selected categorical value (e.g. species of interest)
  )
  
  # Call the database connection module
  mod_db_server("db_1")
  
  shiny::observeEvent(atlas_env$connection.ready(), {
    # Check if the database connection has been established
    shiny::req(atlas_env$connection.ready()) # Subsequent code is only executed once connection has been established
    
    # Each server side function for all modules can be listed here
    # Mod Map
    mod_Map_server("MainMap")
    # Mod Data_Select
    mod_Data_select_server("DataSelect1")
    # Mod Point_View
    mod_Point_view_server("Point_view_1")
    
    # Quit app when button is pressed
    shiny::observeEvent(input$quitApp, {
      QuitApp()
    })
  })
}
