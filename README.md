# Flusion manuscript

This repository houses code and intermediate outputs related to the Flusion manuscript. It uses data from the [flusion](https://github.com/reichlab/flusion) and [FluSight-forecast-hub](https://github.com/cdcepi/FluSight-forecast-hub/) repositories as inputs. Static snapshots of those data that are used for building the manuscript are available in an S3 Bucket at s3://flusion-manuscript-upstream-data.

## Setup and computational environment

### Docker

We use Docker. To get set up, first ensure that you have Docker [installed](https://docs.docker.com/engine/install/), noting that on a Windows or Mac machine you will want to install Docker Desktop.  To build the Docker image, use the following command, working in the root of the `flusion-manuscript` repository:

```bash
docker build -t flusionmanu .
```

Note that this builds a Docker image that includes static snapshots of the FluSight-forecast-hub repository and the flusion repository, which contain model output files that are used in the analyses for the manuscript.

Now, with `flusion-manuscript` as your working directory, you can use that image to conduct analyses, either using the workflows defined in the `makefile` or with one-off commands as documented in the following sections.

#### Building the manuscript and all dependencies using `make`

The project's `makefile` has been copied into the Docker image, and this can be used to build the manuscript using a reproducible workflow.  The makefile defines four targets which may be useful to someone who wants to build the manuscript:

- `make all` builds both the manuscript and the supplement, including intermediate artifacts with plots and scores.
- `make manuscript` build the manuscript and its dependencies
- `make supplement` builds the supplement and its dependencies
- `make clean` removes the built manuscript and supplement, and all intermediate artifacts with plots and scores. The primary use case of this command is to verify that the entire workflow is reproducible, since the next manuscript build will take some time to run to reproduce those intermediate artifacts.

As an example, the following illustrates how to run `make all` within the container:

```
docker run -it \
	-v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -v ./code:/flusion-manuscript/code \
    flusionmanu make all
```

#### Running one-off commands within the Docker container 

For development purposes, it may be helpful to run individual commands within the Docker container. We provide some examples below.

The following starts up a bash shell:

```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -v ./code:/flusion-manuscript/code \
    flusionmanu bash
```

The following runs one of the R scripts to compute scores:

```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -v ./code:/flusion-manuscript/code \
    flusionmanu Rscript code/compute_scores_joint_training.R
```

The following runs one of the python scripts to make a plot that is saved in `artifacts/figures/data_overview.pdf`:

```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -v ./code:/flusion-manuscript/code \
    flusionmanu python3 code/plot_data.py
```

The following knits the manuscript pdf (note that any updates to the pdf are persisted outside of the container):
```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -v ./code:/flusion-manuscript/code \
    -w /flusion-manuscript/manuscript \
    flusionmanu R -e "knitr::knit2pdf('flusion-manuscript.Rnw', bib_engine='biber')"
```

### Using `renv` without Docker

We have not had good luck with using `renv` to get a stable development environment setup going across different machines, so we recommend using Docker as described above.  But if you want to try your luck, you can try to run the following command in an R session in this project:

```{r}
renv::restore()
```

As of April 2024, the version of `arrow` that is installed by default on macs does not have all of the required functionality. You may need to run the following command to install arrow from source:

```{r}
renv::install("arrow", type = "source", rebuild = TRUE)
```

You will also need to have local clones of the FluSight-forecast-hub and flusion repositories in the same folder as the flusion-manuscript repository.
