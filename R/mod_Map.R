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
  ns <- shiny::NS(id)
  shiny::tagList(
    # Render map
    leaflet::leafletOutput(ns("map"),  width = "100%", height = "100%")
  )
}
    
#' map Server Functions
#'
#' @noRd
#' 
#' @import leaflet
#' @importFrom shiny observeEvent observe
mod_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Create the basemap
    output$map <- leaflet::renderLeaflet({
      BaseMap()
    })
    
    # Recentre map when triggered (trigger changed in main app server)
    shiny::observeEvent(atlas_env$recentre_trigger(), {
      
      # Reset to default view if no bounds specified
      if (is.null(atlas_env$bounds)) {
        leaflet::leafletProxy("map", session) %>%
          leaflet::setView(lng = -1.4657, lat = 52.5648, 
                           zoom = 7)
      } else {
        # Use calculated opcat bounds if available
        recentre_map(leaflet::leafletProxy("map", session))
      }
      
    })
    
    ## ADD LOGIC FOR DISPLAYING ADDITIONAL LAYERS AS REQUIRED ##
    
    # Display selected opcats
    shiny::observe({
      req(atlas_env$opcats_spatial())
      
      Plot_opcats(leaflet::leafletProxy("map", session))
    })
    
    # Display waterbody spatial data (rivers, lakes and boundaries) as needed
    shiny::observeEvent(atlas_env$wb_triggers$rivers, {
      Plot_wbs_rivers(leaflet::leafletProxy("map", session))
    })
    shiny::observeEvent(atlas_env$wb_triggers$lakes, {
      Plot_wbs_lakes(leaflet::leafletProxy("map", session))
    })
    shiny::observeEvent(atlas_env$wb_triggers$outlines, {
      Plot_wbs_outlines(leaflet::leafletProxy("map", session))
    })
    
    # Display marine area as needed
    shiny::observeEvent(atlas_env$wb_triggers$marine, {
      Plot_marinearea(leaflet::leafletProxy("map", session))
    })
  })
}   
    
## To be copied in the UI
# mod_map_ui("map_1")
    
## To be copied in the server
# mod_map_server("map_1")



