library(here)
setwd(here::here())

library(hubData)
library(scoringutils)

library(readr)
library(dplyr)

source("code/scoring_helpers.R")

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")
initial_target_data <- readr::read_csv("artifacts/initial_target_data.csv")
target_data_without_revisions <- target_data |>
  dplyr::left_join(
    initial_target_data |>
      dplyr::rename(initial_value = inc),
    by = c("location", "date")
  ) |>
  dplyr::mutate(
    revision_size = abs(value - initial_value),
    revision_prop = revision_size / (value + 1),
    revision_prop2 = revision_size / (initial_value + 1)
  ) |>
  dplyr::filter(revision_size < 10)

hub_path <- "../FluSight-forecast-hub"
hub_con <- connect_hub(hub_path)
forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile"
  ) |>
  dplyr::collect() |>
  as_model_out_tbl() |>
  dplyr::filter(horizon >= 0,
                reference_date >= "2023-10-14",
                location != "US",
                location != "78",
                model_id != "FluSight-lop_norm")

# compute and save score summaries -- all data
save_dir <- "artifacts/scores"
if (!dir.exists(save_dir)) {
  dir.create(save_dir, recursive = TRUE)
}

by <- list("model",
           c("model", "horizon"),
           c("model", "horizon", "reference_date"))

for (target_data_spec in c("all", "without_revisions")) {
  if (target_data_spec == "all") {
    td <- target_data
    file_name_add <- ""
  } else {
    td <- target_data_without_revisions
    file_name_add <- "_without_revisions"
  }

  scores <- compute_scores(forecasts = forecasts,
                           target_data = td,
                           by = by,
                           submission_threshold = 2 / 3)

  for (i in seq_along(by)) {
    by_str <- paste(by[[i]], collapse = "_")
    readr::write_csv(
      scores[[i]],
      file.path(
        save_dir,
        paste0("scores_by_", by_str, "_flusight_all", file_name_add, ".csv")
      )
    )
  }
}
