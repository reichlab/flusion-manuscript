library(here)
setwd(here::here())

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(grid)
library(ggpubr)
library(scales)


source("code/utils.R")

scores <- readr::read_csv(
  "artifacts/scores/scores_by_model_horizon_reference_date_flusight_all.csv") |>
  add_model_anon(
    highlighted_models = c(
      "UMass-flusion" = "Flusion",
      "FluSight-ensemble" = "FluSight-ensemble",
      "FluSight-baseline" = "Baseline-flat",
      "UMass-trends_ensemble" = "Baseline-trend")
  ) |>
  dplyr::mutate(
    target_date = reference_date + 7 * horizon
  )

scores_by_model_horizon <- readr::read_csv(
  "artifacts/scores/scores_by_model_horizon_flusight_all.csv") |>
  add_model_anon(
    highlighted_models = c(
      "UMass-flusion" = "Flusion",
      "FluSight-ensemble" = "FluSight-ensemble",
      "FluSight-baseline" = "Baseline-flat",
      "UMass-trends_ensemble" = "Baseline-trend")
  )

model_colors <- c("Other" = "grey",
                  "Flusion" = "orange",
                  "FluSight-ensemble" = "blue",
                  # "FluSight-ensemble_median" = "cornflowerblue",
                  # "FluSight-ensemble_pool" = "purple",
                  "Baseline-trend" = "brown",
                  "Baseline-flat" = "black")

model_linetypes <- c("Other" = 1,
                     "Flusion" = 1,
                     "FluSight-ensemble" = 4,
                    #  "FluSight-ensemble_median" = 3,
                    #  "FluSight-ensemble_pool" = 4,
                     "Baseline-trend" = 2,
                     "Baseline-flat" = 1)

horizon_labeller <- function(df) {
  list(paste0("Horizon ", df[[1]]))
}

