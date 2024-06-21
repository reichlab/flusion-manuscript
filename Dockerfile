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

RUN apt-get update && apt-get install -y --no-install-recommends git

# install required R packages using renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

ENV RENV_PATHS_LIBRARY renv/library
COPY ./renv.lock renv.lock
RUN R -e "renv::restore()"

# get copies of hub submission files and other data
RUN aws s3 cp s3://flusion-manuscript-upstream-data/FluSight-forecast-hub /FluSight-forecast-hub --no-sign-request --recursive
RUN aws s3 cp s3://flusion-manuscript-upstream-data/flusion /flusion --no-sign-request --recursive

# install python and python dependencies
# note: this is placed here because one dependency is from the flusion repo which
# was pulled in from an S3 bucket just above
RUN apt-get update && apt-get install -y python3-pip
RUN python3 -m pip install --upgrade pip
RUN pip3 install 'numpy==1.26.4' 'pandas==1.5.3' 'scipy==1.11.3' \
                 'matplotlib==3.8.4' 'pytest==7.4.0' 'seaborn==0.12.2' \
                 'scikit-learn==1.2.2' 'pymmwr==0.2.2' 'setuptools==62.1.0'
RUN pip3 install git+https://github.com/reichlab/timeseriesutils.git@4019ee40270d28788165fa36d61bbe5b78bb5ef4
RUN pip3 install /flusion/code/data-pipeline

# set working directory
WORKDIR /flusion-manuscript
