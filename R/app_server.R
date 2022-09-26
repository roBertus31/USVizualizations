#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  waiter::waiter_hide()
  
  #####################################
  mod_mapView_server(id = "map1", monthly = monthlyData, map = usaSF)
  #####################################
  
  #####################################

}
