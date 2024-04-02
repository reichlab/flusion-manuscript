# Flusion manuscript

This repository houses code and intermediate outputs related to the Flusion manuscript.

## Organization


## Setup and computational environment

To build this project, you will need the following supporting repositories to be cloned into the same directory as the `flusion-manuscript` repository:

- [flusion](https://github.com/reichlab/flusion)
- [FluSight-forecast-hub](https://github.com/cdcepi/FluSight-forecast-hub/)

We use `renv` for R environment management. To set up your R environment, run the following command in an R session in this project:

```{r}
renv::restore()
```

As of April 2024, the version of `arrow` that is installed by default on macs does not have all of the required functionality. You may need to run the following command to install arrow from source:

```{r}
renv::install("arrow", type = "source", rebuild = TRUE)
```
