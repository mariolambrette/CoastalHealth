#' Map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList fluidPage
#' @importFrom leaflet leafletOutput

mod_Map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Render map
    shiny::fluidPage(
      leaflet::leafletOutput(ns("map"), width = "100%", height = "100vh")
    )
  )
}
    
#' Map Server Functions
#'
#' @noRd 
#' 
#' @importFrom shiny observe req
#' @importFrom leaflet renderLeaflet leafletProxy clearGroup

mod_Map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Ensure that the database connection is ready before rendering the map
    req(atlas_env$connection.ready())
    
    output$map <- leaflet::renderLeaflet({
      BaseMap()
    })
    
    # Reactively add management layers based on selection
    shiny::observe({
      # Ensure mng_layers is not NULL before proceeding
      mng_layers <- shiny::req(atlas_env$DisplayLayers$mng)
      
      # Use leafletProxy to clear and then add the selected layers
      leaflet::leafletProxy(ns("map")) %>%
        leaflet::clearGroup("MNG")
      
      # Iterate through selected layers and add them to the map
      sapply(
        mng_layers,
        function(lyr) {
          cmd <- AddLayers(add_layers = lyr)
          eval(parse(text = cmd))
        }
      )
    })
    
    # Reactively add Land use layer based on selection
    shiny::observe({
      lu_layer <- req(atlas_env$DisplayLayers$lu)
      
      leaflet::leafletProxy(ns("map")) %>%
        leaflet::clearGroup("LC")
      
      cmd <- AddLayers(add_layers = lu_lyr)
      eval(parse(text = cmd))
    })
    
    # Reactively add data point layers
    shiny::observe({
      point_lyrs <- req(atlas_env$DisplayLayers$point)
      
      ## ADD FUNCTIONLITY FOR USERS TO SELECT A MAIN POINT LAYER ##
      main_points <- point_lyrs[[1]]
      
      leaflet::leafletProxy(ns("map")) %>%
        leaflet::clearGroup("POINT")
      
      sapply(
        point_lyrs,
        function(lyr){
          cmd <- AddLayers(add_layers = lyr)
          eval(parse(text = cmd))
        }
      )
    })
    
    ## POLYGON CLICK FUNCTIONALITY
    
    # Load in polygon data and lookup table
    poly_data <- dplyr::tbl(atlas_env$con, "POLY_data") %>%
      dplyr::collect()
    poly_lu <- dplyr::tbl(atlas_env$con, "POLY_lookup") %>%
      dplyr::collect()
    
    shiny::observeEvent(input$map_shape_click, {
        
      if (!is.null(atlas_env$polyID) &&
          input$map_shape_click["id"] %>%
            as.numeric() == atlas_env$polyID) {
      
        leaflet::leafletProxy(ns("map")) %>%
          leaflet::clearGroup("highlighted")
      
      } else {
        
        # Extract ID of clicked polygon
        atlas_env$polyID <- input$map_shape_click["id"] %>%
          as.numeric()
        
        # Highlight clicked polygon & upstream and downstream
        toHighlight <- HighlightPolys(selectID = atlas_env$polyID)
        
        leaflet::leafletProxy(ns("map")) %>%
          leaflet::clearGroup("highlighted") %>%
          leaflet::addPolygons(
            data = toHighlight,
            color = NA,
            weight = 0,
            opacity = 1,
            fill = T,
            fillOpacity = 1,
            fillColor = toHighlight$colour,
            group = 'highlighted',
            options = leaflet::pathOptions(pane = "highlight_polys",
                                           clickable = F)
          )
      }
    
    })
    
  })
}
    
## To be copied in the UI
# mod_Map_ui("Map_1")
    
## To be copied in the server
# mod_Map_server("Map_1")
