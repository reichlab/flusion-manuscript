FROM rocker/r-ver:4.4.0

# install OS binaries required by R packages - via rocker-versioned2/scripts/install_tidyverse.sh
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    unixodbc-dev \
    cmake


# install required R packages using renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

ENV RENV_PATHS_LIBRARY renv/library
COPY flusion-manuscript/renv.lock renv.lock
RUN R -e "renv::restore()"

# copy manuscript code and flusight hub files
COPY flusion-manuscript/code /flusion-manuscript/code
COPY flusion-manuscript/manuscript /flusion-manuscript/manuscript
COPY ./flusion /flusion
COPY ./FluSight-forecast-hub /FluSight-forecast-hub

# set working directory
WORKDIR /flusion-manuscript
