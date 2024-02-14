library(here)
setwd(here::here())

library(readr)

target_data <- readr::read_csv(
  "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/target-data/target-hospital-admissions.csv")

readr::write_csv(
  target_data,
  "artifacts/target_data.csv")
