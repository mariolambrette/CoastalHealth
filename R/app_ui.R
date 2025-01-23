#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib shinyWidgets
#' @export
#' @noRd
app_ui2 <- function(request) {
   shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    shiny::includeCSS(system.file("app/www/download_buttons.css", package = "ExeAtlas")),

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

    # Quit button
    shiny::actionButton(
      "quitApp",
      "Quit",
      class = "btn btn-danger quit-btn app-quit-btn"
    ),
    
    # Area selection button
    shiny::actionButton(
      "AreaSelect",
      "Select Area",
      class = "btn btn-success green-btn area-btn"
    ),
    
    # Map recentre button
    shiny::actionButton(
      "Recentre",
      "Recentre Map",
      class = "btn btn-success neut-btn recentre-btn"
    )
   )
}



#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib shinyWidgets shinydashboard
#' @export
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    shiny::includeCSS(system.file("app/www/download_buttons.css", package = "ExeAtlas")),
    
    shinydashboard::dashboardPage(
      shinydashboard::dashboardHeader(
         title = "Coastal Health Data Explorer",
         titleWidth = 350
      ),
      shinydashboard::dashboardSidebar(
        shiny::uiOutput("dynamic_sidebar"),
        width = 350
      ),
      shinydashboard::dashboardBody(
        # shinydashboard::tabItems(
          # shinydashboard::tabItem(
            # shiny::fluidRow(
             # shinydashboard::box(
                div(
                  class = "map-container",
                  mod_map_ui("map_1")
                ),
             #   width = 12,
             #   style = "padding: 0; margin: 0; border: none;" # Remove extra padding/margin from box
             # )
            # )
          # )
        # )
      )
    ),
    
    # Quit button
    shiny::actionButton(
      "quitApp",
      "Quit",
      class = "btn btn-danger quit-btn app-quit-btn"
    ),
    
    # Area selection button
    shiny::actionButton(
      "AreaSelect",
      "Select Area",
      class = "btn btn-success green-btn area-btn"
    ),
    
    # Map recentre button
    shiny::actionButton(
      "Recentre",
      "Recentre Map",
      class = "btn btn-success neut-btn recentre-btn"
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
    ),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css"),
    shiny::includeScript(system.file("app/www/sidebar_resize.js", package = "ExeAtlas"))
    # Add here other external resources
  )
}
