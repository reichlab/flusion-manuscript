library(here)
setwd(here::here())

library(readr)
library(dplyr)
library(ggplot2)
library(ggdist)

library(scales)

# number of locations to plot
n_loc <- 1

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")

locs_to_plot <- "48"

p <- ggplot() +
  geom_vline(xintercept = as.Date("2023-01-07"), linetype = 2) +
  geom_line(
    mapping = aes(x = date, y = value),
    linetype = 1,
    linewidth = 0.75,
    color = "#1f77b4",
    alpha = 0.5,
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-01-01"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = value),
    size = 2,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-01-01"
      )
    ) +
  geom_line(
    mapping = aes(x = date, y = value),
    linetype = 2,
    linewidth = 0.75,
    color = "#1f77b4",
    alpha = 0.5,
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2023-01-07" & date <= "2023-01-28"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = value),
    size = 3,
    shape = 15,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2023-01-07" & date <= "2023-01-28"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = value),
    size = 1.5,
    shape = 15,
    color = "#ffffff",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2023-01-07" & date <= "2023-01-28"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = value),
    size = 3,
    shape = 15,
    color = "orange",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date == "2023-01-21"
      )
    ) +
  scale_x_date("Date", date_breaks = "1 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion(c(0, 0), c(2, 7))) +
  scale_y_continuous("NHSN hospitalizations", labels = comma, expand = expansion(c(0, 0), c(100, 100))) +
  facet_wrap(~ location_name, scales = "free_y") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 45, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/forecast_task_setup.pdf"), width = 5, height = 2.5)
print(p)
dev.off()

target_data <- readr::read_csv("artifacts/target_data.csv")

cs_factors <- target_data |>
  dplyr::mutate(
    trans_rate = (weekly_rate + 0.01 + 0.75**4)^0.25
  ) |>
  dplyr::group_by(
    location
  ) |>
  dplyr::summarize(
    s_factor = quantile(trans_rate, 0.95),
    c_factor = mean(trans_rate / (quantile(trans_rate, 0.95) + 0.01))
  )

target_data <- target_data |>
  dplyr::left_join(cs_factors, by="location") |>
  dplyr::mutate(
    inc_trans_cs = (weekly_rate + 0.01 + 0.75**4)^0.25 / (s_factor + 0.01) - c_factor
  )

p <- ggplot() +
  geom_vline(xintercept = as.Date("2023-01-07"), linetype = 2) +
  geom_line(
    mapping = aes(x = date, y = inc_trans_cs),
    linetype = 1,
    linewidth = 0.75,
    color = "#1f77b4",
    alpha = 0.5,
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-01-01"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = inc_trans_cs),
    size = 2,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-01-01"
      )
    ) +
  geom_line(
    mapping = aes(x = date, y = inc_trans_cs),
    linetype = 2,
    linewidth = 0.75,
    color = "#1f77b4",
    alpha = 0.5,
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2023-01-07" & date <= "2023-01-28"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = inc_trans_cs),
    size = 3,
    shape = 15,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2023-01-07" & date <= "2023-01-28"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = inc_trans_cs),
    size = 1.5,
    shape = 15,
    color = "#ffffff",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2023-01-07" & date <= "2023-01-28"
      )
    ) +
  geom_point(
    mapping = aes(x = date, y = inc_trans_cs),
    size = 3,
    shape = 15,
    color = "orange",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date == "2023-01-21"
      )
    ) +
  scale_x_date("Date", date_breaks = "1 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion(c(0, 0), c(2, 7))) +
  scale_y_continuous("Transformed\nNHSN hospitalizations", labels = comma, expand = expansion(c(0, 0), c(0.02, 0.02))) +
  facet_wrap(~ location_name, scales = "free_y") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 45, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/forecast_task_setup_transformed.pdf"), width = 5.1, height = 2.5)
print(p)
dev.off()
