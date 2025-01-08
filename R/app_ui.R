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
      title = "Coastal Health Data Explorer",
      fillable = TRUE,

      sidebar = shiny::uiOutput("dynamic_sidebar"),

      shiny::mainPanel(
        # MAIN MAP UI
        mod_map_ui("map_1"),
        width = 12,
        fillable = TRUE
      )
    ),
    
    # Custom CSS for a wider sidebar
    shiny::tags$style(HTML("
      .bslib-page-sidebar .sidebar {
        width: 350px !important; /* Set your desired width */
      }
    ")),

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
      .area-btn {
        position: fixed;
        bottom: 20px;
        right: 110px;
        width: 100px;
        z-index: 1000;
        background-color: #5f9c5f;
        color: white;
        border-color: #5f9c5f;
      }
      area-btn:hover {
        background-color: #84ad84;
        border-color: #84ad84;
      }
      .recentre-btn {
        position: fixed;
        bottom: 20px;
        right: 220px;
        width: 100px;
        z-index: 1000;
        background-color: #459da1;
        color: white;
        border-color: #459da1;
      }
      recentre-btn:hover {
        background-colour: #708b8c;
        border-color: #708b8c;
      }
    ")),

    # Quit button itself
    shiny::actionButton(
      "quitApp",
      "Quit",
      class = "btn btn-danger quit-btn"
    ),
    
    shiny::actionButton(
      "AreaSelect",
      "Select Area",
      class = "btn btn-success area-btn"
    ),
    
    shiny::actionButton(
      "Recentre",
      "Recentre Map",
      class = "btn btn-success recentre-btn"
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
