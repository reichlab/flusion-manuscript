library(here)
setwd(here::here())

library(hubUtils)
library(scoringutils)

library(readr)
library(dplyr)

source("code/scoring_helpers.R")

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")

# load Flusight-baseline
hub_path <- "../FluSight-forecast-hub"
hub_con <- connect_hub(hub_path)
baseline_forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile",
    model_id == "FluSight-baseline"
  ) |>
  dplyr::collect() |>
  as_model_out_tbl() |>
  dplyr::filter(horizon >= 0,
                reference_date >= "2023-10-14",
                location != "US",
                location != "78")


# load flusion components
hub_path <- "../flusion/submissions-hub"
hub_con <- connect_hub(hub_path)
component_forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile",
    model_id %in% c("UMass-gbq_qr", "UMass-gbq_qr_no_level", "UMass-sarix")
  ) |>
  dplyr::collect() |>
  as_model_out_tbl() |>
  dplyr::filter(horizon >= 0,
                reference_date >= "2023-10-14",
                location != "US",
                location != "78")


# load flusion forecasts -- TODO, update to not realtime
hub_path <- "../FluSight-forecast-hub"
hub_con <- connect_hub(hub_path)
flusion_forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile",
    model_id == "UMass-flusion"
  ) |>
  dplyr::collect() |>
  as_model_out_tbl() |>
  dplyr::filter(horizon >= 0,
                reference_date >= "2023-10-14",
                location != "US",
                location != "78")


forecasts <- dplyr::bind_rows(
  baseline_forecasts,
  component_forecasts,
  flusion_forecasts)

# compute and save score summaries -- all data
by <- list("model",
           c("model", "horizon"),
           c("model", "horizon", "reference_date"))

scores <- compute_scores(forecasts = forecasts,
                         target_data = target_data,
                         by = by,
                         submission_threshold = 0.5)

save_dir <- "artifacts/scores"
if (!dir.exists(save_dir)) {
  dir.create(save_dir, recursive = TRUE)
}

for (i in seq_along(by)) {
  by_str <- paste(by[[i]], collapse = "_")
  readr::write_csv(
    scores[[i]],
    file.path(save_dir, paste0("scores_by_", by_str, "_flusion_components.csv"))
  )
}
