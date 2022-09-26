#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  waiter::waiter_hide()
  load("./inst/app/www/data/USA_geoData.Rdata")
  usaSF <- sf::st_as_sf(usaSF, wkt = "geometry", crs = "NAD83")
  load("./inst/app/www/data/monthlyData.Rdata")
  
  #####################################
  mod_mapView_server(id = "map1", monthly = monthlyData, map = usaSF)
  #####################################
  
  #####################################

}
