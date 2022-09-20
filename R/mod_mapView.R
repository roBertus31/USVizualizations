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
      )
    )
  )
}

mod_mapView_server <- function(id, monthly, map){
  
  moduleServer(id, function(input, output, session){
    
    ns <- NS(id)
    
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
    #        <REACTIVE> Merge the selected google data with the geo data         #
    ##############################################################################
    
    popupValues <- reactive({
      
      popupValues <- as.data.frame(temp[,c(15:20)])
      return(popupValues %>% dplyr::select(input$varSelect))
      
    })
    
    ##############################################################################
    #           <REACTIVE> Create the color palette for visual                   #
    ##############################################################################
    
    paletteCreate <- reactive({
      
      leaflet::colorNumeric(palette = "plasma", domain = c(-90,300), na.color = "grey")
      
    })
    
    ##############################################################################
    #               <OUTPUT>   Create the leaflet map object                     #
    ##############################################################################
    output$mapView <- leaflet::renderLeaflet({
      
      # create the leaflet output
      leaflet::leaflet() %>% 
        leaflet::addProviderTiles("CartoDB.DarkMatter", group = "Dark") %>%
        leaflet::addProviderTiles("Esri.WorldImagery", group = "Aerial") %>%
        leaflet::addProviderTiles("CartoDB.Positron", group = "Greyscale") %>% 
        leaflet::addLayersControl(
          baseGroups = c("Dark","Aerial", "Greyscale")) %>%
        leaflet::setView(lat = 39.8283, lng = -98.5795, zoom =4)
    })
    
    
    ##############################################################################
    #         <OBSERVE>   Change polygon layer based on user inputs              #
    ##############################################################################
    observe({
      
      # merging the processed Google data with the map definitions
      temp <- sp::merge(
        USA, dataSelector(),
        by.x = c("NAME_1", "NAME_2"),
        by.y = c("sub_region_1", "sub_region_2"),
        all.x = T,
        duplicateGeoms = T
      )
      
      # create the legend color palette
      varIndex <- which(colnames(temp@data)==input$varSelect)
      
      curPalette <- leaflet::colorNumeric(palette = "plasma", domain = c(-90,300), na.color = "grey")
      
      popUps <- paste("County: ", temp$NAME_2, "<br>",
                      "State: ", temp$NAME_1, "<br>",
                      "<strong>Percent Change: ", popupValues(), "</strong>", sep = "")
      
      
      # draw and color the polygons based on user input
      leaflet::leafletProxy("mapView", data = temp) %>% 
        leaflet::addPolygons(
          data = temp, weight = 0.5,
          color = "black", fillOpacity = 0.7,
          label = popUps,
          highlightOptions = leaflet::highlightOptions(
            color = "#DE4968", weight = 1.5,
            bringToFront = T, fillOpacity = 0.5
          )
        ) 
      
    })
    
    
  })
}
