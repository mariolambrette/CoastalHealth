#' layerpopup UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList HTML
mod_layerpopup_ui <- function(id) {
  ns <- NS(id)
  tagList(
    
    # CSS for modal rendering
    shiny::tags$style(shiny::HTML("
      .modal-dialog {
        width: 50% !important; /* Set modal width */
        height: 75% !important; /* Set modal height */
        margin: auto; /* Center horizontally */
      }
      .modal-content {
        height: 75vh; /* Set modal height relative to viewport */
        overflow-y: auto; /* Enable scrolling */
      }
    "))
    
  )
}
    
#' layerpopup Server Functions
#'
#' @noRd 
#' 
#' @importFrom data.table fread
#' @importFrom dplyr filter
#' @importFrom reactable renderReactable reactableOutput
#' @importFrom shiny moduleServer observeEvent showModal modalDialog div tagList modalButton
#' @importFrom htmltools p

mod_layerpopup_server <- function(id){
  shiny::moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    shiny::observeEvent(atlas_env$popuptrigger(), {
      
      # Filter layers to those selected and create output table
      layers <- data.table::fread(system.file("extdata", "layer_urls.csv", package = "ExeAtlas")) %>%
        dplyr::filter(name %in% atlas_env$selected_layers)
      
      output$table <- reactable::renderReactable({
        createtable(layers, ns = ns)
      })
      
      # Define and show the modal dialog
      shiny::showModal(
        shiny::modalDialog(
          title = "Selected layers",
          size = "l",  # Large modal
          easyClose = TRUE,  # Allow closing with Esc or clicking outside
          footer = shiny::div(
            class = "layerpopup-footer",
            
            shiny::tags$button(
              type = "button",
              class = "btn neut-btn",
              "Download layer table",
              onclick = paste0("Shiny.setInputValue('", ns("download_table"), "', Date.now(), {priority: 'event'})")
            ),
            
            shiny::tags$button(
              type = "button",
              class = "btn neut-btn",
              "Download all layers to computer",
              onclick = paste0("Shiny.setInputValue('", ns("all_download"), "', Date.now(), {priority: 'event'})")
            ),
            
            shiny::tags$button(
              type = "button",
              class = "btn neut-btn",
              "Load all with sf",
              onclick = paste0("Shiny.setInputValue('", ns("all_sf_load"), "', Date.now(), {priority: 'event'})")
            ),
            
            shiny::tags$button(
              type = "button",
              class = "btn quit-btn",
              "Close",
              onclick = "$('.modal').modal('hide')" # Hides the modal
            )
            
          ),
          
          # Modal content
          shiny::tagList(
            # Brief instructions
            htmltools::p(
              "The following layers were selected. You can use the links to 
              navigate to the source webpage for each layer, or use the links to 
              download the data directly. Additionally, you can use the blue 
              download buttons to load the selected layer directly into your R
              session as an sf object."
            ),
            # Render the table
            shiny::div(
              reactable::reactableOutput(ns("table"))
            )
          )
        )
      )
      
      # Code to load all layers as sf objects
      shiny::observeEvent(input$all_sf_load, {
        print("clicked all sf")
      })
      
      # Code to download all layers to computer
      shiny::observeEvent(input$all_download, {
        print("clicked download all")
      })
      
      # Code to download layer table
      shiny::observeEvent(input$download_table, {
        print("clicked download table")
      })
      
      # Code to download individual sf
      shiny::observeEvent(input$load_layer_sf, {
        print("clicked load sf")
      })
    })
 
  })
}
    
## To be copied in the UI
# mod_layerpopup_ui("layerpopup_1")
    
## To be copied in the server
# mod_layerpopup_server("layerpopup_1")
