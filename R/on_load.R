# .onLoad function and environment definition

.onLoad <- function(libname, pkgname){
  
  opcats_path <- system.file(
    "extdata", 
    "OperationalCatchments.csv",
    package = pkgname
  ) 
  
  if (file.exists(opcats_path)) {
    atlas_env$opcats_all <- data.table::fread(opcats_path)
  }
  
}

# Create package environment with placeholders for required variables
atlas_env <- new.env(parent = emptyenv())

# Polygon of UK land
atlas_env$land <- sf::st_read(
  system.file("extdata", "land_polygons.gpkg", package = "ExeAtlas"),
  quiet = TRUE
)

# Dataframe of names and IDs for all management catchments in England
atlas_env$opcats_all <- NULL

# Selected operational catchments
atlas_env$opcats <- shiny::reactiveVal(NULL)

# Spatial data for selected operational catchments
atlas_env$opcats_spatial <- shiny::reactiveVal(NULL)

# Placeholder for map bounds
atlas_env$bounds <- NULL

# Trigger for recentring map
atlas_env$recentre_trigger <- shiny::reactiveVal(NULL)

# Water body data (rivers, alkes and subcatchments)
atlas_env$wbs_spatial <- shiny::reactiveVal(NULL)

# State of water body layers - i.e. to display them or not. Also includes marine area
atlas_env$wb_triggers <- shiny::reactiveValues(
  rivers = FALSE,
  lakes = FALSE,
  outlines = FALSE,
  marine = FALSE
)

# Placeholder for marine area sf object calculated by Get_marinearea() when
# opcats are selected by the user
atlas_env$marinearea <- NULL
