#' layerpopup UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList HTML tags

mod_layerpopup_ui <- function(id) {
  ns <- NS(id)
  tagList(
    
    # CSS for modal rendering
    tags$style(shiny::HTML("
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
#' @importFrom plyr llply
#' @importFrom reactable renderReactable reactableOutput
#' @importFrom shiny moduleServer observeEvent showModal modalDialog div tagList modalButton tags
#' @importFrom htmltools p
#' @importFrom sf read_sf

mod_layerpopup_server <- function(id){
  shiny::moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    shiny::observeEvent(atlas_env$popuptrigger(), {
      
      # Filter layers to those selected and create output table
      layers <- data.table::fread(system.file("extdata", "layer_urls.csv", package = "CoastalHealth")) %>%
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
              class = "btn neut-btn btn-allsf",
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
      
      

      
      # Code to download layer table
      shiny::observeEvent(input$download_table, {
        print("clicked download table")
      })
      
      # Code to download individual sf
      shiny::observeEvent(input$load_layer_sf, {
        
        # input$load_layer_sf is a list of two elements, 'ts' (the timestamp in
        # unix time, used as a unique id) and 'url', a list of urls to load
        # with sf. It may be a list of length 1 or more than 1
        
        cat(paste0("loading layer ", input$load_layer_sf$id[[1]]))
        
        # Check if there is more than one url
        if (length(input$load_layer_sf$url) > 1) {
          
          # If there is more than one url, load each one, combine them and assign
          # the result ot the global environment
          assign(
            x     = input$load_layer_sf$id[[1]], 
            value = plyr::llply(
              input$load_layer_sf$url,
              sf::read_sf
            ) %>%
              dplyr::bind_rows(), 
            envir = .GlobalEnv
          )
          
        } else {
          load_sf(
            url = input$load_layer_sf$url[[1]],
            id  = input$load_layer_sf$id[[1]]
          )
        }
        
      })
      
      # Code to load all layers as sf objects
      shiny::observeEvent(input$all_sf_load, {
        
        cat("Loading all layers with sf...")
        
        ids <- names(atlas_env$selected_urls_sf)
        
        for (i in seq_along(ids)) {
          
          if (length(atlas_env$selected_urls_sf[[i]]) > 1) {
            assign(
              x = ids[[i]],
              value = plyr::llply(
                atlas_env$selected_urls_sf[[i]],
                sf::read_sf
              ) %>%
                dplyr::bind_rows(),
              envir = .GlobalEnv
            )
          } else {
            assign(
              x = ids[[i]],
              value = sf::read_sf(atlas_env$selected_urls_sf[[i]]),
              envir = .GlobalEnv
            )
          }
        }
        
        cat("All layers loaded with sf.")
        
      })
      
      # Code to download all layers to computer
      shiny::observeEvent(input$all_download, {
        cat("Downloading all layers via browser..")
        openURLs(atlas_env$selected_urls_browser)
      })
      
    })
 
  })
}
    
## To be copied in the UI
# mod_layerpopup_ui("layerpopup_1")
    
## To be copied in the server
# mod_layerpopup_server("layerpopup_1")
