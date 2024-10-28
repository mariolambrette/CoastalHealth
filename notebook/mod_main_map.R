#' main_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList fluidPage sidebarLayout mainPanel sidebarPanel
#' @importFrom shinyjs useShinyjs
#' @importFrom htmltools div
#' @importFrom leaflet leafletOutput
#' @importFrom reactable reactableOutput
#' @importFrom plotly plotlyOutput

mod_main_map_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    shiny::fluidPage(
      shinyjs::useShinyjs(),
      
      tags$head(
        tags$style(
          HTML("
            #map {
              height: 100vh !important;
            }
            .sidebar {
              height: 100vh;
              overflow-y: auto;
            }
            body {
              font-size: 14px; /* Set default font size */
            }
            .header-font {
              font-size: 22px !important;
              font-weight: 600 !important; /* Override font size for specific elements */
            }
            /* Style the quit button */
            .quit-btn {
              position: fixed;
              bottom: 20px;
              right: 20px;
              z-index: 9999; /* Ensure it stays on top of other elements */
            }
          ")
        ),
        tags$link(rel = "stylesheet", href = "https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"),
        tags$script(src = "https://unpkg.com/leaflet@1.7.1/dist/leaflet.js")
      ),
      shiny::sidebarLayout(
        shiny::mainPanel(
          leaflet::leafletOutput(ns("basemap"), width = "100%", height = "100vh")
        ),
        shiny::sidebarPanel(
           class = "sidebar",
           width = 4.8,  # Adjust this value to change sidebar width
           htmltools::div(
             "Layer Selection",
             class = "header-font"
           ),
           htmltools::div(
             class = "mng-select",
             style = "margin-top: 24px; text-align: left; padding-left: 20px;",
             shiny::uiOutput(ns("mng_layer_select_ui"))
           ),
           htmltools::div(
             class = "dat-select",
             style = "margin-top: 24px; text-align: left; padding-left: 20px;",
             shiny::uiOutput(ns("dat_layer_select_ui"))
           ),
           htmltools::div(
             "Subcatchment Data",
             class = "header-font"
           ),
           htmltools::div(
             class = "poly-summary",
             reactable::reactableOutput(ns("poly_summary"))
           ),
           htmltools::div(
             class = "details",
             plotly::plotlyOutput(ns("details"))
           )
         )
      ),
      # Add the quit button at the bottom-right corner
      actionButton(ns("quitApp"), "Quit", class = "btn btn-danger quit-btn")
    )
  )
}
    
#' main_map Server Functions
#'
#' @noRd
#' 
#' @importFrom magrittr `%>%`
#' @importFrom dplyr filter tbl collect sql mutate_all if_else rename
#' @importFrom tibble tibble rownames_to_column
#' @importFrom shinyWidgets pickerInput
#' @importFrom leaflet renderLeaflet leafletProxy clearGroup addPolygons pathOptions
#' @importFrom shiny moduleServer renderUI observe observeEvent
#' @importFrom reactable renderReactable reactable colDef reactableTheme
#' @importFrom reactablefmtr cell_style
#' @importFrom htmltools tags
#' @importFrom htmlwidgets JS

