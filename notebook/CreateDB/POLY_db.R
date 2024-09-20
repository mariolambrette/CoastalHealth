## Preparing ExeAtlas data for interactive map

setwd("C:/Users/ml673/University of Exeter/Exe Atlas - Documents/data")

library(sf)
library(terra)
library(dplyr)

## 1. Load in EA polygons and clean out data leaving simple shapefile with IDs
## 2. Create data storage dataframe to hold values for eacg polygon ID
## 3. Calculate data values for each polygon
## 4. Add connected polygons to dataframe (upstream and downstream)
## 5. Create database of other optional layers (management areas etc.)

## CONNECT TO DATABASE ----

# Create path to database
rel.save.path <- file.path('..', 'sw', 'InteractiveMap')
sp <- file.path(getwd(), rel.save.path) %>%
  normalizePath()

if(!dir.exists(sp)){
  dir.create(sp)
}

con <- DBI::dbConnect(RSQLite::SQLite(), paste0(sp, '\\InteractiveMap.db'))

## LOAD EA SUBCATCHMENTS ----

# Read the shapefile
sc <- sf::st_read('spatial/Sub_catchments_BNG.shp')

# Extract ID column
ID <- sc$ID

# Select only the ID column
sc <- sc[, 18, drop = FALSE]

# Rename the column to 'ID'
colnames(sc)[1] <- 'ID'

# Save a version of the subcatchment sf as a SpatVector for future reference
sc_sv <- terra::vect(sc)

# Change the geometry column to WKT
sc <- sc %>%
  mutate(geom = sf::st_as_text(geometry)) %>%
  sf::st_drop_geometry()

# Write subcatchments into database
dplyr::copy_to(
  dest = con,
  df = sc,
  name = 'SHP_subcatchments',
  overwrite = T,
  indexes = 'ID'
)

RSQLite::dbListTables(con)


## CREATE POLYGON DATA TABLE ----

# Polygon data to be included:
# 1. Polygon ID
#      - numeric
#      - single value
# 2. Polygon area
#      - numeric
#      - single value
#      - Unit = m^2
# 3. EA water body name
#      - string
#      - single value
# 4. EA catchment IDs
#      - numeric
#      - single value
# 5. Presence of management areas
#      - % cover for each management type
#      - numeric
#      - multiple columns with `ma_` prefix
#      - Unit: m^2
# 6. Land use proportions
#      - numeric (% of land cover)
#      - Multiple columns - one for each land type with 'lt_' prefix
#      - crop type data
# 7. Presence of key species
#      - Boolean
#      - Multiple columns - one for each species with 'ks_' prefix
# 8. Pesticide use
# 9. Fertiliser use
# 10. Industrial activity
# 11. Mean elevation
#      - numeric
#      - single value
# 12. Nitrate vulnerable zone presence
#      - Boolean
#      - single value (presence/absence)
# 13. Sewage discharge
# 14. Priority habitat presence
# 15. Priority species presence
# 16. Upstream & downstream polygons
#      - Character
#      - Single character string made up of each upstream/downstream
#        subcatchment ID separated by a space

# 1. Initialise database tables ----

# Polygon data with ID column
poly_data <- dplyr::tibble(ID = ID)

# Polygon lookup table to decode column headers
poly_lu <- dplyr::tibble(
  prefix = 'ID',
  type = 'numeric',
  quantity = 1,
  disp_name = 'ID',
  triggers = NA
)

# 2. Polygon area ----
poly_data$shp_area <- terra::expanse(
  sc_sv,
  transform = T,
  unit = 'm'
)

poly_lu <-
  list(prefix = 'shp_area',
       type = 'numeric',
       quantity = 1,
       disp_name = 'Subcatchment Area',
       triggers = NA) %>%
  bind_rows(poly_lu, .)


# 3. Water Body name ----
poly_data$wb_name <- terra::vect('spatial/Sub_catchments_BNG.shp') %>%
  terra::values() %>%
  dplyr::pull(WB_NAME)

