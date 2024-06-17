# Flusion manuscript

This repository houses code and intermediate outputs related to the Flusion manuscript. It uses data from the [flusion](https://github.com/reichlab/flusion) and [FluSight-forecast-hub](https://github.com/cdcepi/FluSight-forecast-hub/) repositories as inputs. Static snapshots of those data that are used for building the manuscript are available in an S3 Bucket at s3://flusion-manuscript-upstream-data.

## Setup and computational environment

### Docker

We use Docker. To get set up, first ensure that you have Docker [installed](https://docs.docker.com/engine/install/), noting that on a Windows or Mac machine you will want to install Docker Desktop.  To build the Docker image, use the following command, working in the root of the `flusion-manuscript` repository:

```bash
docker build -t flusionmanu .
```

Note that this builds a Docker image that includes static snapshots of the FluSight-forecast-hub repository and the flusion repository, which contain model output files that are used in the analyses for the manuscript.

Now, with `flusion-manuscript` as your working directory, you can use that image to conduct analyses.

The following starts up a bash shell:

```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    flusionmanu bash
```

The following runs one of the R scripts to compute scores:

```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    flusionmanu Rscript code/compute_scores_joint_training.R
```

The following knits the manuscript pdf (note that any updates to the pdf are persisted outside of the container):
```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -w /flusion-manuscript/manuscript \
    flusionmanu R -e "knitr::knit2pdf('flusion-manuscript.Rnw')"
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
