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
#' @return Subcatchment sf object with colour column
#'
#' @examples
#'
#' p <- HighlightPolys(selectID = 53)
#'
#' @importFrom dplyr tbl select filter collect rowwise mutate
#' @importFrom magrittr `%>%`

HighlightPolys <- function(selectID = NULL, sc = ImportSPA(db.connection = atlas_env$con)$SHP_SPA_sc){
  
  # Import upstream and down stream ID data
  usds <- dplyr::tbl(atlas_env$con, 'POLY_data') %>%
    dplyr::select(ID, upstream, downstream) %>%
    dplyr::filter(ID == selectID) %>%
    dplyr::collect() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      upstream = if_else(
        length(upstream) != 0,
        list(upstream %>% strsplit(., " ") %>% unlist() %>% as.numeric()),
        NA
      ),
      downstream = if_else(
        length(downstream) != 0,
        list(downstream %>% strsplit(., " ") %>% unlist() %>% as.numeric()),
        NA
      )
    )
  
  # Define the polygons to be coloured
  colours <- sc %>%
    dplyr::select(ID) %>%
    dplyr::mutate(colour = if_else(ID %in% unlist(usds$upstream),  '#382f4f' ,
                                   if_else(ID %in% unlist(usds$downstream), '#89a4c4',
                                           if_else(ID == selectID, '#E89005', NA)))) %>%
    dplyr::filter(!is.na(colour))
  
  return(colours)
}