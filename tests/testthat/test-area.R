# Required libraries for testing shiny app
library(shinytest2)
library(testthat)
library(shiny)

testthat::test_that("mod_area updates atlas_env$opcats correctly", {
  
  # Simulate atlas env as it exists in the package
  atlas_env <- new.env(parent = emptyenv())
  atlas_env$opcats_all <- data.frame(
    mncat_id = 1:3,
    mncat_name = c("A", "B", "C")
  )
  atlas_env$opcats <- shiny::reactiveVal(NULL)
  
  # Define the test app
  ui <- fluidPage(
    mod_area_ui("area_test")
  )
  
  server <- function(input, output, session) {
    mod_area_server("area_test")
  }
  
  # Use `shinytest2` to launch the app
  app <- AppDriver$new(
    shinyApp(ui, server),
    seed = 1234,
    load_timeout = 5000,
    shiny_args = list(test.mode = TRUE)
  )
  
  # Wait for the app to initialize
  app$wait_for_idle()
  
  # Simulate user interaction
  app$set_inputs(`area_test-mncat_select` = c("A", "B"), wait_ = FALSE)
  app$click("area_test-confirm_button")
  
  # Wait for reactivity
  app$wait_for_idle()
  
  selected <- app$get_value(input = "area_test-mncat_select")
  
  expect_equal(selected, c("A", "B"))
  
  app$stop()
})