poly_lu <-
  list(prefix = 'wb_name',
       type = 'character',
       quantity = 1,
       disp_name = 'Water basin name',
       triggers = NA) %>%
  bind_rows(poly_lu, .)

# 4. Water Body IDs
poly_data$wb_id <- terra::vect('spatial/Sub_catchments_BNG.shp') %>%
  terra::values() %>%
  dplyr::pull(WB_ID)

poly_lu <-
  list(prefix = 'wb_id',
       type = 'character',
       quantity = 1,
       disp_name = 'Water basin ID',
       triggers = NA) %>%
  bind_rows(poly_lu, .)

# 5. Presence of Management Areas ----

# List management area extent files
MA_files <- list(
  WHS = 'terrestrial/World_Heritage_Sites_clipped_BNG.shp',
  LNR = 'terrestrial/LNRs_clipped_BNG.shp',
  IBA = NULL,
  BR = NULL,
  HC = 'terrestrial/Heritage_coast_clipped_BNG.shp',
  RSPBr = 'terrestrial/RSPB_reserves_clipped_BNG.shp',
  RSPBpl = 'terrestrial/RSPB_priority_landscapes_clipped_BNG.shp',
  AONBs = 'terrestrial/AONBs_clipped_BNG.shp',
  NPs = 'terrestrial/NP_areas_clipped_BNG.shp',
  SACs = 'terrestrial/Terrestrial_SACs_clipped_BNG.shp',
  SPAs = 'terrestrial/SPAs_clipped_BNG.shp',
  SSSI = 'terrestrial/SSSIs_clipped_BNG.shp',
  RAMSAR = 'terrestrial/RAMSAR_clipped_BNG.shp',
  CWS = NULL,
  CGS = NULL,
  WRs = NULL
)

ma_lu <- tibble::tibble(
  abrv = names(MA_files) %>% tolower(),
  disp_name = c('World Heritage Sites',
           'Local Nature Reserves',
           'Important Bird & Biodiversity Area UNAVAILABLE',
           'Biosphere Reserve UNAVAILABLE',
           'Heritage Coast',
           'RSPB Reserves',
           'RSPB Priority Landscapes',
           'AONBs',
           'National Parks',
           'SACs',
           'SPAs',
           'SSSIs',
           'RAMSAR Sites',
           'County Wildlife Sites UNAVAILABLE',
           'County Geological Sites UNAVAILABLE',
           'Wildlife Reserves UNAVAILABLE')
)

# Save ma_lu into the database as 'MA_lookup'
RSQLite::dbWriteTable(
  conn = con,
  name = 'MA_lookup',
  value = ma_lu,
  overwrite = T
)

# Get vector of column numbers and add required columns to db
cols <- c(5:(5+(length(MA_files)-1)))
poly_data[,cols] <- NA

# Loop over columns and add the % area of the polygon that is covered by each management type
plyr::llply(
  cols,
  function(x){
    # Get filename
    f <- MA_files[[x-4]]

    # Check that filename exists
    if(is.null(f)){
      poly_data[,x] <<- NA
      colnames(poly_data)[x] <<- names(MA_files)[[x-4]] %>%
        tolower() %>%
        paste0('ma_', .)
      return()
    }

    # Read management file
    ma <- terra::vect(f)

    # Calculate intersection area for each polygon
    poly_data[,x] <<- sapply(
      1:nrow(sc_sv),
      function(i){
        # Extract index polygon
        p <- sc_sv[i]

        area <- terra::intersect(p, ma) %>%
          terra::expanse(
            .,
            transform = T,
            unit = 'm'
          ) %>%
          sum()

        return(area)
      }
    )

    # Use the interesction area to calculate the % coverage
    poly_data[,x] <<- (poly_data[,x]/poly_data$shp_area)*100
    poly_data[,x] <<- round(poly_data[,x], digits = 2)

    colnames(poly_data)[x] <<- names(MA_files)[[x-4]] %>%
      tolower() %>%
      paste0('ma_', .)

    return()
  },
  .progress = 'text'
)

