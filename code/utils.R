add_model_anon <- function(df, highlighted_models = NULL,
                           number_others = FALSE) {
  df <- dplyr::mutate(
    df,
    model_anon = ifelse(
      model %in% names(highlighted_models),
      highlighted_models[model],
      "Other"
    ),
    is_other_model = (model_anon == "Other")
  )

  if (number_others) {
    num_others <- sum(df$model_anon == "Other")
    df$model_anon[df$model_anon == "Other"] <-
      paste0("Other Model \\#", seq_len(num_others))
  }

  return(df)
}
