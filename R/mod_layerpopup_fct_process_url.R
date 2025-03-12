#' Process urls to add variables
#'  
#' @description
#' Helper function to process web urls to add variables such as opcat ids and 
#' spatial and temporal extents
#' 
#' Variables should follow the below format:
#' 
#' **operational catchmnet id:** {opcat_id}
#' **Spatial extent:** {xmin}, {xmax} etc.
#' **Temporal extent:** {sd_YYYY-MM-DD}, {ed_YYYY-MM-DD}. Replace with the appropriate format to be used as a character string in R datetime processing functions
#' 
#' @param url A web url where any variables follow the above stated format
#'
#' @return Process urls as character strings
#'
#' @examples
#' \dontrun{
#'  process_url("https://environment.data.gov.uk/geoservices/datasets/6da82900
#'  -d465-11e4-8cc3-f0def148f590/ogc/features/v1/collections/Saltmarsh_Extents_
#'  and_Zonation/items?limit=300000&bbox={xmin},{ymin},{xmax},{xmin}")
#' }
#' 
#' @noRd

process_url <- function(url) {
  
  if (grepl("\\{opcat_id\\}", url)) { # Check if opcat_ids need to be added
    
    # Replace {opcat_id} with all the opcat ids
    url <- paste0(
      sapply(unique(atlas_env$trac$opcat_id), function(id) gsub("\\{opcat_id\\}", id, url)),
      collapse = ","
    )
  }
  
  if (grepl("\\{mncat_id\\}", url)) { # Check if mncat_ids need to be added
    
    # Replace {mncat_id} with all the mncat ids
    url <- paste0(
      sapply(unique(isolate(atlas_env$opcats_spatial())$mncat_id), function(id) gsub("\\{mncat_id\\}", id, url)),
      collapse = ","
    )
  }
  
  if ((grepl("\\{xmax\\}", url))) { # Check for spatial filtering
    
    # Replace with values from atlas_env$bounds
    url <- gsub("\\{xmin\\}", atlas_env$bounds[[1]], url)
    url <- gsub("\\{ymin\\}", atlas_env$bounds[[2]], url)
    url <- gsub("\\{xmax\\}", atlas_env$bounds[[3]], url)
    url <- gsub("\\{ymax\\}", atlas_env$bounds[[4]], url)
    
  }
  return(url)
  
}
