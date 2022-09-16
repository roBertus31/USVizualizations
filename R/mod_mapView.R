#' Module for the map view tab
#' 
#' @import shiny

mod_mapView_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    leaflet::leafletOutput(
      ns("mapView"),
      width = "100%",
      height = "100%"
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
        ns("dataSelect"),
        choices = c("Google Mobility Data"="googleMobility",
                    "USDA Census 2017"="usdaCensus"),
        label = "Data Selection",
        selected = "usdaCensus"
      ),
      uiOutput(
        ns("variableSelect")
      )
    )
  )
}

mod_mapView_server <- function(id){
  
  moduleServer(id, function(input, output, session){
    
    ns <- NS(id)
    
    ##############################################################################
    #            <REACTIVE> select the data set to visualize                     #
    ##############################################################################
    dataSelector <- reactive({
      
      
      
    })
    
    ##############################################################################
    #            <REACTIVE> select the variable to visualize                     #
    ##############################################################################
    varSelector <- reactive({
      
      if(dataSelect=="googleMobility"){
        outputTags <- tagList(
          selectInput(
            id = ns("variableSelection"),
            choices = 
          )
        )
      }
      
    })
    
    ##############################################################################
    #            <OUTPUT>   render variable selection                            #
    ##############################################################################
    output$variableSelect <- renderUI({
      
      
      
    })
    
    
    ##############################################################################
    #            <OUTPUT>   select the variable to visualize                     #
    ##############################################################################
    output$mapView <- leaflet::renderLeaflet(
      NULL
    )
    
  })
  
}
