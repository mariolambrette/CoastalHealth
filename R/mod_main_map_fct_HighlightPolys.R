#' Create colour index layer for highlighted polygons
#'
#' @description
#' Function to be run when a polygon is clicked by user. returns an sf object
#' that can be added to the map with a column 'colours' that will highlight
#' the correct polygons upstream and downstream.
#'
#'
#' @param selectID The ID of the polygon selected by the user
#' @param sc The subcatchment sf object (retrieved from the shps object imported into parent environment for generating basemaps)
#'
#' @return
#' @export
#'
#' @examples
#'
#' p <- HighlightPolys(selectID = 53)
#'
#'

HighlightPolys <- function(selectID = NULL, sc = ImportSPA(db.connection = atlas_env$con)$SHP_SPA_sc){
  
  # Import upstream and down stream ID data
  usds <- tbl(atlas_env$con, 'POLY_data') %>%
    select(ID, upstream, downstream) %>%
    filter(ID == selectID) %>%
    collect() %>%
    rowwise() %>%
    mutate(upstream = if_else(
      length(upstream) != 0,
      list(upstream %>% strsplit(., " ") %>% unlist() %>% as.numeric()),
      NA
    ),
    downstream = if_else(
      length(downstream) != 0,
      list(downstream %>% strsplit(., " ") %>% unlist() %>% as.numeric()),
      NA
    ))
  
  # Define the polygons to be coloured
  colours <- sc %>%
    select(ID) %>%
    mutate(colour = if_else(ID %in% unlist(usds$upstream),  '#382f4f' ,
                            if_else(ID %in% unlist(usds$downstream), '#89a4c4',
                                    if_else(ID == selectID, '#E89005', NA)))) %>%
    filter(!is.na(colour))
  
  return(colours)
}