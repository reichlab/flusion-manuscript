library(here)
setwd(here::here())

library(hubData)
library(hubEvals)

library(readr)
library(dplyr)
library(ggplot2)
library(ggdist)
library(grid)
library(purrr)

library(scales)

x_grid <- seq(from = 0, to = 500)

normal_params <- data.frame(
  mean = c(200, 200, 300, 300),
  sd = c(10, 50, 10, 50)
)
density_df <- purrr::pmap(
  normal_params,
  function(mean, sd) {
    data.frame(
      location = ifelse(mean == 200, "Correct location", "Incorrect location"),
      dispersion = ifelse(sd == 10, "Low dispersion", "High dispersion"),
      x = x_grid,
      density = dnorm(x_grid, mean = mean, sd = sd)
    )
  }
) |>
  list_rbind() |>
  dplyr::mutate(dispersion = factor(dispersion, levels = c("Low dispersion", "High dispersion")))

q_levels <- c(0.01, 0.025, seq(from = 0.05, to = 0.95, by = 0.05), 0.975, 0.99)
quantiles_df <- purrr::pmap(
  normal_params,
  function(mean, sd) {
    data.frame(
      location = ifelse(mean == 200, "Correct location", "Incorrect location"),
      dispersion = ifelse(sd == 10, "Low dispersion", "High dispersion"),
      p = q_levels,
      q = qnorm(q_levels, mean = mean, sd = sd)
    )
  }
) |>
  list_rbind() |>
  dplyr::mutate(dispersion = factor(dispersion, levels = c("Low dispersion", "High dispersion")))


scores <- hubEvals::score_model_out(
  model_out_tbl = quantiles_df |>
    dplyr::transmute(
      model_id = paste0(location, ",", dispersion),
      output_type = "quantile",
      output_type_id = as.character(p),
      value = q,
      fake_join_column = "junk"
    ),
  target_observations = data.frame(observation = 200,
      fake_join_column = "junk"),
  metrics = c("ae_median", "wis"),
  by = "model_id"
)




p <- ggplot() +
  geom_vline(
    data = quantiles_df,
    mapping = aes(xintercept = q),
    linetype = 2,
    linewidth = 0.2
  ) +
  geom_line(
    data = density_df,
    mapping = aes(x = x, y = density),
    linewidth = 1
  ) +
  geom_vline(
    xintercept = 200,
    linewidth = 1,
    color = "orange"
  ) +
  geom_label(
    data = scores |>
      separate_wider_delim(cols = "model_id", delim = ",", names = c("location", "dispersion")) |>
      dplyr::mutate(
        label = paste0("WIS: ", format(round(wis, 1), nsmall = 1), "\n", "AE: ", ae_median)
      ) |>
      dplyr::mutate(dispersion = factor(dispersion, levels = c("Low dispersion", "High dispersion"))),
    mapping = aes(label = label),
    x = 400,
    y = 0.8 * max(density_df$density)
  ) +
  ylab("Predictive density") +
  xlab("Hospital admissions") +
  scale_y_continuous(expand = expansion(c(0.01, 0.05), 0)) +
  scale_x_continuous(expand = expansion(0, 5)) +
  facet_grid(rows = vars(location), cols = vars(dispersion), scales = "free_y") +
  theme_bw() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank(),
    panel.spacing = unit(1, "lines"),
    plot.margin = unit(c(0.1,1,0.1,0.1), "lines")
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/wis_examples.pdf"), width = 10, height = 4)
print(p)
dev.off()

