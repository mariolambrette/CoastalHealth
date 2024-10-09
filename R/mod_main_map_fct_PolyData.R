#' Get WKT format list of management areas present
#'
#' @param polyID ID of selected polygon
#' @param poly_row row from POLY_data for the corresponding polygon
#'
#' @return
#' @export
#'
#' @examples
#'

MAs_list <- function(poly_row = data){
  
  mas <- poly_row %>%
    select(starts_with('ma_')) %>%
    select(where(~ !is.na(.) & . != 0)) %>%
    colnames(.) %>%
    sapply(
      .,
      function(x){
        strsplit(x, '_') %>%
          unlist() %>%
          .[[2]]
      }
    )
  
  # Load relevant MA names from the database
  names <- tbl(
    atlas_env$con,
    'MA_lookup'
  ) %>%
    filter(abrv %in% mas) %>%
    select(disp_name) %>%
    collect()
  
  names <- paste(names$disp_name, collapse = ', ')
  
  if (nchar(names) == 0) {
    names = 'None'
  }
  
  return(names)
}


#' Skeleton for function to return WKT key species present list. currently returns NA
#'
#' @param polyID
#' @param poly_row
#'
#' @return
#' @export
#'
#' @examples
KS_list <- function(polyID, poly_row = poly_data %>% filter(ID == polyID)){
  return(NA)
}



#' Get dominant land cover for a selected polygon
#'
#' @param polyID ID of selected polygon
#' @param poly_row row from POLY_data for the corresponding polygon
#'
#' @return
#' @export
#'
#' @examples
#'

DominantLC <- function(poly_row = data){
  
  # Find the land cover class with the highest coverage
  lc <- poly_row %>%
    select(starts_with('lc_')) %>%
    tidyr::pivot_longer(
      cols = everything(),
      names_to = 'column',
      values_to = 'value'
    ) %>%
    slice(which.max(value)) %>%
    pull(column) %>%
    strsplit(., '_') %>%
    unlist() %>%
    .[[2]]
  
  # Get the Natural England habitat name for the identified class
  class <- tbl(
    atlas_env$con,
    'LC_lookup'
  ) %>%
    filter(code == as.numeric(lc)) %>%
    select(class) %>%
    collect() %>%
    pull(class)
  
  return(class)
}


#' Get Cumulative sewage discharge summary message
#'
#' @param polyID Selected subcatchment ID
#' @param data cumulative sewage discharge table from database
#'
#' @return
#' @export
#'
#' @examples
#'

CSD <- function(data = tbl(atlas_env$con, "SHP_DAT_csd") %>%
                  collect()){
  
  # Import upstream ID data
  us <- tbl(atlas_env$con, 'POLY_data') %>%
    select(ID, upstream) %>%
    filter(ID == atlas_env$polyID) %>%
    collect() %>%
    rowwise() %>%
    mutate(upstream = if_else(
      length(upstream) != 0,
      list(upstream %>% strsplit(., " ") %>% unlist() %>% as.numeric()),
      NA
    )) %>%
    pull(upstream) %>%
    unlist()
  
  # Filter cumulative sewage discharge sites
  csds <- data %>%
    filter(sc_ID %in% c(us, atlas_env$polyID))
  
  if (nrow(csds) == 0) {
    message <- "No continuous sewage discharges in selected subcatchment"
  } else{
    dwf    <- sum(csds$DryWeatherFlow, na.rm = T)
    n      <- nrow(csds)
    unspec <- is.na(csds$DryWeatherFlow) %>%
      sum()
    spec   <- n - unspec
    
    message <- paste0(
      spec, " continous sewage disacharge site(s) with cumulative dry weather flow
      rate of ", dwf, " m^3 day^-1 plus ", unspec, " site(s) with unspecified
      flow rates."
    )
  }
  
  return(message)
}
