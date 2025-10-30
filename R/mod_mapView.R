#' Module for the map view tab
#' 
#' @import shiny
#' @importFrom magrittr %>%
#' @param id Internal shiny parameter
#' @param monthly A \code{list} object containing the aggregated Google data by
#'   year and month.
#' @param map A \code{sf data.frame} with the geometry data needed for the 
#'   leaflet map.

mod_mapView_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    tags$style(
    type = "text/css", 
      ".leaflet-bottom.leaflet-left {
      bottom: 50px;   /* moves legend up by 50px */
      }"
    ),
    leaflet::leafletOutput(
      ns("mapView"),
      width = "100%",
      height = "95vh"
    ),
    DT::dataTableOutput(
      ns("testTable")
    ),
    absolutePanel(
      id = ns("controls"),
      top = 250,
      left = 100,
      width = 250,
      fixed = TRUE,
      draggable = TRUE,
      height = "auto",
      tags$p("This application uses Google's publicly available Covid-19 mobility data reports available through the link below."),
      tags$a(
        "www.google.com/covid19/mobility",
        target = "_blank",
        href = "https://www.google.com/covid19/mobility/"
      ),
      tags$br(),
      tags$a("View Code",
             href = "https://github.com/roBertus31/USVizualizations",
             target = "_blank"),
      tags$br(),
      selectInput(
        ns("yearSelect"),
        label = "Select Year",
        choices = c(2020,2021,2022)
      ),
      selectInput(
        ns("monthSelect"),
        label = "Select Month",
        choices = month.name,
        selected = "February"
      ),
      selectInput(
        ns("variableSelect"),
        label = "Select Data",
        choices = c("Retail & Recreation" = "retail_rec",
                    "Pharmacy & Grocery" = "groc_pharm",
                    "Parks/Outdoors" = "parks",
                    "Mass Transit Use" = "transit",
                    "Work from workplace" = "workplaces",
                    "Work from home" = "residences"),
        selected = "retail_rec"
      ),
      actionButton(ns("infoButton"), "How to use?")
    )
  )
}

