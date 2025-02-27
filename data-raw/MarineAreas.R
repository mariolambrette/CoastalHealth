## Creating marine areas for each management catchment ##

## Marine areas are calculated as follows:
## 1. A 12nm buffer is calculated from the coast of the selected management 
##    catchment into the sea
## 2. ICES statistical subrectangles (https://gis.ices.dk/sf/index.html), 
##    download at https://gis.ices.dk/shapefiles/ICES_SubStatrec.zip, that
##    intersect with the marine buffer are selected.
## 3. Transitional and Coastal (TraC) operational catchments, designated by the
##    EA, that overlap with the marine buffer are selected.
##
## This provides two statutory regions of interest in the marine area that can
## be used to perform subsequent investigations. 


## 1. LOAD & PREPARE DATA ------------------------------------------------------

# Load libraries
library(sf)
library(dplyr)
library(data.table)

##  Helper functions
# An extension of sf::st_difference that erases all parts of x that overlap with y
st_erase <- function(x, y){
  sf::st_difference(x, sf::st_union(sf::st_combine(y)) %>%
                      st_make_valid(cropped_land))
}

# Read land shapefile
land <- sf::st_read(
  system.file(
    "extdata", 
    "land_polygons.gpkg", 
    package = "CoastalHealth"
  ),
  quiet = TRUE
)

# Read operational catchments and filter out TraC areas
opcats <- sf::st_read(
  system.file(
    "extdata", 
    "OperationalCatchmentsSpatial.gpkg", 
    package = "CoastalHealth"
  ),
  quiet = TRUE
) %>%
  dplyr::filter(!grepl("TraC", mncat_name)) %>%
  sf::st_transform(., crs = 27700)

# Read transitional and coastal opcats
tracs <- sf::st_read(
  system.file(
    "extdata", 
    "OperationalCatchmentsSpatial.gpkg", 
    package = "CoastalHealth"
  ),
  quiet = TRUE
) %>%
  dplyr::filter(grepl("TraC", mncat_name)) %>%
  sf::st_transform(., crs = 27700)

# Read ICES statistical subrectangles
ices <- read_sf("data-raw/ICES_rectangles/ICES_Statistical_Rectangles_Eco.shp") %>%
  st_transform(crs = 27700)

# Extract management catchment IDs
mncats <- unique(opcats$mncat_id) %>%
  as.character()

# 12nm eez boundary
eez <- sf::read_sf("data-raw/12nm_eez_mod.gpkg") %>%
  sf::st_transform(., crs = 27700)


## 2. CALCULATE MARINE BUFFERS -------------------------------------------------

# Function to create marine buffers for a given management catchment ID
create_marine_buffer <- function(m) {
  coast_buffer <- opcats %>%
    filter(mncat_id == m) %>%
    sf::st_simplify(preserveTopology = TRUE, dTolerance = 10) %>%
    sf::st_set_precision(1e5) %>%
    sf::st_union(., by_feature = FALSE) %>%
    sf::st_cast(., "MULTILINESTRING") %>%
    sf::st_buffer(., dist = 100) %>%
    sf::st_intersection(., land %>%
                          sf::st_set_precision(1e5) %>%
                          sf::st_cast(., "MULTILINESTRING"))
    
    
  marine_area <- sf::st_buffer(coast_buffer, dist = 22224) %>%
    sf::st_union() %>%
    st_erase(., land)
  
  return(list(coast_buffer, marine_area))
}

# Calculate marine buffers
marine_buffers <- plyr::llply(
  mncats,
  create_marine_buffer
)
names(marine_buffers) <- mncats


## 3. SELECT ICES AND TRAC AREAS -----------------------------------------------

ices_selection <- plyr::llply(
  marine_buffers,
  function(mb) {
    s <- st_filter(ices, mb[[2]]) %>%
      select(ICESNAME)
    
    if (nrow(s) == 0) {
      return(NULL)
    } else {
      return(s)
    }
  },
  .progress = "text"
) %>%
  rbindlist(idcol = "mncat_id") %>%
  st_as_sf(crs = 27700) %>%
  st_transform(crs = 4326)

trac_selection <- plyr::llply(
  marine_buffers,
  function(mb) {
    s <- st_filter(tracs, mb[[1]]) %>%
      select(opcat_id, opcat_name, mncat_id, mncat_name)
    
    if (nrow(s) == 0) {
      return(NULL)
    } else {
      return(s)
    }
  },
  .progress = "text"
) %>%
  rbindlist(idcol = "parent_mncat_id") %>%
  st_as_sf(crs = 27700) %>%
  st_transform(crs = 4326)



## 4. SAVE DATA TO COASTALHEATH PACKAGE ----------------------------------------
usethis::use_data(trac_selection, ices_selection, internal = TRUE, overwrite = TRUE)
