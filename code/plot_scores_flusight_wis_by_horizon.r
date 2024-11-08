library(readr)
library(ggplot2)

source("code/utils.R")

scores <- readr::read_csv("artifacts/scores/scores_by_model_horizon_flusight_all.csv") |>
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

p <- ggplot(data = scores) +
  geom_line(
    mapping = aes(
      x = horizon,
      y = wis,
      color = model_anon,
      linetype = model_anon,
      linewidth = is_other_model,
      group = model
    )
  ) +
  scale_color_manual("Model", values = model_colors) +
  scale_linetype_manual("Model", values = model_linetypes) +
  scale_linewidth_manual(values = c("TRUE" = 0.25, "FALSE" = 1)) +
  guides(linewidth = "none") +
  xlab("Forecast Horizon") +
  ylab("Weighted Interval Score") +
  theme_bw()

save_dir <- "artifacts/figures"
if (!dir.exists(save_dir)) {
  dir.create(save_dir, recursive = TRUE)
}

pdf(file.path(save_dir, "scores_flusight_wis_by_horizon.pdf"), width = 8, height = 8)
print(p)
dev.off()
