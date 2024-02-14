add_model_anon <- function(df) {
  dplyr::mutate(
    df,
    model_anon = dplyr::case_when(
      model == "UMass-flusion" ~ "Flusion",
      model == "FluSight-ensemble" ~ "FluSight-ensemble_median",
      model == "FluSight-lop_norm" ~ "FluSight-ensemble_pool",
      model == "FluSight-baseline" ~ "Baseline-flat",
      model == "UMass-trends_ensemble" ~ "Baseline-trend",
      TRUE ~ "Other"
    ),
    is_other_model = (model_anon == "Other")
  )
}


add_model_anon <- function(df, highlighted_models = NULL) {
  dplyr::mutate(
    df,
    model_anon = ifelse(
      model %in% names(highlighted_models),
      highlighted_models[model],
      "Other"
    ),
    is_other_model = (model_anon == "Other")
  )
}
