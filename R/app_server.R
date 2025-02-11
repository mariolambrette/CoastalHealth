#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @export
#' @noRd

app_server <- function(input, output, session) {
  
  # UI for Sidebar with Fixed Bottom Container
  output$dynamic_sidebar <- shiny::renderUI({
    if (!is.null(atlas_env$opcats_spatial())) {
      shiny::tagList(
        div(
          style = "display: flex; flex-direction: column; height: 100%;", 
          
          # Scrollable Content Section (Takes remaining space)
          div(
            style = "flex-grow: 1; overflow-y: auto; padding: 10px;",
            shiny::tabsetPanel(
              id = "sidebar",
              shiny::tabPanel("Toggle Waterbody View", mod_wbview_ui("wbview_1")),
              shiny::tabPanel("Select Data Layers", mod_layerselect_ui("layerselect_1"))
            )
          ),
          
          # Fixed Bottom Container (100px height)
          div(
            style = "height: 1px; background: transparent;"
          )
        )
      )
    } else {
      NULL
    }
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
  
  shiny::observeEvent(input$Recentre, {
    atlas_env$recentre_trigger(Sys.time())
  })

}
