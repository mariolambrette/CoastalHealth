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
    
    # # Scrollable checkbox group for mncat selection
    # tags$div(
    #   style = "height: 400px; width: 300; overflow-y: scroll; border: 1px solid #ccc; padding: 10px;",
    #   shiny::checkboxGroupInput(
    #     ns("mncat_select"),
    #     label = "Select Management Catchments of interest",
    #     choices = unique(atlas_env$opcats_all$mncat_name)
    #   )
    # ),
    # 
    shinyTree::shinyTree(
      ns("area_tree"),
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
    
    # Confirm button
    shiny::actionButton(ns("confirm_button"), "Confirm Selection")
 
  )
}
    
#' area Server Functions
#' 
#' @description
#' Server functions for selecting the management catchments of interest for
#' app usage. These areas will form the boundaries within which downstream
#' data sources are displayed. The function updates the atlas_env$opcats
#' variable, creating a dataframe with a mncat_id and mncat_name column.
#' These IDs and names can be used to filter external data sources.
#' 
#'
#' @noRd
#' 
#' @import shiny
#' @import magrittr
#' @importFrom dplyr filter
#' @importFrom shinycssloaders withSpinner

mod_area_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    shiny::observeEvent(atlas_env$areatrigger(), {
      if (!is.null(atlas_env$opcats_all)) {
        # Create tree structure of management catchments (remove TraC areas)
        output$area_tree <- shinyTree::renderTree({
          
          tree <- NULL
          tree <- shinyTree::dfToTree(atlas_env$opcats_all %>%
                                        dplyr::select(rbd_name, mncat_name) %>%
                                        dplyr::filter(!grepl("TraC", mncat_name)) %>%
                                        dplyr::arrange(rbd_name))
          tree <- assign_node_attrs(tree)
        })
      } else {
        message("Atlas environment incorrectly configured. Relaunch app and try again")
      }
    })
    
    # Update the opcats list when the confirm button is pressed
    shiny::observeEvent(input$confirm_button, {
  #    req(input$mncat_select) # Ensure some regions are selected
      
      # Show a modal dialog with a spinner
      shiny::showModal(
        shiny::modalDialog(
          title = "Processing Selection",
          h4("Please wait while we retrieve the data..."),
          div(
            style = "text-align: center; padding: 20px;",
            shinycssloaders::withSpinner(shiny::div(style = "height: 50px; width: 50px;"))
          ),
          footer = NULL,
          easyClose = FALSE
        )
      )
      
      mncats <- shinyTree::get_selected(input$area_tree, format = "names") %>%
        as.character()
      
      # List of selected opcats
      selected_opcats <- atlas_env$opcats_all %>%
        dplyr::filter(mncat_name %in% mncats)
      atlas_env$opcats(selected_opcats)

      # Get spatial data for selected opcats
      atlas_env$opcats_spatial(Get_opcats())

      # Retrieve water body data for the selected opcats
      Get_wbs()

      # Retrieve marine area
      Get_marinearea()

      # Remove the modal dialogue box
      shiny::removeModal()
    })
 
  })
}
    
## To be copied in the UI
# mod_area_ui("area_1")
    
## To be copied in the server
# mod_area_server("area_1")
