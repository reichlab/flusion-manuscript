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
