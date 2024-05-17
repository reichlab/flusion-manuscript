library(here)
setwd(here::here())

library(readr)
library(dplyr)

target_data <- readr::read_csv(
  "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/target-data/target-hospital-admissions.csv")

readr::write_csv(
  target_data,
  "artifacts/target_data.csv")

# collect initially-reported versions of target data
files <- Sys.glob("../flusion/data-raw/influenza-hhs/hhs-????-??-??.csv")
files

initial_target_data <- purrr::map(
  files,
  function(f) {
    f_date <- as.Date(substr(basename(f), 5, 14))
    f_contents <- readr::read_csv(f)
    return(f_contents |> dplyr::slice_max(date, n = 1))
  }) |>
  purrr::list_rbind()

readr::write_csv(
  initial_target_data,
  "artifacts/initial_target_data.csv")
