library(here)
setwd(here::here())

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(grid)
library(ggpubr)
library(scales)

importance <- readr::read_csv("../flusion/retrospective-hub/model-artifacts/UMass-gbq_qr/feat_importance/2024-01-06-UMass-gbq_qr.csv")

importance <- importance |>
  group_by(feat, q_level) |>
  summarize(importance = mean(importance))

clean_feat_names <- function(feat) {
  feat[feat == "season_week"] <- "season week"
  feat[feat == "delta_xmas"] <- "weeks from Christmas"
  feat[feat == "log_pop"] <- "log(population)"
  
  feat <- gsub("inc_trans_cs_rollmean", "rolling mean", feat, fixed = TRUE)
  feat <- gsub("inc_trans_cs_taylor", "Taylor poly.", feat, fixed = TRUE)
  feat <- gsub("inc_trans_cs", "signal value", feat, fixed = TRUE)
  feat <- gsub("source_", "source: ", feat, fixed = TRUE)
  feat[feat == "source: hhs"] <- "source: nhsn"
  feat <- gsub("location_", "location: ", feat, fixed = TRUE)
  feat <- gsub("agg_level_", "agg. level: ", feat, fixed = TRUE)

  feat <- gsub("t_sNone", "", feat, fixed = TRUE)
  feat <- gsub("_d", ", d=", feat, fixed = TRUE)
  feat <- gsub("_c", ", c=", feat, fixed = TRUE)
  feat <- gsub("_w", ", w=", feat, fixed = TRUE)
  feat <- gsub("_lag", ", lag=", feat, fixed = TRUE)
}

p <- importance |>
  group_by(feat) |>
  summarize(importance = mean(importance)) |>
  arrange(importance) |>
  mutate(
    feat_clean = clean_feat_names(feat),
    feat = factor(feat_clean, levels = feat_clean, ordered = TRUE)) |>
  ggplot() +
    geom_col(mapping = aes(x = feat, y = importance)) +
    xlab("Feature name") +
    ylab("Importance score") +
    coord_flip() +
    theme_bw(base_size=9) +
    theme(
      axis.text.x = element_text(angle=90, hjust=1, vjust=0.5)
    )

# put the plots together
save_dir <- "artifacts/figures"
if (!dir.exists(save_dir)) {
  dir.create(save_dir, recursive = TRUE)
}

pdf(file.path(save_dir, "feature_importance.pdf"), width = 8, height = 10)
print(p)
dev.off()

