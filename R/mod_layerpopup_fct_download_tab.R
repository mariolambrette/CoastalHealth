#' Format selected layer table for download
#'
#' @param layers The dataframe of selected layers created in the layerpopup module
#'
#' @return Formatted dataframe ready to be saved as a csv file
#' @noRd

download_tab <- function(layers) {
  
  tab <- layers %>%
    dplyr::select(-c(spatial_filtering, temporal_filtering, id)) %>%
    dplyr::rowwise() %>%
    # Process all urls for place holders
    dplyr::mutate(
      url = process_url(url),
      source = process_url(source)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(
      name, source, url, download_format, browser_compatible, sf_compatible
    ) %>%
    dplyr::rename(
      "Layer_name" = name,
      "Source" = source,
      "Download_link" = url,
      "Download_format" = download_format
    )
  
  return(tab)
  
}
