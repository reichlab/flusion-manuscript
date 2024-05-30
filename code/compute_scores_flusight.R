library(here)
setwd(here::here())

library(hubData)
library(scoringutils)

library(readr)
library(dplyr)

source("code/scoring_helpers.R")

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")
ref_date_loc_revised <- get_ref_date_loc_revised()

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
                target_end_date <= "2024-04-27",
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

for (to_score in c("all", "without_revisions")) {
  if (to_score == "all") {
    forecasts_to_score <- forecasts
    file_name_add <- ""
  } else {
    forecasts_to_score <- forecasts |>
      dplyr::anti_join(ref_date_loc_revised,
                       by = c("reference_date", "location"))
    file_name_add <- "_without_revisions"
  }

  scores <- compute_scores(forecasts = forecasts_to_score,
                           target_data = target_data,
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
