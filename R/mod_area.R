#' area UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList checkboxGroupInput
mod_area_ui <- function(id) {
  ns <- NS(id)
  tagList(
    
    # Scrollable checkbox group for mncat selection
    tags$div(
      style = "height: 200px; overflow-y: scroll; border: 1px solid #ccc; padding: 10px;",
      shiny::checkboxGroupInput(
        ns("mncat_select"),
        label = "Select Management Catchments of interest",
        choices = NULL
      )
    ),
    
    # Confirm button
    shiny::actionButton(ns("confirm_button"), "Confirm Selection")
 
  )
}
    
#' area Server Functions
#' 
#' @description
#' Server functions for selecting the management catchments of interest for
#' app usage. These areas will form the boundaries within which downstream
#' data sources are displayed. Te function updates the atlas_env$opcats
#' variable, creating a dataframe with a mncat_id and mncat_name column.
#' These IDs and names can be used to filter external data sources.
#' 
#'
#' @noRd 
mod_area_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    shiny::observe({
      if (!is.null(atlas_env$opcats_all)) {
        shiny::updateCheckboxGroupInput(
          session,
          "mncat_select",
          choices = unique(atlas_env$opcats_all$mncat_name)
        )
      }
    })
    
    # Update the opcats list when the confirm button is pressed
    shiny::observeEvent(input$confirm_button, {
      req(input$mncat_select) # Ensure some regions are selected
      
      selected_opcats <- atlas_env$opcats_all %>%
        dplyr::filter(mncat_name %in% input$mncat_select)
      
      atlas_env$opcats(selected_opcats)
    })
 
  })
}
    
## To be copied in the UI
# mod_area_ui("area_1")
    
## To be copied in the server
# mod_area_server("area_1")
