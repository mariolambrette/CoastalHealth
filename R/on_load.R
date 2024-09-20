# .onLoad function and environment definition

.onLoad <- function(libname, pkgname){

}

# Create package environment with placeholders for required variables
atlas_env <- new.env(parent = emptyenv())
atlas_env$con <- NULL
atlas_env$connection.ready <- shiny::reactiveVal(FALSE)
