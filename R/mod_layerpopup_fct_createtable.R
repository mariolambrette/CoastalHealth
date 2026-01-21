

#' Create reactable widget for rendering
#' 
#' @description
#' Function that creates a reactable object from the selected layers. The output
#' is the result from `reactable::reactable()`. the function is
#' used in the server side of the layerpopup module to create and format the 
#' table to be rendered in the ui..
#' 
#'
#' @param layers Filtered verion of the layer_urls table containing user selected layers.
#' @param ns Module namepace for correct internal varibale namespacing
#'
#' @return a `reactable` widget that can be rendered by `reactable::renderReactable()`
#' 
#' @importFrom reactable reactable reactableTheme colDef
#' @importFrom dplyr rowwise mutate select ungroup pull
#' @importFrom jsonlite toJSON
#' @import magrittr
#'
#' @examples
#' \dontrun{
#' layers <- data.table::fread(system.file("extdata", "layer_urls.csv", package = "CoastalHealth"))
#' createtable(layers[1:5,])
#' }
#' 
#' @noRd

createtable <- function(layers, ns) {
  
  # Process layers table before rendering
  layers <- layers %>%
    dplyr::rowwise() %>%
    # Process all urls for place holders
    dplyr::mutate(
      url = process_url(url),
      source = process_url(source)
    ) %>%
    dplyr::ungroup() %>%
    # Expand urls to lists where necessary
    dplyr::mutate(
      url_list = strsplit(url, ","),
      source_list = strsplit(source, ",")
    ) %>%
    dplyr::select(name, source_list, url_list, download_format, sf_compatible, id, url, source, 
                  browser_compatible, spatial_filtering, temporal_filtering, 
                  )
  
  # Extract a vector of all urls and for bulk processing by browser
  atlas_env$selected_urls_browser <- layers %>%
    dplyr::filter(browser_compatible == "T") %>%
    dplyr::pull(url_list) %>%
    unlist() %>%
    unique()
  
  # Extract a vector of all urls and for bulk processing by sf
  atlas_env$selected_urls_sf <- layers %>%
    dplyr::filter(sf_compatible == "T") %>%
    dplyr::pull(url_list, name = id)
  
  reactable::reactable(
    data = layers,
    
    columns = list( 
      
      # Layer names
      name = reactable::colDef(
        name = "Layer name",
        searchable = TRUE,
        align = "left",
        vAlign = "top",
        sticky = "left",
        style = list(
          fontWeight = "bold",
          fontSize = "12px"
        ),
        headerStyle = list(
          fontWeight = "bold",
          fontSize = "14px"
        )
      ),
      
      # Web links (sources)
      source_list = reactable::colDef(
        name = "Web link",
        searchable = FALSE,
        align = "left",
        vAlign = "top",
        cell = function(value, index) {
          
          url <- layers$url[index]
          
          if (url != "NA (internal data)") {
            
            if (length(value) == 1) {
              # Single URL - create a direct hyperlink
              return(sprintf('<a href="%s" target="_blank" style="color: blue;">open source</a>', value))
            } else {
              # Multiple URLs - create a single clickable link that opens all in new tabs
              urls_json <- jsonlite::toJSON(value, auto_unbox = TRUE)
              js_function <- sprintf(
                '<a href="#" onclick=\'(function() { 
             var urls = %s; 
             urls.forEach(function(url) { 
               window.open(url, "_blank"); 
             }); 
             return false;
           })()\' style="color: blue;">open all sources</a>',
                urls_json
              )
              
              return(js_function)
            }
            
          } else {
            return("NA")
          }
        },
        html = TRUE
      ),
      
      # Clickable download links (browser download)
      url_list = reactable::colDef(
        name = "Download link",
        searchable = FALSE,
        align = "left",
        vAlign = "top",
        cell = function(value, index) {
          
          # check if link is browser download compatible
          browser_compatible <- layers$browser_compatible[index]
          
          if (browser_compatible == "T") {
            
            if (length(value) == 1) {
              # Single URL case - just create a direct link
              return(sprintf('<a href="%s" target="_blank" style="color: blue;">download</a>', value))
            } else {
              # Multiple URLs case - create a single link with an onClick handler
              urls_json <- jsonlite::toJSON(value, auto_unbox = TRUE) # Ensure JSON is an array, not a string
              js_function <- sprintf(
                '<a href="#" onclick=\'(function() { 
             var urls = %s; 
             urls.forEach(function(url) { 
               window.open(url, "_blank"); 
             }); 
             return false;
           })()\' style="color: blue;">download all</a>',
                urls_json
              )
              
              return(js_function)
            }
            
          } else {
            return("NA")
          }
        },
        html = TRUE
      ),
      
      download_format = reactable::colDef(
        name = "Download format",
        searchable = FALSE,
        align = "left",
        vAlign = "top",
        cell = function(value, index) {
          
          # check is link is browser download compatible
          browser_compatible <- layers$browser_compatible[index]
          
          
          if (browser_compatible == "T") {
            return(value)
          } else {
            return("NA")
          }
        }
      ),
      
      # sf download button
      sf_compatible = reactable::colDef(
        name = "Load with sf",
        searchable = FALSE,
        align = "left",
        vAlign = "top",
        
        cell = function(value, index, row) {
          if (value == "T") {
            
            # Get the url_list from the current row
            url_value <- layers$url_list[[index]]
            url_json <- jsonlite::toJSON(url_value)
            
            # Get the layer id
            id <- layers$id[[index]]
            id_json <- jsonlite::toJSON(id)
            
            shiny::tags$button(
              type = "button",
              class = "btn neut-btn btn-allsf",
              "Load with sf",
              onclick = paste0("Shiny.setInputValue('", ns("load_layer_sf"), "',
                         {ts: Date.now(), id: ", id_json, ", url: ", url_json, "}, 
                         { priority: 'event' })")
            )
          } else {
            shiny::tags$p(
              style = "color: red;",
              "Not sf compatible."
            )
        }
      ),
      
      id = reactable::colDef(
        show = FALSE
      ),

      browser_compatible = reactable::colDef(
        show = FALSE
      ),

      spatial_filtering = reactable::colDef(
        show = FALSE
      ),

      temporal_filtering = reactable::colDef(
        show = FALSE
      ),

      url = reactable::colDef(
        show = FALSE
      ),

      source = reactable::colDef(
        show = FALSE
      )
    ),
    
    sortable = FALSE,
    resizable = TRUE,
    filterable = FALSE,
    searchable = TRUE,
    pagination = TRUE,
    defaultPageSize = 25, # Show 25 rows
    highlight = TRUE,     # highlight table rows on hover
    wrap = TRUE,          # wrap text
    fullWidth = TRUE,     # Stretch table to fill full container width
    
    theme = reactable::reactableTheme(
      
    )
  )
}
