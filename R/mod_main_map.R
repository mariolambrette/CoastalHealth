#' main_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyjs useShinyjs
#' @importFrom leaflet leafletOutput
#' @importFrom reactable reactableOutput
#' @importFrom plotly plotlyOutput

mod_main_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::fluidPage(
      shinyjs::useShinyjs(),
      
      tags$head(
        tags$style(
          HTML("
            #map {
              height: 100vh !important;
            }
            .sidebar {
              height: 100vh;
              overflow-y: auto;
            }
            body {
              font-size: 14px; /* Set default font size */
            }
            .header-font {
              font-size: 22px !important;
              font-weight: 600 !important; /* Override font size for specific elements */
            }
          ")
        )
      ),
      sidebarLayout(
        mainPanel(
          leaflet::leafletOutput(ns("map"), width = "100%", height = "100%")
        ),
        sidebarPanel(
          class = "sidebar",
          width = 4.8,  # Adjust this value to make the sidebar wider
          div(
            "Layer Selection",
            class = "header-font"
          ),
          div(
            class = "mng-select",
            style = "margin-top: 24px; text-align: left; padding-left: 20px;",
            uiOutput(ns("mng_layer_select_ui"))
          ),
          div(
            class = "dat-select",
            style = "margin-top: 24px; text-align: left; padding-left: 20px;",
            uiOutput(ns("dat_layer_select_ui"))
          ),
          div(
            "Subcatchment Data",
            class = "header-font"
          ),
          div(
            class = "poly-summary",
            reactable::reactableOutput(ns("poly_summary"))
          ),
          div(
            class = "details",
            plotly::plotlyOutput(ns("details"))
          )
        )
      )
    )
  )
}
    
#' main_map Server Functions
#'
#' @noRd
#' 
#' @importFrom magrittr `%>%`
#' @importFrom dplyr filter tbl collect sql
#' @importFrom shinyWidgets pickerInput
#' @importFrom leaflet renderLeaflet leafletProxy clearGroup

mod_main_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Read in layer index file to provide dropdown menu of plotting options
    SHP_index <- dplyr::tbl(atlas_env$con, "SHP_lookup") %>%
      dplyr::filter(!(dplyr::sql('SUBSTR(SHP_name, INSTR(SHP_name, "SPA"), 3) COLLATE BINARY = "SPA"'))) %>%
      dplyr::collect()
    
    # Extract list of layers for the user to choose from
    layers <- SHP_index$SHP_name %>%
      as.list()
    layers <- c("none", layers) # Add a null option to show no additional layers
    names(layers) <- c("None", SHP_index$disp_name)
    
    # Load in polygon data and lookup table
    poly_data <- dplyr::tbl(atlas_env$con, "POLY_data" ) %>%
      dplyr::collect()
    poly_lu <- dplyr::tbl(atlas_env$con, "POLY_lookup") %>%
      dplyr::collect()
    
    # Management layer select drop down menu
    output$mng_layer_select_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(
        inputId = "mng_layer",
        label = "Select Management Type:",
        choices = layers[grepl("MNG", layers)],
        options = list(
          `none-selected-text` = "No selection",
          `live-search` = TRUE,
          `actions-box` = TRUE,  # Enable actions box to provide "Deselect All" functionality
          `deselect-all-text` = "Deselect All"
        ),
        multiple = TRUE  # Allow multiple selection
      )
    })
    
    # Data layer drop down menu (allows multiple selections to be made so that multiple data
    # layers can be displayed at the same time)
    output$dat_layer_select_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(
        inputId = "dat_layer",
        label = "Select Data Layer: ",
        choices = layers[grepl("DAT", layers)],
        options = list(
          `actions-box` = FALSE,
          `deselect-all-text` = "Deselect All",
          `none-selected-text` = "No selection"
        ),
        multiple = TRUE
      )
    })
    
    # Leaflet base map - contains empty panes for additional data layers
    output$map <- leaflet::renderLeaflet(
      BaseMap()
    )
    
    # Reactively add management layers based on selection
    observe({
      lyr <- input$mng_layer
      
      leaflet::leafletProxy(ns("map")) %>%
        leaflet::clearGroup("MNG")
      
      # Create and execute plotting command based on the selected layer
      if (!is.null(lyr)) {
        cmd <- AddLayers(add_layers = lyr)
        eval(parse(text = cmd))
      }
    })
    
    # Reactively add data layers based on selection
    observe({
      lyrs <- input$dat_layer
      
      leaflet::leafletProxy(ns("map")) %>%
        leaflet::clearGroup("DAT")
      
      # Get the plotting command for each selected layer and execute it
      if (length(lyrs) > 0) {
        sapply(
          lyrs,
          function(lyr){
            cmd <- AddLayers(add_layers = lyr)
            eval(parse(text = cmd))
          }
        )
      }
    })
    
    
  })
}
    
## To be copied in the UI
# mod_main_map_ui("main_map_1")
    
## To be copied in the server
# mod_main_map_server("main_map_1")
