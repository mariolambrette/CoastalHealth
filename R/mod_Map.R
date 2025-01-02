#' map UI Function
#'
#' @description A shiny Module. Renders the leaflet map, including all
#' additional layers in a self-contained container to be displayed as needed
#' in the Coastal Health Data Explorer app
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList fluidPage
#' @importFrom leaflet leafletOutput
mod_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Render map
    shiny::fluidPage(
      leaflet::leafletOutput(ns("map"), width = "100%", height = "100hv")
    )
  )
}
    
#' map Server Functions
#'
#' @noRd 
mod_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Create the basemap
    output$map <- leaflet::renderLeaflet({
      BaseMap()
    })
    
    ## ADD LOGIC FOR DISPLAYING ADDITIONAL LAYERS AS REQUIRED ##
    
  })
}   
    
## To be copied in the UI
# mod_map_ui("map_1")
    
## To be copied in the server
# mod_map_server("map_1")
