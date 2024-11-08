library(here)
setwd(here::here())

library(hubData)

library(readr)
library(dplyr)
library(ggplot2)
library(ggdist)
library(grid)

library(distfromq)

library(scales)

locs_to_plot <- "06"

# load data
target_data <- readr::read_csv("artifacts/target_data.csv")

# initial reported values for target data
initial_target_data <- readr::read_csv("artifacts/initial_target_data.csv")

hub_path <- "../FluSight-forecast-hub"
hub_con <- connect_hub(hub_path)
forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile",
    reference_date == "2023-12-09",
    location == "06",
    model_id == "UMass-flusion",
    horizon >= 0
  ) |>
  dplyr::collect() |>
  as_model_out_tbl()

# format forecasts for plotting
median_df <- forecasts |>
  dplyr::filter(output_type_id == "0.5") |>
  dplyr::transmute(model = model_id,
                   location = location,
                   reference_date = reference_date,
                   x = target_end_date,
                   y = value,
                   .point = "median")

outputs_for_plot <- purrr::map(
  c(0.5, 0.8, 0.95),
  function(width) {
    q_levels <- as.character(c((1 - width) / 2, 1 - (1 - width) / 2))
    interval_df <- forecasts |>
      dplyr::filter(output_type_id %in% q_levels) |>
      tidyr::pivot_wider(names_from = output_type_id,
                         values_from = value) |>
      dplyr::mutate(model = model_id,
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
    # target_data |>
    #   dplyr::mutate(report_type = "Final report"),
    initial_target_data |>
      dplyr::left_join(
        target_data |> distinct(location, location_name),
        by = "location"
      ) |>
      dplyr::mutate(
        value = inc,
        report_type = "Hospitalizations")
  ) |>
  dplyr::filter(location %in% locs_to_plot, date >= "2023-10-01", date < "2023-12-09")# |>
  # dplyr::mutate(
  #   location_name = factor(
  #     location_name,
  #     levels = cum_values_by_loc$location_name[seq_len(n_loc)],
  #     ordered = TRUE)
  # )


p <- ggplot() +
  geom_lineribbon(
    mapping = aes(x = x, y = y, ymin = .lower, ymax = .upper, group = reference_date),
    data = outputs_for_plot |>
      dplyr::filter(location %in% locs_to_plot)
  ) +
  geom_line(
    mapping = aes(x = date, y = value),
    linewidth = 0.75,
    color = "orange",
    data = combined_target_data_for_plot) +
  geom_point(
    mapping = aes(x = date, y = value),
    size = 2,
    color = "orange",
    data = combined_target_data_for_plot) +
  # scale_linetype("Reported Data") +
  # scale_shape("Reported Data") +
  scale_fill_brewer("Interval Level", labels = c("95%", "80%", "50%")) +
  scale_x_date("Date", date_breaks = "1 month", date_labels = "%b %Y",
    limits = c(as.Date("2023-10-01"), as.Date("2023-12-31")),
    expand = expansion()) +
  scale_y_continuous("Hospital admissions", labels = comma) +
  # facet_grid(rows = vars(location_name), cols = vars(model), scales = "free_y") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.text.x = element_text(hjust=0, vjust=1)
  )

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/forecast_anatomy_ribbon.pdf"), width = 7, height = 2)
print(p)
dev.off()

x_grid <- seq(from = 0, to = 4000, length.out = 201)

get_spar_value <- function(ted) {
  if (ted == "2023-12-09") return(0.5)
  if (ted == "2023-12-16") return(0.6)
  if (ted == "2023-12-23") return(0.7)
  if (ted == "2023-12-30") return(0.8)
}

density_df <- forecasts |>
  dplyr::group_by(target_end_date) |>
  dplyr::summarize(
    x = list(x_grid),
    density = list(distfromq::make_d_fn(ps = as.numeric(output_type_id), qs = value)(x_grid))
  ) |>
  tidyr::unnest(cols = c("x", "density")) |>
  dplyr::group_by(target_end_date) |>
  dplyr::mutate(
    density_smoothed_spline = pmax(0, predict(smooth.spline(x, density, spar = get_spar_value(target_end_date[1])), x)$y)
  )
  
# x <- x_grid
# y <- density_df |> dplyr::slice_min(target_end_date) |> dplyr::pull(density)
# lowpass.spline <- smooth.spline(x,y, spar = 0.6)
# predict(lowpass.spline, x_grid)

# plot(x, y, type="l", lwd = 5, col = "green")
# lines(predict(lowpass.spline, x), col = "red", lwd = 2)

p <- ggplot() +
  geom_vline(
    data = forecasts |> dplyr::filter(output_type_id == "0.5"),
    mapping = aes(xintercept = value),
    linetype = 1,
    linewidth = 1
  ) +
  geom_vline(
    data = forecasts |> dplyr::filter(output_type_id %in% c(0.025, 0.975)),
    mapping = aes(xintercept = value),
    linetype = 1,
    linewidth = 1,
    color = "#E0EBF6"
  ) +
  geom_vline(
    data = forecasts |> dplyr::filter(output_type_id %in% c(0.1, 0.9)),
    mapping = aes(xintercept = value),
    linetype = 1,
    linewidth = 1,
    color = "#A7C9DE"
  ) +
  geom_vline(
    data = forecasts |> dplyr::filter(output_type_id %in% c(0.25, 0.75)),
    mapping = aes(xintercept = value),
    linetype = 1,
    linewidth = 1,
    color = "#4981B8"
  ) +
  geom_vline(
    data = forecasts,
    mapping = aes(xintercept = value),
    linetype = 2,
    linewidth = 0.2
  ) +
  geom_line(
    data = density_df,
    mapping = aes(x = x, y = density_smoothed_spline),
    linewidth = 1#,
    # color = "#1f77b4"
  ) +
  ylab("Predictive density") +
  xlab("Hospital admissions") +
  expand_limits(x = 0) +
  scale_y_continuous(expand = expansion(c(0.01, 0.05), 0)) +
  scale_x_continuous(expand = expansion(0, 5)) +
  # facet_wrap(~ target_end_date, nrow = 1) +
  facet_wrap(~ target_end_date, nrow = 1, scales = "free_y") +
  # facet_wrap(~ target_end_date, nrow = 1, scales = "free_x") +
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

pdf(file.path("talks/20241112_Yale_ELR_flusion/figures/forecast_anatomy_by_date.pdf"), width = 7, height = 2)
print(p)
dev.off()

