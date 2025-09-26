# Base image
FROM rocker/verse:4.1.2

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    make pandoc zlib1g-dev cmake libgdal-dev gdal-bin libgeos-dev \
    libpng-dev libssl-dev libproj-dev libsqlite3-dev libudunits2-dev git && \
    rm -rf /var/lib/apt/lists/*

# Set R options globally
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/ && \
    echo "options(renv.config.pak.enabled = FALSE, \
                  repos = c(CRAN = 'https://cran.rstudio.com/'), \
                  download.file.method = 'libcurl', \
                  Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | \
                  tee /usr/lib/R/etc/Rprofile.site

# Install R packages
RUN R -e 'install.packages("remotes")' && \
    R -e 'remotes::install_version("renv", version = "1.0.3")'

# Copy and restore R environment
COPY renv.lock.prod renv.lock
RUN --mount=type=cache,id=renv-cache,target=/root/.cache/R/renv \
    R -e 'renv::restore()'

# Install application package
COPY USVisualizations_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz", upgrade = "never")' && \
    rm /app.tar.gz

# Expose port and set user
EXPOSE 50000
USER rstudio

# Command to run the Shiny app
CMD R -e "options('shiny.port' = 50000, shiny.host = '0.0.0.0'); \
          library(USVisualizations); USVisualizations::run_app()"
