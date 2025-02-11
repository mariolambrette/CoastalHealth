## Function that creates a reactable object from the selected layers. 
## The output is the result from `reactable::reactable()`. the function is
## used in the server side of the layerpopup module to create and format the
## table to rendered in the ui.


#' Create reactable widget for rendering
#'
#' @param layers Filtered verion of the layer_urls table containing user selected layers.
#' @param ns Module namepace for correct internal varibale namespacing
#'
#' @return a `reactable` widget that can be rendered by `reactable::renderReactable()`
#' 
#' @importFrom reactable reactable reactableTheme colDef
#' @importFrom dplyr rowwise mutate
#'
#' @examples
#' \dontrun{
#' layers <- read.csv(system.file("extdata", "layer_urls.csv", package = "CoastalHealth"))
#' createtable(layers[1:5,])
#' }
#' 

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
    dplyr::select(name, source_list, url_list, sf_compatible, id, url, source, 
                  browser_compatible, spatial_filtering, temporal_filtering)
  
  reactable::reactable(
    data = layers,
    
    # defaultColDef = reactable::colDef(
    #   show = FALSE
    # ),
    
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
            # Generate clickable hyperlinks for each URL
            links <- sapply(value, function(link) {
              sprintf('<a href="%s" target="_blank" style="color: blue;">link</a>', link)
            })
            # Combine links into a single cell with line breaks
            paste(links, collapse = "<br>")
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
          
          # check is link is browser download compatible
          browser_compatible <- layers$browser_compatible[index]
          
          if (browser_compatible) {
            
            # Generate clickable hyperlinks for each URL
            links <- sapply(value, function(link) {
              sprintf('<a href="%s" target="_blank" style="color: blue;">link</a>', link)
            })
            # Combine links into a single cell with line breaks
            paste(links, collapse = "<br>")
          
          } else {
            return("NA")
          }
        },
        html = TRUE
      ),
      
      # sf download button
      sf_compatible = reactable::colDef(
        name = "Load with sf",
        searchable = FALSE,
        align = "left",
        vAlign = "top",
        # cell = htmlwidgets::JS("
        #   function(rowInfo, column) {
        # 
        #     // Check if sf_compatible is true
        #     if (!rowInfo.values['sf_compatible']) {
        #       return '-';
        #     }
        # 
        #     console.log(rowInfo); // Log to check if the row data is correct
        # 
        #     // Return a button element
        #     return `<button 
        #               class='btn neut-btn' 
        #               onclick=\"Shiny.setInputValue(
        #                 'layer_info', 
        #                 { id: '${rowInfo.values['id']}', url: '${rowInfo.values['url']}' }, 
        #                 { priority: 'event' }
        #               )\">Load</button>`;
        #   }
        # ")
        
        cell = function(value, index) {
          if (value) {
            shiny::tags$button(
              type = "button",
              class = "btn neut-btn",
              "Load with sf",
              onclick = paste0("Shiny.setInputValue('", ns("load_layer_sf"), "', {ts: Date.now(), row: ", index, "}, { priority: 'event' })")
            )
          }
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

process_url <- function(url) {
  
  if (grepl("\\{opcat_id\\}", url)) { # Check if opcat_ids need to be added
    
    # Replace {opcat_id} with all the opcat ids
    paste0(
      sapply(isolate(atlas_env$opcats())$opcat_id, function(id) gsub("\\{opcat_id\\}", id, url)),
      collapse = ","
    )
  } else if ((grepl("\\{xmax\\}", url))) { # Check for spatial filtering
    
    # Replace with values from atlas_env$bounds
    url <- gsub("\\{xmin\\}", atlas_env$bounds[[1]], url)
    url <- gsub("\\{ymin\\}", atlas_env$bounds[[2]], url)
    url <- gsub("\\{xmax\\}", atlas_env$bounds[[3]], url)
    url <- gsub("\\{ymax\\}", atlas_env$bounds[[4]], url)
  
  } else { # Leave url unprocessed if no place holders exist
    url
  }
}
