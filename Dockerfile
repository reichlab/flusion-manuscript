FROM rocker/r-ver:4.4.0

# install OS binaries required by R packages - via rocker-versioned2/scripts/install_tidyverse.sh
# additionally, stuff for rendering tex
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
    cmake \
    awscli \
    texlive-full


# install required R packages using renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

ENV RENV_PATHS_LIBRARY renv/library
COPY ./renv.lock renv.lock
RUN R -e "renv::restore()"

# copy manuscript code and flusight hub files
RUN aws s3 cp s3://flusion-manuscript-upstream-data/FluSight-forecast-hub /FluSight-forecast-hub --no-sign-request --recursive
RUN aws s3 cp s3://flusion-manuscript-upstream-data/flusion /flusion --no-sign-request --recursive
COPY ./code /flusion-manuscript/code

# set working directory
WORKDIR /flusion-manuscript
