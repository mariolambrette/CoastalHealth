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
#' @noRd 
mod_db_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Function to create the dialogue box for username input
    un_input_modal <- function(error_message = NULL){
      showModal(modalDialog(
        title = "Enter you UoE username",
        textInput(ns("un"), "Username", value = ""),
        if(!is.null(error_message)) div(style = "color: red;", error_message),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("submit_un"), "Submit")
        )
      ))
    }
    
    # Show username dialogue box
    un_input_modal()

    # Observe the username submission
    observeEvent(input$submit_un, {
      
      # Check the user name is valid after user submits
      if(!validate_username(input$un)){
        # Show an error and ask the user to try again
        show_username_modal(error_message = "Error: path to database not found. Check username and try again.")
      } else{
        
        # remove dialogue box if input is correct
        removeModal()
        
        # Create a database connection using the entered username
        atlas_env$con <- CreateConnection(input$un)
        
        if(RSQLite::dbIsValid(atlas_env$con)){
          atlas_env$connection.ready(TRUE)
        } else{
          # Show an error and ask the user to try again
          show_username_modal(error_message = "Error: Unable to connect to database. Please try again.")
        }
      }
    })
  })
}
    
## To be copied in the UI
# mod_db_ui("db_1")
    
## To be copied in the server
# mod_db_server("db_1")
