#' Point_view UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS
#' @import htmltools
mod_Point_view_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    shiny::uiOutput(ns("point_ui"))
  )
}
    
#' Point_view Server Functions
#'
#' @noRd 
mod_Point_view_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    output$point_ui <- shiny::renderUI({
      if (is.null(atlas_env$DisplayLayers$point) || length(atlas_env$DisplayLayers$point) == 0) {
        # Display warning message in red
        tags$div(style = "color: red;", "Select a point data layer to view")
      } else {
        # Fetch the table name from the DisplayLayers
        table_name <- atlas_env$DisplayLayers$point[[1]]
        
        # Define the date range with error handling for empty tables
        date_data <- dplyr::tbl(atlas_env$con, table_name) %>%
          dplyr::select(DATE) %>%
          dplyr::collect() %>%
          dplyr::mutate(DATE = as.Date(DATE))  # Ensure DATE is in Date format
        
        # Calculate min and max dates
        start_date <- date_data %>%
          dplyr::summarise(min_date = min(DATE, na.rm = TRUE)) %>%
          dplyr::pull(min_date)
        
        end_date <- date_data %>%
          dplyr::summarise(max_date = max(DATE, na.rm = TRUE)) %>%
          dplyr::pull(max_date)
        
        # Use current date as fallback if no dates found
        start_date <- ifelse(is.na(start_date), Sys.Date(), start_date)
        end_date <- ifelse(is.na(end_date), Sys.Date(), end_date)
        
        tagList(
          shiny::dateInput(ns("start_date"), "Earliest Date", value = start_date),
          shiny::dateInput(ns("end_date"), "Last Date", value = end_date),
          shiny::selectizeInput(
            inputId = ns("category"),
            "Select categories/species", 
            choices = dplyr::tbl(atlas_env$con, table_name) %>%
              dplyr::select(CAT) %>%
              dplyr::distinct() %>%  # Ensure unique categories
              dplyr::pull(CAT),
            options = list(
              placeholder = "No selection",
              plugins = list('remove_button', 'dropdown_header'), # Allows removing items and search
              hideSelected = FALSE, # Keeps selected items in the dropdown
              searchField = 'text'   # Enables live search within options
            ),
            multiple = TRUE
          ),
        )
      }
    })
    
    shiny::observe({
      
      atlas_env$PointState$Time[[1]] <- input$start_date
      atlas_env$PointState$Time[[2]] <- input$end_date
      atlas_env$PointState$Cat       <- input$category
      
    })
 
  })
}
    
## To be copied in the UI
# mod_Point_view_ui("Point_view_1")
    
## To be copied in the server
# mod_Point_view_server("Point_view_1")
