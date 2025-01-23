# .onLoad function and environment definition

.onLoad <- function(libname, pkgname){
  
  opcats_path <- system.file(
    "extdata", 
    "OperationalCatchments.csv",
    package = pkgname
  ) 
  
  if (file.exists(opcats_path)) {
    atlas_env$opcats_all <- read.csv(opcats_path)
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

# Placeholder for map bounds, and area centre and radius
atlas_env$bounds <- NULL
atlas_env$opcats_centre <- NULL
atlas_env$opcats_radius <- NULL

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

# Placehodler for user selected date range
atlas_env$date_range <- NULL

# Placeholder for selected layers
atlas_env$selected_layers <- NULL

# List structure for layer selection element
atlas_env$layer_options <- yaml::read_yaml(system.file("extdata", "data_structure.yaml", package = "ExeAtlas")) %>%
  rapply(
    .,
    function(x) as.list(x),
    classes = "ANY",
    how = "replace"
  )

atlas_env$map_sidebar <- NULL

# Reactive trigger to display the layer selection popup
atlas_env$popuptrigger <- shiny::reactiveVal(NULL)
