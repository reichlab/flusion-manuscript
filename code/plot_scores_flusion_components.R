library(here)
setwd(here::here())

library(readr)
library(dplyr)
library(ggplot2)

source("code/utils.R")

scores <- readr::read_csv(
  "artifacts/scores/scores_by_model_horizon_reference_date_flusion_components.csv") |>
  dplyr::mutate(
    model = dplyr::case_when(
      model == "UMass-flusion" ~ "Flusion",
      model == "FluSight-ensemble" ~ "FluSight-ensemble_median",
      model == "FluSight-baseline" ~ "Baseline-level",
      model == "UMass-trends_ensemble" ~ "Baseline-trend",
      TRUE ~ "Other"
    ),
    is_other_model = (model_anon == "Other")
  )

model_colors <- c("Other" = "grey",
                  "Flusion" = "orange",
                  "FluSight-ensemble_median" = "cornflowerblue",
                  "FluSight-ensemble_pool" = "purple",
                  "Baseline-trend" = "brown",
                  "Baseline-level" = "black")

model_linetypes <- c("Other" = 1,
                     "Flusion" = 1,
                     "FluSight-ensemble_median" = 3,
                     "FluSight-ensemble_pool" = 4,
                     "Baseline-trend" = 2,
                     "Baseline-level" = 1)

horizon_labeller <- function(df) {
  list(paste0("Horizon ", df[[1]]))
}

p_wis_by_horizon <- ggplot() +
  geom_line(
    data = scores,
    mapping = aes(x = reference_date,
                  y = wis_scaled_relative_skill,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  geom_line(
    data = scores |> dplyr::filter(model_anon != "Other"),
    mapping = aes(x = reference_date,
                  y = wis_scaled_relative_skill,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  scale_color_manual("Model", values = model_colors) +
  scale_linetype_manual("Model", values = model_linetypes) +
  scale_linewidth_manual(values = c("TRUE" = 0.25, "FALSE" = 1)) +
  guides(linewidth = "none") +
  facet_wrap(~ horizon, ncol = 1, labeller = horizon_labeller) +
  coord_cartesian(ylim = c(0, 2.5)) +
  xlab("Forecast reference date") +
  ylab("Relative WIS") +
  theme_bw()

p_wis_by_horizon



p_wis_by_horizon <- ggplot() +
  geom_line(
    data = scores,
    mapping = aes(x = reference_date,
                  y = wis_scaled_relative_skill,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  geom_line(
    data = scores |> dplyr::filter(model_anon != "Other"),
    mapping = aes(x = reference_date,
                  y = wis_scaled_relative_skill,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  scale_color_manual("Model", values = model_colors) +
  scale_linetype_manual("Model", values = model_linetypes) +
  scale_linewidth_manual(values = c("TRUE" = 0.25, "FALSE" = 1)) +
  guides(linewidth = "none") +
  facet_wrap(~ horizon, ncol = 1, labeller = horizon_labeller) +
  coord_cartesian(ylim = c(0, 2.5)) +
  xlab("Forecast reference date") +
  ylab("Relative WIS") +
  theme_bw()

p_wis_by_horizon



ggplotly(p_by_horizon)


coverage_by_horizon <- ggplot(data = scores_by_model_horizon_date |>
                dplyr::mutate(is_umass = grepl("UMass", model))) +
  geom_line(mapping = aes(x = reference_date, y = interval_coverage_50, color = model, size = factor(is_umass))) +
  geom_point(mapping = aes(x = reference_date, y = interval_coverage_50, color = model, size = factor(is_umass))) +
  geom_hline(yintercept=0.5, linetype=2) +
  scale_size_manual(values = c(0.25, 1)) +
  facet_wrap(~ horizon) +
  theme_bw()

ggplotly(coverage_by_horizon)


coverage_by_horizon <- ggplot(data = scores_by_model_horizon_date |>
                dplyr::mutate(is_umass = grepl("UMass", model))) +
  geom_line(mapping = aes(x = reference_date, y = interval_coverage_95, color = model, size = factor(is_umass))) +
  geom_point(mapping = aes(x = reference_date, y = interval_coverage_95, color = model, size = factor(is_umass))) +
  geom_hline(yintercept=0.95, linetype=2) +
  scale_size_manual(values = c(0.25, 1)) +
  facet_wrap(~ horizon) +
  theme_bw()

ggplotly(coverage_by_horizon)





