showPopups <- function(inputVar, data, mapID, lat, lng){
  
  selectedCounty <- data[data$GID_2==mapID,]
  
  if(inputVar == "retail_rec"){
    colSelect <- selectedCounty$retail_rec
  }
  if(inputVar == "groc_pharm"){
    colSelect <- selectedCounty$groc_pharm
  }
  if(inputVar == "parks"){
    colSelect <- selectedCounty$parks
  }
  if(inputVar == "transit"){
    colSelect <- selectedCounty$transit
  }
  if(inputVar == "workplaces"){
    colSelect <- selectedCounty$workplaces
  }
  if(inputVar == "residences"){
    colSelect <- selectedCounty$residences
  }
  
  content <- as.character(
    htmltools::tagList(
      paste( "County: ", selectedCounty$NAME_2, sep = ""), tags$br(),
      paste("State: ", selectedCounty$NAME_1, sep = ""), tags$br(),
      tags$strong(paste("Percent Change: ", colSelect, sep ="")), 
      )
    )
  
  leaflet::leafletProxy("mapView") %>% leaflet::addPopups(lng = lng, lat = lat, popup = content)
}

