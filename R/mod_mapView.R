#' Module for the map view tab
#' 
#' @import shiny
#' @importFrom magrittr %>%

mod_mapView_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
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
      top = 75,
      left = 55,
      width = 250,
      fixed = TRUE,
      draggable = TRUE,
      height = "auto",
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
                    "Work from work" = "workplaces",
                    "At home" = "residences"),
        selected = "retail_rec"
      )
    )
  )
}

mod_mapView_server <- function(id, monthly, map){
  
  moduleServer(id, function(input, output, session){
    
    ns <- NS(id)
    
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
        leaflet::addProviderTiles("CartoDB.Positron", group = "Greyscale", 
                                  options = leaflet::providerTileOptions(noWrap = TRUE)) %>% 
        leaflet::addLayersControl(
          baseGroups = c("Aerial","Dark", "Greyscale")) %>%
        leaflet::setView(lat = 39.8283, lng = -98.5795, zoom =4)
    })
    
    ##############################################################################
    #            <REACTIVE> select the date range if applicable                  #
    ##############################################################################
    dataSelector <- reactive({
      
      yearIndex <- which(names(monthly)==as.character(input$yearSelect))
      monthIndex <- which(names(monthly[[yearIndex]])==input$monthSelect)
      filteredData <- monthly[[yearIndex]][[monthIndex]]
      
      return(filteredData)
      
    })
    
    ##############################################################################
    #           <REACTIVE> Merge selected data with the PolygonData              #
    ##############################################################################
    vizData <- reactive({
      
      # merging the processed Google data with the map definitions
      temp <- sp::merge(
        usaSF, dataSelector(),
        by.x = c("NAME_1", "NAME_2"),
        by.y = c("sub_region_1", "sub_region_2"),
        all.x = T,
        duplicateGeoms = T
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
    
    paletteCreate <- reactive({
      
      colorBy <- input$variableSelect
      
      leaflet::colorNumeric(palette = "plasma", domain = vizData()[[colorBy]], na.color = "grey")
      
    })
    
    ##############################################################################
    #                         <REACTIVE> Create the legend                       #
    ##############################################################################
    
    observe({
      
      colorBy <- input$variableSelect
      
      leaflet::leafletProxy("mapView") %>% 
        leaflet::clearControls() %>% 
        leaflet::addLegend(
          position = "bottomleft",
          pal = paletteCreate(),
          values = vizData()[[colorBy]],
          opacity = 0.7
        )
      
    })
    
    
    ##############################################################################
    #         <OBSERVE>   Change polygon layer based on user inputs              #
    ##############################################################################
    observe({
      
      varSelected <- input$variableSelect
      visualData <- vizData()[[varSelected]]
      
      
      # draw and color the polygons based on user input
      leaflet::leafletProxy("mapView") %>% 
        leaflet::clearShapes() %>% 
        leaflet::addPolygons(
          data = vizData(), weight = 0.5,
          color = "black", fillOpacity = 0.7,
          fillColor = ~paletteCreate()(visualData),
          highlightOptions = leaflet::highlightOptions(
            color = "#DE4968", weight = 1.5,
            bringToFront = T, fillOpacity = 0.5
          ),
          layerId = vizData()$GID_2
        ) 
      
    })
    
    
  })
}
