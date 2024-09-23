#' Add layers to base map
#'
#' @description
#' Add layers onto the basic base map, including optional data layers
#'
#'
#' @param bm Basic basemap created with the BaseMap() function. Calls `BaseMap()` by default, though this not the ideal implementation when the function is used in production
#' @param add_layers A list of file paths to the layers to add
#'
#' @return A character string that contains the plotting command to be evaluated by `eval(parse(text = cmd))` to add the correct data layer to the base map
#' 
#'
#' @examples
#' 
#' \dontrun{
#' print(ggiraph::girafe(ggobj = AddLayers(bm)))
#'
#' # Complete plot
#' p <- BaseMap()
#' p1 <- AddLayers(bm = p)
#' p2 <- ggiraph::girafe(ggobj = p1)
#' print(p2)
#' }
#' 
#' @importFrom dplyr tbl filter select collect pull

AddLayers <- function(add_layers = 'none',
                         db.connection = atlas_env$con){
  
  if (add_layers == 'none') {
    return()
  }
  
  # Extract the plotting command for the selected layer from the database
  plot_cmd <- dplyr::tbl(db.connection, "SHP_lookup") %>%
    dplyr::filter(SHP_name == add_layers) %>%
    dplyr::select(aes) %>%
    dplyr::collect() %>%
    dplyr::pull(aes)
  
  return(plot_cmd)
  
}