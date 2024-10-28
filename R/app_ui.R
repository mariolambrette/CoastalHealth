#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib shinyWidgets
#' @export
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    # Main page set up
    bslib::page_sidebar(
      theme = bslib::bs_theme(bootswatch = "minty"),
      title = "ExeAtlas Interactive Mapping Tool",
      fillable = T,
      
      sidebar =  shiny::tagList(
        shiny::tabsetPanel(
          id = "sidebar",
          shiny::tabPanel("1. Select data", mod_Data_select_ui("DataSelect1")),
          shiny::tabPanel("2. Modify points view", mod_Point_view_ui("Point_view_1")),
          shiny::tabPanel("3. Modify land cover view", "LAND COVER VIEW UI")
          # Add more tabPanels here if needed
        )
      ),
      
      shiny::mainPanel(
        # MAIN MAP UI
        mod_Map_ui("MainMap"),
        width = 12
      )
    ),
    
    # Add the quit button with custom styling
    shiny::tags$style(HTML("
      .quit-btn {
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 80px;
        z-index: 1000;        
        background-color: #FF0000; 
        color: white;
        border-color: #FF0000;
      }
      .quit-btn:hover {
        background-color: #cc0000;
        border-color: #cc0000;
      }
    ")),
    
    # Quit button itself
    actionButton(
      "quitApp", 
      "Quit", 
      class = "btn btn-danger quit-btn"
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "ExeAtlas"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
