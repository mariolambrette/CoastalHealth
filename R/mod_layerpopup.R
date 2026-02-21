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
      
      
      if (nrow(layers) > 0) {
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
              
             shiny::downloadButton(
                outputId = ns("download_table"),
                label = "Download layer table",
                class = "btn neut-btn btn-allsf",
                icon = NULL
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
                "Close table",
                onclick = "$('.modal').modal('hide')" # Hides the modal
              ),

              shiny::tags$button(
                type = "button",
                class = "btn quit-btn",
                "Quit CoHDEx",
                onclick = "Shiny.setInputValue('quitApp', true, {priority: 'event'})"
              ),
              
              shiny::tags$script(HTML("
                Shiny.addCustomMessageHandler('triggerDownload', function(id) {
                  let link = document.createElement('a');
                  link.href = document.getElementById(id).href;
                  link.click();
                });
              "))
              
            ),
            
            # Modal content
            shiny::tagList(
              # Brief instructions
#              htmltools::p(
#                "The following layers were selected. You can use the links to 
#              navigate to the source webpage for each layer, or use the links to 
#              download the data directly. Additionally, you can use the blue 
#              download buttons to load the selected layer directly into your R
#              session as an sf object."
#              ),

              htmltools::p(
                style = "font-weight: bold;",
                "The following layers were selected."
              ),

              shiny::actionLink(ns("table_help"), "Show additional information..."),

              shiny::conditionalPanel(
                condition = sprintf("input['%s'] %% 2 === 1", ns("table_help")),
                style = "margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 6px; background: #f7f7f7;",
                htmltools::tags$ul(
                  htmltools::tags$li("You can use this table to navigate to the 
                  data sources, download the data to your machine, or load it 
                  directly into your R session with sf."),
                  htmltools::tags$li("Below is a description of each column:"),
                  htmltools::tags$ul(
                    htmltools::tags$li(htmltools::tags$strong("Layer name: "), "The name of the dataset."),
                    htmltools::tags$li(htmltools::tags$strong("Web link: "), "A clickable hyperlink to the source webpage for the dataset. This webpage will normally contain additional relevant information about the dataset."),
                    htmltools::tags$li(htmltools::tags$strong("Download link: "), "A clickable hyperlink that will download the dataset directly to your machine."),
                    htmltools::tags$li(htmltools::tags$strong("Download format: "), "The file format in which the dataset will be downloaded."),
                    htmltools::tags$li(htmltools::tags$strong("Load with sf: "), "Clicking this button loads the dataset directly into your R session with sf. The data will become available in your session once you close the app. (note that this may not work for all datasets, depending on the data source)")
                  ),
                  htmltools::tags$li("There all also some global action buttons provided:"),
                  htmltools::tags$ul(
                    htmltools::tags$li(htmltools::tags$strong("Download layer table: "), "Downloads the table of selected layers as a .csv file containing the relevant links to web pages."),
                    htmltools::tags$li(htmltools::tags$strong("Download all layers to computer: "), "Downloads all selected layers to your machine via the browser. (note that this may not work for all datasets, depending on the data source)"),
                    htmltools::tags$li(htmltools::tags$strong("Load all with sf: "), "Loads all selected layers directly into your R session with sf. The data will become available in your session once you close the app. (note that this may not work for all datasets, depending on the data source)"),
                    htmltools::tags$li(htmltools::tags$strong("Close: "), "Closes this popup box.")
                  )
                )
              ),

              shiny::tags$script(HTML(sprintf(
                "$(document).on('shiny:inputchanged', function(event) {
                   if (event.name === '%s') {
                     var val = event.value || 0;
                     var label = (val %% 2 === 1) ? 'Hide additional information...' : 'Show additional information...';
                     $('#%s').text(label);
                   }
                 });",
                ns("table_help"), ns("table_help")
              ))),

              htmltools::p(
                style = "font-style: italic; font-weight: bold;",
                "\n\nNote that data loaded into your R session will only become 
              available once you close the app."
              ),
              
              # Render the table
              shiny::div(
                reactable::reactableOutput(ns("table"))
              )
            )
          )
        )
      } else {
        # Show warning modal when no layers are selected
        shiny::showModal(
          shiny::modalDialog(
            title = "No layers selected",
            size = "m",  # Medium modal
            easyClose = TRUE,
            footer = shiny::tags$button(
              type = "button",
              class = "btn quit-btn",
              "Close",
              onclick = "$('.modal').modal('hide')"
            ),
            
            # Warning message content
            shiny::div(
              style = "text-align: center; padding: 20px;",
              shiny::tags$i(class = "fa fa-exclamation-triangle", style = "font-size: 48px; color: #f39c12; margin-bottom: 15px;"),
              htmltools::p(
                style = "font-size: 18px; margin-top: 15px;",
                "You have not selected any valid layers."
              ),
              htmltools::p(
                "Please go back and select at least one layer."
              )
            )
          )
        )
      }
      
      # Code to download layer table
      output$download_table <- downloadHandler(
        filename = function() {
          paste0("selected_layers_", Sys.Date(), ".csv")
        },
        content = function(file) {
          write.csv(download_tab(layers), file, row.names = FALSE)
        }
      )

      # Code to download individual sf
      shiny::observeEvent(input$load_layer_sf, {
        
        # input$load_layer_sf is a list of two elements, 'ts' (the timestamp in
        # unix time, used as a unique id) and 'url', a list of urls to load
        # with sf. It may be a list of length 1 or more than 1
        
        cat(paste0("loading layer ", input$load_layer_sf$id[[1]]))
        
        # Check if there is more than one url
        if (length(input$load_layer_sf$url) > 1) {
          
          # If there is more than one url, load each one, combine them and assign
          # the result to the global environment
          assign(
            x = input$load_layer_sf$id[[1]], 
            value = plyr::llply(
              input$load_layer_sf$url,
              sf::read_sf
            ) %>%
              dplyr::bind_rows() %>%
              sf::st_crop(., sf::st_as_sfc(atlas_env$bounds)), 
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
