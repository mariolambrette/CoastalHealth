#' db UI Function
#'
#' @description Module to handle the shiny app's connection to the SQLite database
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_db_ui <- function(id) {
  ns <- NS(id)
  tagList(
 
  )
}
   
 
#' db Server Functions
#'
#' @importFrom shiny showModal textInput actionButton observeEvent removeModal
#' @importFrom htmltools div tagList
#' @importFrom RSQLite dbIsValid
#' @importFrom shinyjs runjs
#'
#' @noRd 
mod_db_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Function to create the dialogue box for username input
    un_input_modal <- function(error_message = NULL){
      shiny::showModal(modalDialog(
        title = "Enter you UoE username",
        shiny::textInput(ns("un"), "Username", value = ""),
        if (!is.null(error_message)) htmltools::div(style = "color: red;", error_message),
        footer = htmltools::tagList(
          shiny::actionButton(ns("submit_un"), "Submit"),
          shiny::actionButton(ns("quitApp"), "Quit")
        )
      ))
    }
    
    # Show username dialogue box
    un_input_modal()
    
    # JavaScript to trigger submit button on Enter key
    shinyjs::runjs(sprintf('
      $(document).on("keypress", "#%s", function(e) {
        if(e.which == 13) {
          $("#%s").click();
        }
      });
    ', ns("un"), ns("submit_un")))

    # Observe the username submission
    shiny::observeEvent(input$submit_un, {
      
      # Check the user name is valid after user submits
      if (!validate_username(input$un)) {
        # Show an error and ask the user to try again
        un_input_modal(error_message = "Error: path to database not found. Check username and try again.")
      } else{
        
        # remove dialogue box if input is correct
        shiny::removeModal()
        
        # Create a database connection using the entered username
        atlas_env$con <- CreateConnection(input$un)
        
        if (RSQLite::dbIsValid(atlas_env$con)) {
          atlas_env$connection.ready(TRUE)
        } else{
          # Show an error and ask the user to try again
          un_input_modal(error_message = "Error: Unable to connect to database. Please try again.")
        }
      }
    })
    
    # Quit the app if needed
    shiny::observeEvent(input$quitApp, {
      QuitApp()
    })
  })
}
    
## To be copied in the UI
# mod_db_ui("db_1")
    
## To be copied in the server
# mod_db_server("db_1")
