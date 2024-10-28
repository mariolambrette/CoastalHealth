# .onLoad function and environment definition

.onLoad <- function(libname, pkgname){

}

# Create package environment with placeholders for required variables
atlas_env <- new.env(parent = emptyenv())
atlas_env$con <- NULL
atlas_env$connection.ready <- shiny::reactiveVal(FALSE)
atlas_env$polyID <- NULL
atlas_env$DisplayLayers <- shiny::reactiveValues(
  mng   = NULL,
  lc    = NULL,
  point = NULL
)
atlas_env$PointState <- shiny::reactiveValues(
  Time = NULL, # Becomes two element list - [[1]] min date, [[2]] max date
  Cat  = NULL  # List of selected categorical value (e.g. species of interest)
)
atlas_env$RefreshPointsTrigger <- shiny::reactiveVal(0)