# tests/test_layer_urls.R

devtools::load_all()
library(sf)
library(data.table)
library(dplyr)
library(arcgislayers)

test_layer_urls <- function(
    # Use a real mncat to ensure valid opcat/mncat ids
  test_mncat = "East Hampshire",
  max_features = 5,
  verbose = TRUE
) {
  
  # ---- 1. Bootstrap atlas_env with plain (non-reactive) values ----
  
  env_setup(reset = TRUE)
  
  if (is.null(atlas_env$opcats_all)) {
    stop("atlas_env$opcats_all is not populated. Is the package installed correctly?")
  }
  
  test_selection <- atlas_env$opcats_all %>%
    dplyr::filter(mncat_name == test_mncat)
  
  if (nrow(test_selection) == 0) {
    stop("Test management catchment '", test_mncat, "' not found.")
  }
  
  # Read spatial data and filter directly - no reactives
  opcats_spatial <- sf::read_sf(
    system.file("extdata", "OperationalCatchmentsSpatial.gpkg", package = "CoastalHealth")
  ) %>%
    dplyr::filter(opcat_id %in% test_selection$opcat_id)
  
  # Calculate bounds
  atlas_env$bounds <- sf::st_bbox(opcats_spatial)
  
  # Calculate centre and radius for {x}, {y}, {radius_km} placeholders
  centroid <- sf::st_centroid(sf::st_union(opcats_spatial))
  coords <- sf::st_coordinates(centroid)
  atlas_env$area_centre <- data.frame(x = coords[1], y = coords[2])
  atlas_env$area_radius <- 20  # Reasonable default in km
  
  # Set up marine area data for {opcat_id} and {mncat_id} placeholders
  atlas_env$trac <- trac_selection %>%
    dplyr::filter(parent_mncat_id %in% unique(opcats_spatial$mncat_id)) %>%
    sf::st_as_sf(crs = 4326)
  
  atlas_env$ices <- ices_selection %>%
    dplyr::filter(mncat_id %in% unique(opcats_spatial$mncat_id)) %>%
    sf::st_as_sf(crs = 4326)
  
  # Override the reactive opcats_spatial with a plain function that returns the data
  # This is needed if process_url calls isolate(atlas_env$opcats_spatial())
  atlas_env$opcats_spatial <- function() opcats_spatial
  
  
  # ---- 2. Load and process layer URLs ----
  
  layers <- data.table::fread(
    system.file("extdata", "layer_urls.csv", package = "CoastalHealth")
  )
  
  results <- data.frame(
    name          = character(),
    id            = character(),
    url_type      = character(),
    status        = character(),
    n_features    = integer(),
    geometry_type = character(),
    error_message = character(),
    stringsAsFactors = FALSE
  )
  
  # ---- 3. Test each layer ----
  
  for (i in seq_len(nrow(layers))) {
    
    row <- layers[i, ]
    if (verbose) cat(sprintf("[%d/%d] %s ... ", i, nrow(layers), row$name))
    
    # Skip layers with no URL
    if (is.na(row$url) || row$url == "" || grepl("^NA", row$url)) {
      if (verbose) cat("SKIPPED\n")
      results <- rbind(results, data.frame(
        name = row$name, id = row$id, url_type = "none",
        status = "SKIPPED", n_features = NA_integer_,
        geometry_type = NA_character_,
        error_message = "No URL provided",
        stringsAsFactors = FALSE
      ))
      next
    }
    
    # Use the actual process_url function
    processed_url <- tryCatch(
      process_url(row$url),
      error = function(e) {
        return(paste0("URL_PROCESSING_ERROR: ", e$message))
      }
    )
    
    if (grepl("^URL_PROCESSING_ERROR", processed_url)) {
      if (verbose) cat("FAILED (url processing)\n")
      results <- rbind(results, data.frame(
        name = row$name, id = row$id, url_type = "processing",
        status = "FAILED", n_features = NA_integer_,
        geometry_type = NA_character_,
        error_message = processed_url,
        stringsAsFactors = FALSE
      ))
      next
    }
    
    # Take first URL if comma-separated (from opcat expansion)
    test_url <- strsplit(processed_url, ",")[[1]][1]
    url_type <- if (grepl("FeatureServer|MapServer", test_url)) "arcgis" else "sf_direct"
    
    # Attempt to load
    result <- tryCatch(
      {
        if (url_type == "arcgis") {
          
          if (!grepl("\\d+$", test_url)) test_url <- paste0(test_url, "/0")
          
          layer <- arcgislayers::arc_open(test_url)
          bbox_sf <- sf::st_as_sfc(atlas_env$bounds)
          sf_obj <- arcgislayers::arc_select(layer, filter_geom = bbox_sf, n_max = max_features)
          
        } else {
          sf_obj <- sf::read_sf(test_url)
          
          if (!is.null(atlas_env$bounds)) {
            sf_obj <- sf::st_crop(sf_obj, sf::st_as_sfc(atlas_env$bounds))
          }
          
          if (nrow(sf_obj) > max_features) {
            sf_obj <- sf_obj[1:max_features, ]
          }
        }
        
        n <- nrow(sf_obj)
        geom <- if (n > 0) {
          as.character(sf::st_geometry_type(sf_obj, by_geometry = FALSE))
        } else {
          "EMPTY"
        }
        
        data.frame(
          name = row$name, id = row$id, url_type = url_type,
          status = if (n > 0) "OK" else "OK (empty)",
          n_features = n, geometry_type = geom,
          error_message = NA_character_,
          stringsAsFactors = FALSE
        )
      },
      error = function(e) {
        data.frame(
          name = row$name, id = row$id, url_type = url_type,
          status = "FAILED", n_features = NA_integer_,
          geometry_type = NA_character_,
          error_message = conditionMessage(e),
          stringsAsFactors = FALSE
        )
      }
    )
    
    results <- rbind(results, result)
    if (verbose) cat(result$status, "\n")
  }
  
  # ---- 4. Summary ----
  
  cat("\n===== SUMMARY =====\n")
  cat(sprintf("Total:      %d\n", nrow(results)))
  cat(sprintf("OK:         %d\n", sum(results$status == "OK")))
  cat(sprintf("OK (empty): %d\n", sum(results$status == "OK (empty)")))
  cat(sprintf("Failed:     %d\n", sum(results$status == "FAILED")))
  cat(sprintf("Skipped:    %d\n", sum(results$status == "SKIPPED")))
  
  if (any(results$status == "FAILED")) {
    cat("\n--- FAILED LAYERS ---\n")
    failed <- results %>% dplyr::filter(status == "FAILED")
    for (j in seq_len(nrow(failed))) {
      cat(sprintf("  [%s] %s\n    -> %s\n",
                  failed$url_type[j], failed$name[j], failed$error_message[j]))
    }
  }
  
  invisible(results)
}

result <- test_layer_urls()
