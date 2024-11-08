library(here)
setwd(here::here())

library(readr)
library(dplyr)
library(ggplot2)
library(ggdist)

library(scales)

# number of locations to plot
n_loc <- 9

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")

# locations with largest cumulative incidence in season
cum_values_by_loc <- target_data |>
  dplyr::filter(date >= "2023-10-14", date <= "2024-05-01", location != "US") |>
  dplyr::group_by(location, location_name) |>
  dplyr::summarize(
    cum_admissions = sum(value),
    cum_rate = sum(weekly_rate)) |>
  dplyr::arrange(desc(cum_admissions))

locs_to_plot <- cum_values_by_loc$location[seq(from = 1, to = nrow(cum_values_by_loc), length.out = n_loc)]
location_names_ordered <- cum_values_by_loc |>
  dplyr::filter(location %in% locs_to_plot) |>
  dplyr::pull(location_name)

p <- ggplot() +
  geom_line(
    mapping = aes(x = date, y = value),
    linewidth = 0.75,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-06-01"
      ) |>
      dplyr::mutate(
        location_name = factor(location_name, levels = location_names_ordered)
      )
    ) +
  scale_x_date("Date", date_breaks = "2 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous("NHSN: Influenza hospitalizations", labels = comma) +
  facet_wrap(~ location_name, scales = "free_y") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 20, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/nhsn_data_selected_states.pdf"), width = 9, height = 5)
print(p)
dev.off()



p <- ggplot() +
  geom_line(
    mapping = aes(x = date, y = weekly_rate),
    linewidth = 0.75,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-06-01"
      ) |>
      dplyr::mutate(
        location_name = factor(location_name, levels = location_names_ordered)
      )
    ) +
  scale_x_date("Date", date_breaks = "2 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous("NHSN: Influenza hospitalizations / 100k pop.", labels = comma) +
  facet_wrap(~ location_name, scales = "free_y") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 20, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/nhsn_rate_selected_states.pdf"), width = 9, height = 5)
print(p)
dev.off()



p <- ggplot() +
  geom_line(
    mapping = aes(x = date, y = (weekly_rate + 0.01 + 0.75**4)^0.25),
    linewidth = 0.75,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-06-01"
      ) |>
      dplyr::mutate(
        location_name = factor(location_name, levels = location_names_ordered)
      )
    ) +
  scale_x_date("Date", date_breaks = "2 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous("Fourth root of influenza hospitalizations / 100k pop.", labels = comma) +
  facet_wrap(~ location_name) +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 20, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/nhsn_4rt_rate_selected_states.pdf"), width = 9, height = 5)
print(p)
dev.off()


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
  geom_line(
    mapping = aes(x = date, y = inc_trans_cs),
    linewidth = 0.75,
    color = "#1f77b4",
    data = target_data |>
      dplyr::filter(
        location %in% locs_to_plot,
        date >= "2022-10-01" & date <= "2023-06-01"
      ) |>
      dplyr::mutate(
        location_name = factor(location_name, levels = location_names_ordered)
      )
    ) +
  scale_x_date("Date", date_breaks = "2 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous("Transformed influenza hospitalizations rate", labels = comma) +
  facet_wrap(~ location_name) +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 20, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/nhsn_cs_4rt_rate_selected_states.pdf"), width = 9, height = 5)
print(p)
dev.off()


location_data <- read_csv("../flusion/submissions-hub/auxiliary-data/locations.csv") |>
  dplyr::select(location, population)

p <- ggplot() +
  geom_line(
    mapping = aes(x = date, y = inc_trans_cs, color = population, group = location),
    linewidth = 0.75,
    data = target_data |>
      dplyr::left_join(
        location_data, by = "location"
      ) |>
      dplyr::filter(
        location != "US",
        date >= "2022-10-01" & date <= "2023-06-01"
      ) |>
      dplyr::mutate(
        location_name = factor(location_name, levels = location_names_ordered)
      )
    ) +
  scale_color_viridis_c(
    trans="log", option="B", end=0.9, begin=0.1,
    breaks=c(1000000, 2000000, 4000000, 8000000, 16000000, 32000000)
  ) +
  scale_x_date("Date", date_breaks = "2 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous("Transformed influenza hospitalizations rate", labels = comma) +
  # theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 20, hjust=1, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/nhsn_cs_4rt_rate_all_states.pdf"), width = 9, height = 5)
print(p)
dev.off()