poly_lu <-
  list(prefix = 'ma_',
       type = 'numeric',
       quantity = length(MA_files),
       disp_name = 'Management area coverage',
       triggers = NA) %>%
  bind_rows(poly_lu, .)

rm(MA_files, cols)

# 6. Land use proportions ----
# Load land cover file
lc <- terra::vect('terrestrial/CEH_lc_parcels_clipped_BNG.shp')

# Landcover look up codes and colours
lc_lu <- terra::values(lc) %>%
  distinct(class, .keep_all = T) %>%
  select(c('class', 'BAP', 'colour', '_mode')) %>%
  rename(code = `_mode`) %>%
  arrange(code)

# Save lc_lu into the database as 'LC_lookup'
RSQLite::dbWriteTable(
  conn = con,
  name = 'LC_lookup',
  value = lc_lu,
  overwrite = T
)

# Column indices in database
cols <- c(21:(20+nrow(lc_lu)))

plyr::llply(
  cols,
  function(x){

    # Extract habitat name
    h <- lc_lu$class[x-20]

    # Subset landcover file
    l <- terra::subset(
      lc,
      lc$class == h
    )

    # Calculate the intersection area for each polygon
    poly_data[,x] <<- sapply(
      1:nrow(sc_sv),
      function(i){
        # Select polygon
        p <- sc_sv[i]

        # Calculate intersection area
        area <- terra::intersect(p, l) %>%
          terra::expanse(
            .,
            transform = T,
            unit = 'm'
          ) %>%
          sum()

        return(area)
      }
    )

    # Use the intersection area to calculate the % coverage
    poly_data[,x] <<- (poly_data[,x]/poly_data$shp_area)*100
    poly_data[,x] <<- round(poly_data[,x], digits = 2)

    # Set column name
    colnames(poly_data)[x] <<- paste0('lc_', lc_lu$code[x-20]) %>%
      tolower()

    return()
  },
  .progress = 'text'
)

poly_lu <-
  list(prefix = 'lc_',
       type = 'numeric',
       quantity = nrow(lc_lu),
       disp_name = 'Land cover',
       triggers = NA) %>%
  bind_rows(poly_lu, .)

rm(lc, cols)

# Crop type proportions
# Load crome file
crome <- terra::vect('terrestrial/CROME_21_clipped_BNG.shp')

# Crop type look up codes and colours
ct_lu <- terra::values(crome) %>%
  distinct(lucode, .keep_all = T) %>%
  select(lucode, Crop, CropType) %>%
  arrange(CropType) %>%
  mutate(colour = c('#a56f00', '#ffd300', '#a15a88', '#dae319', '#dae319',
                    '#6f2400', '#ac007c', '#ffff00', '#b84b12', '#d9b56a',
                    '#a15a88', '#6e55ca', '#d6ff6f', '#cd6600', '#e9ffbf',
                    '#bfbfbf', '#826449', '#55ff00', '#826449', '#979797',
                    '#006000', '#ff6666', '#4d6fa4'))

# Save ct_lu into the database as 'CT_lookup'
RSQLite::dbWriteTable(
  conn = con,
  name = 'CT_lookup',
  value = ct_lu,
  overwrite = T
)

# Column indices in database
cols <- c(41:(41+nrow(ct_lu)))

plyr::llply(
  cols,
  function(x){

    # Get the crop lucode
    ct <- ct_lu$lucode[x-41]

    # Subset the crop type file
    ct_ext <- terra::subset(
      crome,
      crome$lucode == ct
    )

    # Calculate the intersection area for each polygon
    poly_data[,x] <<- sapply(
      1:nrow(sc_sv),
      function(i){
        # Select polygon
        p <- sc_sv[i]

        # Calculate intersection area
        area <- terra::intersect(p, ct_ext) %>%
          terra::expanse(
            .,
            transform = T,
            unit = 'm'
          ) %>%
          sum()

        return(area)
      }
    )

    # Use the intersection area to calculate the % coverage
    poly_data[,x] <<- (poly_data[,x]/poly_data$shp_area)*100
    poly_data[,x] <<- round(poly_data[,x], digits = 2)

    # Set column name
    colnames(poly_data)[x] <<- paste0('ct_', ct) %>%
      tolower()

    return()
  },
  .progress = 'text'
)

