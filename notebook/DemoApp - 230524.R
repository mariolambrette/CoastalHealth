## Demo Shiny App 23/05/24

un <- "ml673"
#un <- "mjw205"

library(leaflet)
library(shiny)
library(shinyjs)
library(dplyr)
library(RSQLite)
library(reactable)
library(ggplot2)
library(plotly)


## Source required functions ----
source(paste0("C:/Users/", un, "/University of Exeter/Exe Atlas - Documents/sw/InteractiveMap/Notes_Examples/leafletMapping/BaseMap_ll.R"))
source(paste0("C:/Users/", un, "/University of Exeter/Exe Atlas - Documents/sw/InteractiveMap/Notes_Examples/leafletMapping/PolyDataDisplay_ll.R"))


## Create database connection ----
con_ll <<- CreateConnection_ll(un)


## Shiny functions ----
ui <- shiny::fluidPage(
  useShinyjs(),

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
          font-size: 14px; /*Set default font size */
        }
        .header-font {
          font-size: 22px !important; font-weight: 600 !important; /* Override font size for specific elements */
        }
      ")
    )
  ),
  sidebarLayout(
    mainPanel(
      leafletOutput("map", width = "100%", height = "100%")
    ),
    sidebarPanel(
      class = "sidebar",
      width = 4.8,  # Adjust this value to make the sidebar wider
      div(
        "Layer Selection",
        class = "header-font"
      ),
      div(
        class = 'mng-select',
        style = "margin-top: 24px; text-align: left; padding-left: 20px;",
        uiOutput('mng_layer_select_ui')
      ),
      div(
        class = 'dat-select',
        style = "margin-top: 24px; text-align: left; padding-left: 20px;",
        uiOutput('dat_layer_select_ui')
      ),
      div(
        "Subcatchment Data",
        class = "header-font"
      ),
      div(
        class = 'poly-summary',
        reactableOutput("poly_summary")
      ),
      div(
        class = 'details',
        plotlyOutput('details')
      )
    )
  )
)

server <- function(session, input, output){

    # Read in layer index file to provide dropdown menu of plotting options
    SHP_index <- tbl(con_ll, 'SHP_lookup') %>%
      filter(!(sql('SUBSTR(SHP_name, INSTR(SHP_name, "SPA"), 3) COLLATE BINARY = "SPA"'))) %>%
      collect()

    # Extract list of layers for the user to choose from
    layers <- SHP_index$SHP_name %>%
      as.list()
    layers <- c("none", layers) # Add a null option to show no additional layers
    names(layers) <- c("None", SHP_index$disp_name)

    # Load in polygon data and lookup table
    poly_data <- tbl(con_ll, 'POLY_data' ) %>%
      collect()
    poly_lu <- tbl(con_ll, 'POLY_lookup') %>%
      collect()

    # Management layer select drop down menu
    output$mng_layer_select_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(
        inputId = 'mng_layer',
        label = 'Select Management Type:',
        choices = layers[grepl('MNG', layers)],
        options = list(
          `none-selected-text` = "No selection",
          `live-search` = TRUE,
          `actions-box` = TRUE,  # Enable actions box to provide "Deselect All" functionality
          `deselect-all-text` = "Deselect All"
        ),
        multiple = FALSE  # Single selection only
      )
    })

    # Data layer drop down menu (allows multiple selections to be made so that multiple data
    # layers can be displayed at the same time)
    output$dat_layer_select_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(
        inputId = 'dat_layer',
        label = 'Select Data Layer: ',
        choices = layers[grepl('DAT', layers)],
        options = list(
          `actions-box` = FALSE,
          `deselect-all-text` = "Deselect All",
          `none-selected-text` = "No selection"
        ),
        multiple = TRUE
      )
    })

    # Leaflet base map - contains an empty pane for management layers (mng_layers)
    output$map <- renderLeaflet(
      BaseMap_ll()
    )

    # Reactively add management layers based on selection
    observe({
      lyr <- input$mng_layer

      leafletProxy("map") %>%
        clearGroup("MNG")

      # Create and execute plotting command based on the selected layer
      if(!is.null(lyr)){
        cmd <- AddLayers_ll(add_layers = lyr)
        eval(parse(text = cmd))
      }
    })

    # Reactively add data layers based on selection
    observe({
      lyrs <- input$dat_layer

      leafletProxy("map") %>%
        clearGroup('DAT')

      # Get the plotting command for each selected layer and execute it
      if(length(lyrs) > 0){
        sapply(
          lyrs,
          function(lyr){
            cmd <- AddLayers_ll(add_layers = lyr)
            eval(parse(text = cmd))
          }
        )
      }
    })

    # Observe polygon clicks
    observeEvent(input$map_shape_click, {

      polyID <<- input$map_shape_click["id"] %>%
        as.numeric()

      print(polyID)

      # Highlight clicked polygon & upstream and downstream
      toHighlight <- HighlightPolys_ll(selectID = polyID)

      leafletProxy("map") %>%
        clearGroup("highlighted") %>%
        addPolygons(
          data = toHighlight,
          color = NA,
          weight = 0,
          opacity = 1,
          fill = T,
          fillOpacity = 1,
          fillColor = toHighlight$colour,
          group = 'highlighted',
          options = pathOptions(pane = "highlight_polys",
                                clickable = F)
        )

      # Create summary table to be rendered in UI
      # Filter polygon data to selected polygon
      data <- poly_data %>%
        filter(ID == polyID)

      # Create template df for rendered output table
      tbl_out <- tibble::tibble(
        `Water body`          = if_else(is.na(data$wb_name), 'NA', data$wb_name),
        `Water body ID`       = if_else(is.na(data$wb_id), 'NA', data$wb_id),
        `Subcatchment area`   = round(data$shp_area / 1000000, digits = 2) %>%
          paste0(., ' km2'),
        `Management areas`    = MAs_list(polyID, data),
        `Dominant land cover` = DominantLC(polyID, data),
        `Priority species`    = KS_list(polyID, data),
        `Continuous Sewage Discharges` = CSD(polyID)
      ) %>%
        mutate_all(as.character()) %>%
        t() %>%
        as.data.frame() %>%
        tibble::rownames_to_column(var = 'type') %>%
        rename(value = V1) %>%
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

    # Observe changes in show details row selection and display additional
    # data accordingly
    observeEvent(input$show_details, {
      #print(input$show_details)

      row_ind <- input$show_details$index

      if(row_ind == 5){ # land cover
        output$details <- renderPlotly(
          DetailsLC(
            polyID,
            poly_row = tbl(con_ll, 'POLY_data' ) %>%
              collect() %>%
              filter(ID == polyID))
        )
      }



    })

}

shiny::shinyApp(
  ui,
  server
)

