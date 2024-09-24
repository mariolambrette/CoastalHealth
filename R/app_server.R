#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @export
#' @noRd

app_server <- function(input, output, session) {

  # ##DEBUGGING
  # output$simple_map <- leaflet::renderLeaflet({
  #   leaflet() %>% addTiles()
  # })

  # Call the database connection module
  mod_db_server("db_1")

  observe({
    # Check if the database connection has been established
    req(atlas_env$connection.ready()) # Subsequent code is only executed once connection has been established

    print("running main map module")

    ## Remaining app logic can go here ##

    # Now run the server-side logic of the main map module
    mod_main_map_server("main_map_1")

    # Reactively render the UI for the main map module after connection is ready
    output$map_ui <- renderUI({
      mod_main_map_ui("main_map_1")  # Ensure the UI is rendered after connection is established
    })
  })
}