p_wis_by_horizon <- ggplot() +
  geom_line(
    data = scores,
    mapping = aes(x = target_date,
                  y = wis_scaled_relative_skill,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  geom_line(
    data = scores |> dplyr::filter(model_anon != "Other"),
    mapping = aes(x = target_date,
                  y = wis_scaled_relative_skill,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  scale_color_manual("Model", values = model_colors) +
  scale_linetype_manual("Model", values = model_linetypes) +
  scale_linewidth_manual(values = c("TRUE" = 0.25, "FALSE" = 1)) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  guides(linewidth = "none") +
  facet_wrap(~ horizon, ncol = 1, labeller = horizon_labeller) +
  coord_cartesian(ylim = c(0, 2.5)) +
  xlab("Forecast target date") +
  ylab("") +
  ggtitle("(b) Forecast scores by target date") +
  theme_bw() +
  theme(plot.margin = margin(0, 0, 0, 0, "cm"))

# legend_wis <- ggpubr::get_legend(p_wis_by_horizon, position = "bottom")
legend_wis <- ggpubr::get_legend(p_wis_by_horizon)

p_wis_by_horizon <- p_wis_by_horizon +
  theme(legend.position = "none")



# p_wis_by_horizon <- ggplot() +
#   geom_line(
#     data = scores,
#     mapping = aes(x = reference_date,
#                   y = wis_scaled_relative_skill,
#                   color = model_anon,
#                   linetype = model_anon,
#                   linewidth = is_other_model,
#                   group = model)) +
#   geom_line(
#     data = scores |> dplyr::filter(model_anon != "Other"),
#     mapping = aes(x = reference_date,
#                   y = wis_scaled_relative_skill,
#                   color = model_anon,
#                   linetype = model_anon,
#                   linewidth = is_other_model,
#                   group = model)) +
#   scale_color_manual("Model", values = model_colors) +
#   scale_linetype_manual("Model", values = model_linetypes) +
#   scale_linewidth_manual(values = c("TRUE" = 0.25, "FALSE" = 1)) +
#   guides(linewidth = "none") +
#   facet_wrap(~ horizon, ncol = 1, labeller = horizon_labeller) +
#   coord_cartesian(ylim = c(0, 2.5)) +
#   xlab("Forecast reference date") +
#   ylab("Relative WIS") +
#   theme_bw()

# p_wis_by_horizon

scores_q_coverage <- scores_by_model_horizon |>
  select(model, model_anon, is_other_model, horizon,
         starts_with("q_coverage_")) |>
  pivot_longer(cols = starts_with("q_coverage"),
               names_to = "nominal", names_prefix = "q_coverage_",
               values_to = "empirical") |>
  mutate(
    nominal = as.numeric(nominal),
    coverage_delta = empirical - nominal)

p_q_coverage_by_horizon <- ggplot() +
  geom_rect(
    data = data.frame(
      xmin = c(0.5, 0),
      xmax = c(1, 0.5),
      ymin = c(0, -1),
      ymax = c(1, 0)
    ),
    mapping = aes(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax),
    alpha = 0.2,
    fill = "cornflowerblue"
  ) +
  geom_line(
    data = scores_q_coverage,
    mapping = aes(x = nominal,
                  y = coverage_delta,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  geom_hline(yintercept = 0) +
  geom_line(
    data = scores_q_coverage |> dplyr::filter(model_anon != "Other"),
    mapping = aes(x = nominal,
                  y = coverage_delta,
                  color = model_anon,
                  linetype = model_anon,
                  linewidth = is_other_model,
                  group = model)) +
  geom_text(
    data = data.frame(
      horizon = 0,
      x = c(0.25, 0.75),
      y = c(-0.3, 0.2),
      label = c("conservative\nlower tail", "conservative\nupper tail")
    ),
    mapping = aes(x = x, y = y, label = label),
    size = 8,
    size.unit = "pt",
    color = "#444444",
    parse = FALSE
  ) +
  scale_color_manual("Model", values = model_colors) +
  scale_linetype_manual("Model", values = model_linetypes) +
  scale_linewidth_manual(values = c("TRUE" = 0.25, "FALSE" = 1)) +
  guides(linewidth = "none") +
  facet_wrap(~ horizon, ncol = 1, labeller = horizon_labeller) +
  coord_cartesian(xlim = c(0, 1), ylim = c(-0.4, 0.3), expand = FALSE) +
  xlab("Nominal coverage rate") +
  ylab("Empirical minus nominal coverage rate") +
  ggtitle("(c) Forecast calibration") +
  theme_bw() +
  theme(legend.position = "none",
        plot.margin = margin(0, 0.1, 0, 0, "cm"))

p_q_coverage_by_horizon


target_data <- readr::read_csv("artifacts/target_data.csv") |>
  dplyr::filter(
    date >= "2023-10-14",
    location != "US",
    location != "78") |>
  dplyr::group_by(date) |>
  dplyr::summarize(value = sum(value))

p_target_data <- ggplot() +
  geom_line(
    data = target_data,
    mapping = aes(x = date, y = value, color = "National data")) +
  scale_color_manual("National Data", values = "black") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous(labels = comma) +
  xlab("Date") +
  ylab("") +
  ggtitle("(a) Influenza Hospitalizations") +
  theme_bw() +
  theme(plot.margin = margin(0, 0, 0, 0, "cm"))
legend_data <- ggpubr::get_legend(p_target_data)
p_target_data <- p_target_data +
  theme(legend.position = "none")


# put the plots together
save_dir <- "artifacts/figures"
if (!dir.exists(save_dir)) {
  dir.create(save_dir, recursive = TRUE)
}

pdf(file.path(save_dir, "scores_flusight.pdf"), width = 8, height = 10)
panel_padding <- c(0.035, 0.025)
plot_layout <- grid.layout(
  nrow = 3, ncol = 6,
  widths = unit(c(1.5, panel_padding[1], 0.8, panel_padding[2], 0.45, 0.5),
                c("lines", rep("null", 4), "lines")),
  heights = unit(c(1, 0.5, 4), c("null", "lines", "null")))

grid.newpage()
pushViewport(viewport(layout = plot_layout))

print(as_ggplot(legend_wis), vp = viewport(layout.pos.row = 1, layout.pos.col = 5))
print(p_target_data, vp = viewport(layout.pos.row = 1, layout.pos.col = 2:3))
print(p_q_coverage_by_horizon, vp = viewport(layout.pos.row = 3, layout.pos.col = 5))
print(p_wis_by_horizon, vp = viewport(layout.pos.row = 3, layout.pos.col = 3))

grid.text("            Weekly\n          Hospital Admissions",
  just = "center",
  rot = 90,
  gp = gpar(fontsize = 11),
  vp = viewport(layout.pos.row = 1, layout.pos.col = 1))

print(
  ggplot() +
    geom_line(
      data = data.frame(x = c(1, 1), y = c(0.035, 0.97)),
      mapping = aes(x = x, y = y)) +
    xlim(0, 1) +
    scale_y_continuous(limits = c(0, 1), expand = expansion(0, 0)) +
    theme_void(),
  vp = viewport(layout.pos.row = 3, layout.pos.col = 1)
)
grid.text("       Relative MWIS",
  just = "center",
  rot = 90,
  gp = gpar(fontsize = 11),
  vp = viewport(layout.pos.row = 3, layout.pos.col = 1))

dev.off()
