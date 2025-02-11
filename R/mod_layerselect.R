#' layerselect UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @importFrom shinyTree shinyTree
mod_layerselect_ui <- function(id) {
  ns <- NS(id)
  tagList(
    
    # Confirm button
    shiny::actionButton(
      ns("confirm_btn"),
      "Confirm Selection",
      class = "green-btn"
    ),
    
    shiny::dateRangeInput(
      ns("date_range"),
      label = "Select date range",
      start = "2014-01-01",
      end   = Sys.Date(),
      format = "yyyy-mm-dd",
      separator = " to ",
      width = "100%"
    ),
    
    # Selection tree with search option and checkboxes
    shinyTree::shinyTree(
      ns("layer_tree"),
      checkbox = TRUE,
      search = TRUE,
      types = "{
        'folder' : { 'icon' : 'fas fa-folder', 'valid_children' : ['file'] },
        'file' : { 'icon' : 'fas fa-file', 'valid_children' : [] },
        'none' : { 'icon' : 'fas fa-xmark', 'valid_children' : [] }
      }",
      theme = "proton",
      whole_node = FALSE
    ),

    tags$style(HTML(paste0("
      #", ns("layer_tree-search-input"), " {
        color: black !important;
        margin-left: 10px !important; /* Adjust the value to shift more or less */
      }
    
      #", ns("layer_tree-search-input"), "::placeholder {
        color: black !important;
        opacity: 1 !important;
      }
      
        /* Change color of highlighted nodes in search */
      #", ns("layer_tree"), " .jstree-search {
        background-color: #acada8 !important; /* A blue highlight */
        color: white !important; /* Ensure text remains readable */
        font-weight: bold !important;
        border-radius: 3px !important;
        padding: 2px 5px !important;
      }
      
    ")))
  )
}

#' layerselect Server Functions
#'
#' @noRd 
#' 
#' @importFrom shinyTree renderTree get_selected set_node_attrs
mod_layerselect_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Render tree structure from atlas_env$layer_options
    output$layer_tree <- shinyTree::renderTree({
      tree <- atlas_env$layer_options
      tree <- assign_node_attrs(tree)
    })
    
    # Update selected layers reactive value when confirm button is pressed
    shiny::observeEvent(input$confirm_btn, {
      atlas_env$selected_layers <- shinyTree::get_selected(input$layer_tree, format = "names") %>%
        as.character()
      atlas_env$date_range <- input$date_range
      atlas_env$popuptrigger(Sys.time())
    })
    
  })
}

## To be copied in the UI
# mod_layerselect_ui("layerselect_1")

## To be copied in the server
# mod_layerselect_server("layerselect_1")