mod_main_map_server <- function(id){
  shiny::moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Ensure that the database connection is ready before rendering the map
    req(atlas_env$connection.ready())
    
    # Read in layer index file to provide drop down menu of plotting options
    SHP_index <- dplyr::tbl(atlas_env$con, "SHP_lookup") %>%
      dplyr::filter(!(dplyr::sql('SUBSTR(SHP_name, INSTR(SHP_name, "SPA"), 3) COLLATE BINARY = "SPA"'))) %>%
      dplyr::collect()
    
    # Extract list of layers for the user to choose from
    layers <- SHP_index$SHP_name %>%
      as.list()
    layers <- c("none", layers) # Add a null option to show no additional layers
    names(layers) <- c("None", SHP_index$disp_name)
    
    # Load in polygon data and lookup table
    poly_data <- dplyr::tbl(atlas_env$con, "POLY_data" ) %>%
      dplyr::collect()
    poly_lu <- dplyr::tbl(atlas_env$con, "POLY_lookup") %>%
      dplyr::collect()
    
    # Management layer select drop down menu
    output$mng_layer_select_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(
        inputId = ns("mng_layer"),
        label = "Select Management Type:",
        choices = layers[grepl("MNG", layers)],
        options = list(
          `none-selected-text` = "No selection",
          `live-search` = TRUE,
          `actions-box` = TRUE,  # Enable actions box to provide "Deselect All" functionality
          `deselect-all-text` = "Deselect All"
        ),
        multiple = TRUE  # Allow multiple selection
      )
    })
    
    # Data layer drop down menu (allows multiple selections to be made so that multiple data
    # layers can be displayed at the same time)
    output$dat_layer_select_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(
        inputId = ns("dat_layer"),
        label = "Select Data Layer: ",
        choices = layers[grepl("DAT", layers)],
        options = list(
          `actions-box` = FALSE,
          `deselect-all-text` = "Deselect All",
          `none-selected-text` = "No selection"
        ),
        multiple = TRUE
      )
    })
    
    # Leaflet base map - contains empty panes for additional data layers
    output$basemap <- leaflet::renderLeaflet({
      BaseMap()
    })

    # Reactively add management layers based on selection
    shiny::observe({
      mng_lyrs <- input$mng_layer

      leaflet::leafletProxy(ns("basemap")) %>%
        leaflet::clearGroup("MNG")

      # Create and execute plotting command based on the selected layer
      if (!is.null(input$mng_layer)) {
        sapply(
          mng_lyrs,
          function(lyr){
            cmd <- AddLayers(add_layers = lyr)
            eval(parse(text = cmd))
          }
        )
      }
    })

    # Reactively add data layers based on selection
    shiny::observe({
      dat_lyrs <- input$dat_layer

      leaflet::leafletProxy(ns("basemap")) %>%
        leaflet::clearGroup("DAT")

      # Get the plotting command for each selected layer and execute it
      if (length(dat_lyrs) > 0) {
        sapply(
          dat_lyrs,
          function(lyr){
            cmd <- AddLayers(add_layers = lyr)
            eval(parse(text = cmd))
          }
        )
      }
    })
    
    # Observe polygon clicks
    shiny::observeEvent(input$basemap_shape_click, {
      
      # Extract ID of clicked polygon
      atlas_env$polyID <- input$basemap_shape_click["id"] %>%
        as.numeric()
      
      # Highlight clicked polygon & upstream and downstream
      toHighlight <- HighlightPolys(selectID = atlas_env$polyID)
      
      leaflet::leafletProxy(ns("basemap")) %>%
        leaflet::clearGroup("highlighted") %>%
        leaflet::addPolygons(
          data = toHighlight,
          color = NA,
          weight = 0,
          opacity = 1,
          fill = T,
          fillOpacity = 1,
          fillColor = toHighlight$colour,
          group = 'highlighted',
          options = leaflet::pathOptions(pane = "highlight_polys",
                                         clickable = F)
        )
      
      ## Create a summary table to be rendered in the UI
      # Filter polygon data to selected polygon
      data <- poly_data %>%
        dplyr::filter(ID == atlas_env$polyID)
      
      # Create template df for rendered output table
      tbl_out <- tibble::tibble(
        `Water body`          = dplyr::if_else(is.na(data$wb_name), 'NA', data$wb_name),
        `Water body ID`       = dplyr::if_else(is.na(data$wb_id), 'NA', data$wb_id),
        `Subcatchment area`   = round(data$shp_area / 1000000, digits = 2) %>%
          paste0(., ' km2'),
        `Management areas`    = MAs_list(data),
        `Dominant land cover` = DominantLC(data),
        `Priority species`    = KS_list(data),
        `Continuous Sewage Discharges` = CSD()
      ) %>%
        dplyr::mutate_all(as.character()) %>%
        t() %>%
        as.data.frame() %>%
        tibble::rownames_to_column(var = 'type') %>%
        dplyr::rename(value = V1) %>%
        cbind(., details = NA)
      
      
      # Create reactable object to be rendered in UI
      output$poly_summary <- reactable::renderReactable(
        reactable::reactable(
          tbl_out,
          columns = list(
            type = reactable::colDef(
              width = 115,  # Set the width for the first column
              style = reactablefmtr::cell_style(background_color = '#698EDF',
                                                font_weight = 'normal')
            ),
            # Adjust the width of the 'value' column (Column 2)
            value = reactable::colDef(
              width = 370  # Set the width for the second column (wider)
            ),
            # Render a 'show details' button in the last column (Column 3)
            details = reactable::colDef(
              name = '',
              sortable = FALSE,
              width = 90,  # Set the width for the third column
              cell = function() htmltools::tags$button('Show details'),
              align = 'right'
            )
          ),
          onClick = htmlwidgets::JS("function(rowInfo, column) {
              // Only handle click events on the 'details' column
              if (column.id !== 'details') {
                return
              }

              // Send the click event to Shiny, which will be available in input$show_details
              // Note that the row index starts at 0 in JavaScript, so we add 1
              if (window.Shiny) {
                Shiny.setInputValue('show_details', { index: rowInfo.index + 1 }, { priority: 'event' })
              }
            }"),
          wrap = TRUE, # wrap text in cells
          theme = reactable::reactableTheme(
            headerStyle = list(
              display = "none"
            ),
            borderWidth = 0
          )
        )
      )
      
      # Reset 'show_details' row to NULL
      session$sendInputMessage("show_details", 'none')
    })
    
    # Quit app when button is pressed
    shiny::observeEvent(input$quitApp, {
      QuitApp()
    })
  })
}
    
## To be copied in the UI
# mod_main_map_ui("main_map_1")
    
## To be copied in the server
# mod_main_map_server("main_map_1")
