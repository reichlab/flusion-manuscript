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

p <- importance |>
  group_by(feat) |>
  summarize(importance = mean(importance)) |>
  arrange(importance) |>
  mutate(feat = factor(feat, levels = feat, ordered = TRUE)) |>
  ggplot() +
    geom_col(mapping = aes(x = feat, y = importance)) +
    xlab("feature name") +
    ylab("importance score") +
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

