
<!-- README.md is generated from README.Rmd. Please edit that file -->

# USVisualizations

<!-- badges: start -->
<!-- badges: end -->

The goal of USVisualizations is to provide publicly available data to be
visualized through a shiny-app interface using the
<a href="https://leafletjs.com/">leaflet javascript library</a>.

## Installation

### For local PC:

To install this application as a local R-package, use the `remotes` R-package, and the following
command into an R-console:

``` r
remotes::install_github("roBertus31/USVizualizations")
```

Once installed, enter the following command in your R-console session to
start up the application on your local host:

``` r
USVisualizations::run_app()
```

### via Docker:

1.  Make sure that you have docker installed on your PC. You can
    download and install docker
    <a href="https://www.docker.com/products/docker-desktop/">from
    here</a>.
2.  After installing docker, clone this repo
3.  Navigate to the root directory of this project, and open a terminal
    session of your choice (bash, command prompt, powershell, etc.).
4.  Enter the following command to build the docker image. Once started
    it will take several minutes to complete.

<!-- -->

    docker build -f Dockerfile --progress=plain -t usvisualizations:latest .

5.  Once complete, run this command to start the newly created
    container.

<!-- -->

    docker run -d -p 50000:50000 usvisualizations:latest

6.  Finally, go to 127.0.0.1:50000 through a web browser of your choice.

The application is also currently running live via
<a href="https://www.shinyapps.io/">shinyapps.io</a>

<a href="https://tealrobert.shinyapps.io/usvisualizations/" target="_blank">View the application here...</a>
