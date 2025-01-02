library(shiny)
library(dplyr)

source("R/mod_area.R")

# Simulate your package environment and data
atlas_env <- new.env(parent = emptyenv())
atlas_env$opcats_all <- data.frame(
  mncat_id = 1:10,
  mncat_name = paste("Catchment", 1:10)
)
atlas_env$opcats <- shiny::reactiveVal(NULL)

# The test app
ui <- fluidPage(
  mod_area_ui("area_test")
)

server <- function(input, output, session) {
  # Load the module
  mod_area_server("area_test")
  
  # Observe the confirm button and print filtered opcats
  observeEvent(atlas_env$opcats(), {
    req(atlas_env$opcats()) # Ensure `atlas_env$opcats` is not NULL
    
    # Print to console
    print(atlas_env$opcats())
    
    # Display in app
    output$console_output <- renderPrint({
      atlas_env$opcats()
    })
  })
}

shinyApp(ui, server)

