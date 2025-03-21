#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny shinydashboard
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    # Add window close handler
    tags$script(HTML("
      window.onbeforeunload = function() {
        Shiny.onbeforeUnload(function() {
          return null;
        });
      };           
    ")),
    
    shinydashboard::dashboardPage(
      shinydashboard::dashboardHeader(
         title = "Coastal Health Data Explorer",
         titleWidth = 350
      ),
      shinydashboard::dashboardSidebar(
        div(
          shiny::uiOutput("dynamic_sidebar"),
          class = "sidebar-container"
        ),
        width = 350
      ),
      shinydashboard::dashboardBody(
        # Leaflet map container
        div(
          class = "map-container",
          mod_map_ui("map_1")
        )
      )
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
    favicon(
      ico = "logo",
      rel = "shortcut icon",
      resources_path = "www",
      ext = "svg"
    ),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "CoastalHealth"
    ),
    tags$script(
      src = "https://kit.fontawesome.com/b40f9f7bab.js",
      crossorigin = "anonymous"
    ),
    shiny::includeScript(system.file("app/www/sidebar_resize.js", package = "CoastalHealth")),
    shiny::includeCSS(system.file("app/www/download_buttons.css", package = "CoastalHealth"))
    # Add here other external resources
  )
}
