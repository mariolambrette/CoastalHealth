#' Data_select UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList uiOutput
#' @importFrom htmltools div HTML
mod_Data_select_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(htmltools::HTML("
      .picker-container .dropdown-menu {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
      }
    ")),
    htmltools::div(
      class = "mng-select",
      style = "margin-top: 24px; text-align: left; padding-left: 20px;",
      shiny::uiOutput(ns("mng_select"))
    ),
    htmltools::div(
      class = "point-select",
      style = "margin-top: 24px; text-align: left; padding-left: 20px;",
      shiny::uiOutput(ns("lc_select"))
    ),
    htmltools::div(
      class = "lc-select",
      style = "margin-top: 24px; text-align: left; padding-left: 20px;",
      shiny::uiOutput(ns("point_select"))
    )
  )
}
    
#' Data_select Server Functions
#'
#' @noRd 
#' 
#' @importFrom dplyr tbl sql collect
#' @importFrom shiny req renderUI
#' @importFrom shinyWidgets pickerInput
#' @importFrom magrittr `%>%`
mod_Data_select_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Ensure database connection is available
    shiny::req(atlas_env$connection.ready())
    
    # Read in layer index file to provide dropdown menu of plotting options
    SHP_index <- dplyr::tbl(atlas_env$con, "SHP_lookup") %>%
      dplyr::filter(!(dplyr::sql('SUBSTR(SHP_name, INSTR(SHP_name, "SPA"), 3) COLLATE BINARY = "SPA"'))) %>%
      dplyr::collect()
    
    # Extract list of layers for the user to choose from
    layers <- SHP_index$SHP_name %>%
      as.list()
    layers <- c("No selection", layers) # Add a null option to show no additional layers
    names(layers) <- c("No selection", SHP_index$disp_name)
    
    # Management layer selection UI
    output$mng_select <- shiny::renderUI({
      shiny::selectizeInput(
        inputId = ns("mng_layer"),
        label = "Select management area(s):",
        choices = layers[grepl("MNG", layers)],
        options = list(
          placeholder = "No selection",
          plugins = list('remove_button', 'dropdown_header'), # Allows removing items and search
          hideSelected = FALSE, # Keeps selected items in the dropdown
          searchField = 'text'   # Enables live search within options
        ),
        multiple = TRUE
      )
    })
    
    # Land cover layer selection UI
    output$lc_select <- shiny::renderUI({
      shiny::selectizeInput(
        inputId = ns("lc_layer"),
        label = "Select land cover layer:",
        choices = layers[grepl("LC|selection", layers)],
        options = list(
          placeholder = "No selection",
          plugins = list('remove_button', 'dropdown_header'), # Allows removing items and search
          hideSelected = FALSE, # Keeps selected items in the dropdown
          searchField = 'text'   # Enables live search within options
        ),
        multiple = FALSE
      )
    })
    
    # Point data layer selection
    output$point_select <- shiny::renderUI({
      shiny::selectizeInput(
        inputId = ns("point_layer"),
        label = "Select point data layer(s):",
        choices = layers[grepl("POINT", layers)],
        options = list(
          placeholder = "No selection",
          plugins = list('remove_button', 'dropdown_header'), # Allows removing items and search
          hideSelected = FALSE, # Keeps selected items in the dropdown
          searchField = 'text'   # Enables live search within options
        ),
        multiple = TRUE
      )
    })
    
    # Reactively adjust environment selected layer values
    shiny::observe({
      mng_layers <- input$mng_layer
      atlas_env$DisplayLayers$mng <- mng_layers
    })
    shiny::observe({
      lc_layers <- input$lc_layer
      atlas_env$DisplayLayers$lc <- lc_layers
    })
    shiny::observe({
      point_layers <- input$point_layer
      atlas_env$DisplayLayers$point <- point_layers
    })
  })
}
    
## To be copied in the UI
# mod_Data_select_ui("Data_select_1")
    
## To be copied in the server
# mod_Data_select_server("Data_select_1")