mod_mapView_server <- function(id){
  
  moduleServer(id, function(input, output, session){
    
    ns <- NS(id)
    
    waitMap <- waiter::Waiter$new(
      c(ns("mapView")),
      html = busyScreen,
      color = waiter::transparent()
    )
    
    load("./data/monthlyData.Rdata")
    load("./data/USA_geoData.Rdata")
    
    ##############################################################################
    #               <OUTPUT>   Create the leaflet map object                     #
    ##############################################################################
    output$mapView <- leaflet::renderLeaflet({
      
      # create the leaflet output
      leaflet::leaflet() %>% 
        leaflet::addProviderTiles("CartoDB.DarkMatter", group = "Dark", 
                                  options = leaflet::providerTileOptions(noWrap = TRUE)) %>%
        leaflet::addProviderTiles("Esri.WorldImagery", group = "Aerial", 
                                  options = leaflet::providerTileOptions(noWrap = TRUE)) %>%
        leaflet::addProviderTiles("Thunderforest.Transport", group = "Street-map", 
                                  options = leaflet::providerTileOptions(noWrap = TRUE)) %>% 
        leaflet::addLayersControl(
          baseGroups = c("Aerial","Dark", "Street-map")) %>%
        leaflet::setView(lat = 39.8283, lng = -98.5795, zoom =4) %>% 
        leaflet::addLegend(
          position = "bottomleft",
          pal = staticPal,
          values = c(-100, 100),
          opacity = 0.7,
          title = "% Change from Baseline"
        )
        
    })
    
    ##############################################################################
    #            <REACTIVE> Draw the polygon layer for the map                   #
    ##############################################################################
    observe({
      leaflet::leafletProxy("mapView") %>% 
        leaflet::addPolygons(
          data = vizData(), weight = 0.5,
          color = "black", fillOpacity = 0.7,
          fillColor = "grey",
          highlightOptions = leaflet::highlightOptions(
            color = "#DE4968", weight = 1.5,
            bringToFront = T, fillOpacity = 0.5
          ),
          layerId = vizData()$GID_2,
          group = "polygons"
        ) 
    })
    
    ##############################################################################
    #            <REACTIVE> select the date range if applicable                  #
    ##############################################################################
    dataSelector <- reactive({
      
      yearIndex <- which(names(monthlyData)==as.character(input$yearSelect))
      monthIndex <- which(names(monthlyData[[yearIndex]])==input$monthSelect)
      filteredData <- monthlyData[[yearIndex]][[monthIndex]]
      
      return(filteredData)
      
    })
    
    ##############################################################################
    #           <REACTIVE> Merge selected data with the PolygonData              #
    ##############################################################################
    vizData <- reactive({
      
      # merging the processed Google data with the map definitions
      temp <- merge(
        usaSF, dataSelector(),
        by.x = c("NAME_1", "NAME_2"),
        by.y = c("sub_region_1", "sub_region_2"),
        all.x = T,
        duplicateGeoms = T
      )
      return(
        sf::st_as_sf(x = temp)
      )
    })
    
    ##############################################################################
    #        <REACTIVE> create the popup data when a polygon is clicked          #
    ##############################################################################
    
    observe({
      
      #p <- input$mapView_shape_click
      #print(p)
      leaflet::leafletProxy("mapView") %>% leaflet::clearPopups()
      event <- input$mapView_shape_click
      if(is.null(event)){
        return()
      }
      isolate({
        showPopups(inputVar = input$variableSelect, data = vizData(), mapID = event$id, lat = event$lat, lng = event$lng)
      })
      print(event)
      
    })
    
    ##############################################################################
    #                     <REACTIVE> Create the color palette                    #
    ##############################################################################
    
    staticPal <- leaflet::colorNumeric(
      palette = "plasma",
      domain = c(-100, 100),
      na.color = "grey"
    )
    #paletteCreate <- reactive({
      
    #  colorBy <- input$variableSelect
      
    #  leaflet::colorNumeric(palette = "plasma", domain = vizData()[[colorBy]], na.color = "grey")
      
    #})
    
    
    ##############################################################################
    #                         <REACTIVE> Create the legend                       #
    ##############################################################################
    
    #observe({
      
    #  colorBy <- input$variableSelect
      
    #  leaflet::leafletProxy("mapView") %>% 
    #    leaflet::clearControls() %>% 
    #    leaflet::addLegend(
    #      position = "bottomleft",
    #      pal = paletteCreate(),
    #      values = vizData()[[colorBy]],
    #      opacity = 0.7
    #    )
      
    #})
    
    
    ##############################################################################
    #         <OBSERVE>   Change polygon layer based on user inputs              #
    ##############################################################################
    observe({
      
      # user inputs are used to subset the input data.
      varSelected <- input$variableSelect
      visualData <- vizData()[[varSelected]]
      
      # show the css spinner to show that the app is working, and just sitting
      waitMap$show()
      
      # draw and color the polygons based on user input
      leaflet::leafletProxy("mapView") %>% 
        leaflet::clearGroup("polygons") %>%
        leaflet::clearPopups() %>% 
        leaflet::addPolygons(
          data = vizData(), weight = 0.5,
          color = "black", fillOpacity = 0.7,
          fillColor = ~staticPal(visualData),
          highlightOptions = leaflet::highlightOptions(
            color = "#DE4968", weight = 1.5,
            bringToFront = T, fillOpacity = 0.5
          ),
          layerId = vizData()$GID_2
        ) 
      
      # hide the css spinner after the polygons are drawn
      waitMap$hide()
    })
    
    ##############################################################################
    #         <OBSERVE>   Display info modal with user instructions              #
    ##############################################################################
    observeEvent(input$infoButton, {
      
      showModal(
        modalDialog(
          title = "How to Use...",
          tags$div(
            h5("This application allows you interactively view anonymized data from Google's COVID-19 community mobility reports, aggregated to the county level for the United States of America. 
               The data within shows changes in people's movement, relative to their pre-COVID baseline."), 
            br(),
            h5("For example: If a county's change in movement shows -41% in the popup, that means that there was a 41% decrease in movement in that category compared to the pre-COVID baseline movement. Pre-COVID baselines can be visualized for a category by selecting February 2020 as the time point to view."),
            br(),
            h5("There are six categories in these data."),
            HTML(
              "<ul>
                <li>Movement to retail or recreational areas</li>
                <li>Movement to pharmacy & grocery</li>
                <li>Movement to parks or outdoor spaces</li>
                <li>Use of modes of mass transit</li>
                <li>Movement to workplaces for work</li>
                <li>Movement, or lack of movement, for working from home</li>
              </ul>"
            )
          ),
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      
    })
    
  })
}
