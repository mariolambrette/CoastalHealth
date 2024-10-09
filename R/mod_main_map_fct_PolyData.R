#' Get WKT format list of management areas present
#'
#' @param poly_row row from POLY_data for the corresponding polygon
#'
#' @return List of Management areas present in selected subcatchment
#' 
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select tbl filter collect
#'

MAs_list <- function(poly_row = data){
  
  mas <- poly_row %>%
    dplyr::select(starts_with('ma_')) %>%
    dplyr::select(where(~ !is.na(.) & . != 0)) %>%
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
  names <- dplyr::tbl(
      atlas_env$con,
      'MA_lookup'
    ) %>%
    dplyr::filter(abrv %in% mas) %>%
    dplyr::select(disp_name) %>%
    dplyr::collect()
  
  names <- paste(names$disp_name, collapse = ', ')
  
  if (nchar(names) == 0) {
    names = 'None'
  }
  
  return(names)
}


#' Skeleton for function to return WKT key species present list. currently returns NA
#'
#' @param polyID selected polygon ID
#' @param poly_row Row of polygon data
#'
#' @return NA
#'

KS_list <- function(polyID, poly_row = data){
  return(NA)
}



#' Get dominant land cover for a selected polygon
#'
#' @param poly_row row from POLY_data for the corresponding polygon
#'
#' @return Nma eof the dominant land cover class in selected polygon
#'
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select slice pull tbl filter collect
#' @importFrom tidyr pivot_longer

DominantLC <- function(poly_row = data){
  
  # Find the land cover class with the highest coverage
  lc <- poly_row %>%
    dplyr::select(starts_with('lc_')) %>%
    tidyr::pivot_longer(
      cols = everything(),
      names_to = 'column',
      values_to = 'value'
    ) %>%
    dplyr::slice(which.max(value)) %>%
    dplyr::pull(column) %>%
    strsplit(., '_') %>%
    unlist() %>%
    .[[2]]
  
  # Get the Natural England habitat name for the identified class
  class <- dplyr::tbl(
    atlas_env$con,
    'LC_lookup'
  ) %>%
    dplyr::filter(code == as.numeric(lc)) %>%
    dplyr::select(class) %>%
    dplyr::collect() %>%
    dplyr::pull(class)
  
  return(class)
}


#' Get Cumulative sewage discharge summary message
#'
#' @param data cumulative sewage discharge table from database
#'
#' @return Description of upstream cummulative sewage discharges
#'
#' @importFrom magrittr `%>%`
#' @importFrom dplyr tbl select filter collect rowwise mutate pull if_else
#'

CSD <- function(data = tbl(atlas_env$con, "SHP_DAT_csd") %>%
                  collect()){
  
  # Import upstream ID data
  us <- dplyr::tbl(atlas_env$con, 'POLY_data') %>%
    dplyr::select(ID, upstream) %>%
    dplyr::filter(ID == atlas_env$polyID) %>%
    dplyr::collect() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(upstream = dplyr::if_else(
      length(upstream) != 0,
      list(upstream %>% strsplit(., " ") %>% unlist() %>% as.numeric()),
      NA
    )) %>%
    dplyr::pull(upstream) %>%
    unlist()
  
  # Filter cumulative sewage discharge sites
  csds <- data %>%
    dplyr::filter(sc_ID %in% c(us, atlas_env$polyID))
  
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
