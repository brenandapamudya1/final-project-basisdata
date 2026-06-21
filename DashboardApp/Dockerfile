FROM rocker/shiny-verse:latest

# Install system dependencies untuk RMariaDB
RUN apt-get update && apt-get install -y \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c( \
    'bs4Dash', \
    'DBI', \
    'RMariaDB', \
    'plotly', \
    'DT', \
    'dplyr', \
    'lubridate', \
    'scales', \
    'shinycssloaders', \
    'shinyjs' \
  ), repos = 'https://cran.rstudio.com/', quiet = TRUE)"

# Copy app ke direktori Shiny server
COPY . /srv/shiny-server/dashboard/

# Hapus default Shiny apps (opsional)
RUN rm -rf /srv/shiny-server/sample-apps

EXPOSE 3838
