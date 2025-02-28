#' wbview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList  checkboxInput

mod_wbview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::checkboxInput(ns("rivers"), "Rivers", value = FALSE),
    shiny::checkboxInput(ns("lakes"), "Lakes", value = FALSE),
    shiny::checkboxInput(ns("outlines"), "Waterbody boundaries", value = FALSE),
    shiny::checkboxInput(ns("trac"), "Transitional and coastal operational catchments (EA)", value = FALSE),
    shiny::checkboxInput(ns("ices"), "ICES rectangles", value = FALSE)
  )
}
    
#' wbview Server Functions
#'
#' @noRd 
#' 
#' @importFrom shiny observe updateCheckboxInput observe

mod_wbview_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Initialize checkboxes with the current state of atlas_env$wb_triggers
    shiny::observe({
      shiny::updateCheckboxInput(session, "rivers", value = atlas_env$wb_triggers$rivers)
      shiny::updateCheckboxInput(session, "lakes", value = atlas_env$wb_triggers$lakes)
      shiny::updateCheckboxInput(session, "outlines", value = atlas_env$wb_triggers$outlines)
      shiny::updateCheckboxInput(session, "trac", value = atlas_env$wb_triggers$trac)
      shiny::updateCheckboxInput(session, "ices", value = atlas_env$wb_triggers$ices)
    })
    
    # Update the values of the waterbody view triggers based on the user input
    shiny::observe({
      atlas_env$wb_triggers$rivers <- input$rivers
    })
    shiny::observe({
      atlas_env$wb_triggers$lakes <- input$lakes
    })
    shiny::observe({
      atlas_env$wb_triggers$outlines <- input$outlines
    })
    shiny::observe({
      atlas_env$wb_triggers$trac <- input$trac
    })
    shiny::observe({
      atlas_env$wb_triggers$ices <- input$ices
    })
    
  })
}
    
## To be copied in the UI
# mod_wbview_ui("wbview_1")
    
## To be copied in the server
# mod_wbview_server("wbview_1")
