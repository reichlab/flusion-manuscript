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

#' load forecasts
#'
#' @param hub_path string specifying path to hub directory structure
#' @param models character vector of model names to load
#' @param adjust_horizon boolean indicating whether an adjustment to the
#' horizon is required. This should be set to TRUE when loading flusion
#' component models. For those models, the saved model output files have
#' horizons relative to the last observed data rather than the reference date
#'
#' @return data frame with model outputs
load_forecasts <- function(hub_path, models, adjust_horizon = FALSE) {
  hub_con <- connect_hub(hub_path)

  forecasts <- hub_con |>
    dplyr::filter(
      output_type == "quantile",
      model_id %in% models,
      reference_date >= "2023-10-14",
      target_end_date <= "2024-04-27",
      location != "US",
      location != "78"
    ) |>
    dplyr::collect() |>
    as_model_out_tbl()

  # note: component model horizons are off by 1 due to different accounting in
  # model fitting and hub formats: is horizon relative to last observation or
  # the reference date?  We adjust here to standardize on hub format
  if (adjust_horizon) {
    forecasts <- forecasts %>%
      dplyr::filter(horizon < 3) %>%
      dplyr::mutate(horizon = horizon + 1)
  }

  forecasts <- forecasts |>
    dplyr::filter(horizon >= 0)

  return(forecasts)
}

# load Flusight-baseline
baseline_forecasts <- load_forecasts(
  hub_path = "../FluSight-forecast-hub",
  models = "FluSight-baseline"
)


# load flusion components
models <- c("UMass-gbq_qr", "UMass-gbq_qr_no_reporting_adj",
            "UMass-gbq_qr_no_transform")

# retrospective predictions exist for dates where a model was not fit in real
# time or there was a bug affecting its real-time predictions
component_forecasts_retrospective <- load_forecasts(
  "../flusion/retrospective-hub", models,
  adjust_horizon = TRUE
)

# load forecasts from submissions-hub
component_forecasts_submissions <- load_forecasts(
  "../flusion/submissions-hub", models,
  adjust_horizon = TRUE
)

# combine, keeping everything from retrospective fits and
# anything from submissions hub that was not replaced by a retrospective fit
component_forecasts <- dplyr::bind_rows(
  component_forecasts_retrospective,
  anti_join(
    component_forecasts_submissions,
    component_forecasts_retrospective,
    by = c("model_id", "location", "reference_date", "horizon")
  )
)

forecasts <- dplyr::bind_rows(
  baseline_forecasts,
  component_forecasts
)

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
                           submission_threshold = 0.5)

  for (i in seq_along(by)) {
    by_str <- paste(by[[i]], collapse = "_")
    readr::write_csv(
      scores[[i]],
      file.path(
        save_dir,
        paste0("scores_by_", by_str, "_flusion_data_adj", file_name_add, ".csv")
      )
    )
  }
}
