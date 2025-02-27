#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd

app_server <- function(input, output, session) {
  
  # Add session end handler for browser window close
  session$onSessionEnded(function() {
    isolate({
      QuitApp()
    })
  })
  
  # UI for Sidebar with Fixed buttons along the top
  output$dynamic_sidebar <- shiny::renderUI({
    # Create the buttons div that will always be present
    buttons_div <- div(
      style = "display: flex; justify-content: space-between; padding: 10px;",
      
      # Area selection button
      shiny::actionButton(
        "AreaSelect",
        "Select Area",
        class = "btn btn-success green-btn sidebar-btn"
      ),
      
      # Map recentre button
      shiny::actionButton(
        "Recentre",
        "Recentre Map",
        class = "btn btn-success neut-btn sidebar-btn"
      ),
      
      # Quit button
      shiny::actionButton(
        "quitApp",
        "Quit",
        class = "btn btn-danger quit-btn sidebar-btn"
      )
    )
    
    # Create the dynamic content section
    dynamic_content <- if (!is.null(atlas_env$opcats_spatial())) {
      div(
        style = "flex-grow: 1; overflow-y: auto; padding: 10px;",
        shiny::tabsetPanel(
          id = "sidebar",
          shiny::tabPanel("Toggle Waterbody View", mod_wbview_ui("wbview_1")),
          shiny::tabPanel("Select Data Layers", mod_layerselect_ui("layerselect_1"))
        )
      )
    } else {
      # Empty div when no selection
      div(style = "flex-grow: 1;")
    }
    
    # Return the combined layout
    shiny::tagList(
      div(
        style = "display: flex; flex-direction: column; height: 100%;", 
        buttons_div,
        dynamic_content
      )
    )
  })
  
  # Module servers
  mod_map_server("map_1")
  mod_area_server("area_1")
  mod_wbview_server("wbview_1")
  mod_layerselect_server("layerselect_1")
  mod_layerpopup_server("layerpopup_1")
  
  # Call the area selection module when the area-btn is pressed
  shiny::observeEvent(input$AreaSelect, {
   
    atlas_env$areatrigger(Sys.time())
    
    shiny::showModal(
      shiny::modalDialog(
        title = "Select management catchments of interest",
        size = "xl",
        easyClose = TRUE,
        footer = NULL,
        mod_area_ui("area_1")
      )
    )
  })
  
  # Quit the app when the quit button is pressed
  shiny::observeEvent(input$quitApp, {
    stopApp()
  })
  
  # Recentre the map when the recentre button is pressed
  shiny::observeEvent(input$Recentre, {
    atlas_env$recentre_trigger(Sys.time())
  })

}
