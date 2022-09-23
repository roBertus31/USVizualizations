#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinyjs
#' @noRd
app_ui <- function(request) {
  shiny::fluidPage(
    
    shinyjs::useShinyjs(),
    waiter::useWaiter(),
    waiter::waiterShowOnLoad(html = startUpScreen),
    
    theme = bslib_base_theme,
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    
    shiny::navbarPage(
      title = "US Visualizations",
      shiny::tabPanel(
        "Map View",
        ###########################
        mod_mapView_ui(id = "map1")
        ###########################
      )
    )
    
  )
}



#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'USVisualizations'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}
