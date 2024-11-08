library(here)
setwd(here::here())

library(hubData)

library(readr)
library(dplyr)
library(ggplot2)
library(ggdist)

library(scales)

source("code/utils.R")

# number of locations to plot
n_loc <- 6

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")

# initial reported values for target data
initial_target_data <- readr::read_csv("artifacts/initial_target_data.csv")

# locations with largest cumulative incidence in season
cum_values_by_loc <- target_data |>
  dplyr::filter(date >= "2023-10-14", date <= "2024-05-01", location != "US") |>
  dplyr::group_by(location, location_name) |>
  dplyr::summarize(
    cum_admissions = sum(value),
    cum_rate = sum(weekly_rate)) |>
  dplyr::arrange(desc(cum_admissions))

locs_to_plot <- cum_values_by_loc$location[seq_len(n_loc)]

hub_path <- "../FluSight-forecast-hub"
hub_con <- connect_hub(hub_path)
forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile"
  ) |>
  dplyr::collect() |>
  as_model_out_tbl() |>
  dplyr::filter(horizon >= 0,
                reference_date >= "2023-10-14",
                location %in% locs_to_plot) |>
  dplyr::rename(model = model_id) |>
  add_model_anon(
    highlighted_models = c(
      "UMass-flusion" = "Flusion",
      "FluSight-ensemble" = "FluSight-ensemble",
      "FluSight-baseline" = "Baseline-flat",
      "UMass-trends_ensemble" = "Baseline-trend")
  ) |>
  dplyr::filter(model_anon != "Other")

ref_dates_to_plot <- seq.Date(from = min(forecasts$reference_date),
                              to = max(forecasts$reference_date),
                              by = 4 * 7)

forecasts <- forecasts |>
  dplyr::filter(reference_date %in% ref_dates_to_plot)

# format forecasts for plotting
median_df <- forecasts |>
  dplyr::filter(output_type_id == "0.5") |>
  dplyr::transmute(model = model_anon,
                   location = location,
                   reference_date = reference_date,
                   x = target_end_date,
                   y = value,
                   .point = "median")

outputs_for_plot <- purrr::map(
  c(0.5, 0.95),
  function(width) {
    q_levels <- as.character(c((1 - width) / 2, 1 - (1 - width) / 2))
    interval_df <- forecasts |>
      dplyr::filter(output_type_id %in% q_levels) |>
      tidyr::pivot_wider(names_from = output_type_id,
                         values_from = value) |>
      dplyr::mutate(model = model_anon,
                    location = location,
                    reference_date = reference_date,
                    x = target_end_date,
                    .lower = .data[[q_levels[1]]],
                    .upper = .data[[q_levels[2]]],
                    .width = width,
                    .interval = "qi",
                    .keep = "none")
      left_join(median_df, interval_df, by = c("model", "location", "reference_date", "x"))
  }) |>
  purrr::list_rbind()


combined_target_data_for_plot <- dplyr::bind_rows(
    target_data |>
      dplyr::mutate(report_type = "Final report"),
    initial_target_data |>
      dplyr::left_join(
        target_data |> distinct(location, location_name),
        by = "location"
      ) |>
      dplyr::mutate(
        value = inc,
        report_type = "Initial report")
  ) |>
  dplyr::filter(location %in% locs_to_plot, date >= "2023-10-01") |>
  dplyr::mutate(
    location_name = factor(
      location_name,
      levels = cum_values_by_loc$location_name[seq_len(n_loc)],
      ordered = TRUE)
  )


p <- ggplot() +
  geom_lineribbon(
    mapping = aes(x = x, y = y, ymin = .lower, ymax = .upper, group = reference_date),
    data = outputs_for_plot |>
      dplyr::filter(location %in% locs_to_plot) |>
      dplyr::left_join(
        cum_values_by_loc |> select(location, location_name),
        by = "location") |>
      dplyr::mutate(
        location_name = factor(
          location_name,
          levels = cum_values_by_loc$location_name[seq_len(n_loc)],
          ordered = TRUE)
      )
  ) +
  geom_line(
    mapping = aes(x = date, y = value, linetype = report_type),
    linewidth = 0.75,
    color = "orange",
    data = combined_target_data_for_plot) +
  scale_linetype("Reported Data") +
  scale_fill_brewer("Interval Level", labels = c("95%", "50%")) +
  scale_x_date("Forecast target date", date_breaks = "2 month", date_labels = "%b %Y",
    # limits = c(as.Date("2020-07-25"), as.Date("2021-11-15")),
    expand = expansion()) +
  scale_y_continuous("Hospital admissions", labels = comma) +
  facet_grid(rows = vars(location_name), cols = vars(model), scales = "free_y") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(angle = 20, hjust=1, vjust=1)
  )

pdf(file.path("talks/20240806_JSM_ELR_flusion/figures/forecasts_flusight.pdf"), width = 10.5, height = 6)
print(p)
dev.off()