poly_lu <-
  list(prefix = 'ct_',
       type = 'numeric',
       quantity = nrow(ct_lu),
       disp_name = 'Crop type',
       triggers = NA) %>%
  bind_rows(poly_lu, .)

rm(crome, cols)

# 7. Presence of key species ----

## Key species need to be identified and spatial extents need to be ##
## calculated so that overlaps can be extracted                     ##


# 8. Pesticide use ----

## Processing script for pesticide use needs to be amended to       ##
## include look-up table for raster band names                      ##


# 9 . Fertiliser use ----

## Processing script for fertiliser use needs to be amended to      ##
## include look-up table for raster band names                      ##


# 10. Industrial activity ----


# 11. Mean elevation ----


# 12. Nitrate vulnerable zone presence ----


# 13. Sewage discharge ----


# 14. Priority habitat presence ----


# 15. Priority species presence ----


# 16. Upstream & downstream polygons ----

# Load downstream csv file
ds <- read.csv(paste0(sp, '\\Notes_Examples\\TempDataStore\\downstream.csv')) %>%
  arrange(ID)

# Calculate all downstream subcatchments
ds.a <- lapply(
  ID,
  function(x){
    # Get first down stream polygon
    d <- ds$Downstream1[x]

    # Initiate vector of downstream polygons
    ds.v <- c(d)

    # Add the second downstream polygon where applicable
    if(!is.na(ds$Downstream2[x])){
      ds.v <- append(ds.v, ds$Downstream2[x])
    }

    # Loop thorugh downstream polygons until an NA is reached
    while(!is.na(d)){
      d <- ds$Downstream1[d]
      ds.v <- append(ds.v, d)
    }

    # remove the last element of the downstream vector which will alwys be an NA
    if(length(ds.v) > 1){
      ds.v <- ds.v[-c(length(ds.v))]
    }

    return(ds.v)
  }
)

# Use these to calculate all downstream subcatchments and collapse both into
# a single character vector for each ID so that a single column can be added to
# the db
us.a <- lapply(
  ID,
  function(x){

    # For the given ID number, loop through each of the downstream list elements
    # and check the if the ID is present. If so that subcatchment is upstream of
    # the current ID
    s <- c(1:length(ds.a))
    us <- sapply(
      s,
      function(i){
        # Check if subcatchment 'x' is downstream of subcatchment 'i'
        if (as.numeric(x) %in% as.numeric(ds.a[[i]])){
          return(i)
        } else{
          return(NA)
        }
      }
    ) %>%
      na.omit()

    # collapse upstream polygons
    us <- paste(us, collapse = ' ') %>%
      unlist()

    # Collapse downstream polygons for subcatchment 'x'
    ds.a[[x]] <<- paste(ds.a[[x]], collapse = ' ') %>%
      unlist()

    return(us)
  }
)

# Add upstream and downstream vectors to the database
poly_data$upstream <- us.a %>%
  unlist()
poly_data$downstream <- ds.a %>%
  unlist()

poly_lu <-
  list(prefix = 'upstream',
       type = 'character',
       quantity = 1,
       disp_name = 'Upstream water bodies',
       triggers = NA) %>%
  bind_rows(poly_lu, .)

poly_lu <-
  list(prefix = 'downstream',
       type = 'character',
       quantity = 1,
       disp_name = 'Downstream water bodies',
       triggers = NA) %>%
  bind_rows(poly_lu, .)


## STORE POLY_DATA AND POLY_LOOKUP IN DATABASE

# Save tables
RSQLite::dbWriteTable(
  conn = con,
  name = 'POLY_data',
  value = poly_data,
  overwrite = T
)
RSQLite::dbWriteTable(
  conn = con,
  name = 'POLY_lookup',
  value = poly_lu,
  overwrite = T
)

# Disconnect from database
RSQLite::dbDisconnect(con)
rm(con)
