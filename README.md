# Flusion manuscript

This repository houses code and intermediate outputs related to the Flusion manuscript.

## Organization


## Setup and computational environment

To build this project, you will need the following supporting repositories to be cloned into the same directory as the `flusion-manuscript` repository:

- [flusion](https://github.com/reichlab/flusion)
- [FluSight-forecast-hub](https://github.com/cdcepi/FluSight-forecast-hub/)

### Docker

We use Docker.  To build the Docker image, use the following command from the parent directory of the `flusion-manuscript` repository. That is, you should be in a directory that contains `flusion-manuscript`, `flusion`, and `FluSight-forecast-hub`.

```bash
docker build -f flusion-manuscript/Dockerfile -t flusionmanu .
```

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

### Using `renv` without Docker

We have not had good luck with using `renv` to get a stable development environment setup going across different machines, so we recommend using Docker as described above.  But if you want to try your luck, you can try to run the following command in an R session in this project:

```{r}
renv::restore()
```

As of April 2024, the version of `arrow` that is installed by default on macs does not have all of the required functionality. You may need to run the following command to install arrow from source:

```{r}
renv::install("arrow", type = "source", rebuild = TRUE)
```
