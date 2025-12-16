# function to plot regression model results
plot_model <- function(data, fit, region_vars = NULL, file) {
  # add regions to data
  data <- 
    data |>
    drop_na(c(ZCAF_5y_Donation, hof_idv)) |>
    mutate(
      region = countrycode::countrycode(
        sourcevar = iso2,
        origin = "iso2c",
        destination = "region23"
      )
    )
  # get fitted regression line
  newdata <- 
    tibble(
      hof_idv = seq(
        from = min(data$hof_idv),
        to = max(data$hof_idv),
        length.out = 1000
      )
    )
  f <-
    fitted(
      object = fit,
      newdata = newdata,
      re_formula = NA
    )
  newdata <- bind_cols(newdata, f)
  # plot
  if (!is.null(region_vars)) {
    p <-
      ggplot() +
      geom_point(
        data = filter(data, !(region %in% region_vars)),
        mapping = aes(
          x = hof_idv,
          y = ZCAF_5y_Donation
        ),
        colour = "grey90"
      ) +
      geom_point(
        data = filter(data, region %in% region_vars),
        mapping = aes(
          x = hof_idv,
          y = ZCAF_5y_Donation
        ),
        colour = "red"
      ) +
      geom_text_repel(
        data = filter(data, region %in% region_vars),
        mapping = aes(
          x = hof_idv,
          y = ZCAF_5y_Donation,
          label = iso2
        ),
        size = 3.5,
        colour = "red",
        seed = 1
      )
  } else {
    p <-
      ggplot() +
      geom_point(
        data = data,
        mapping = aes(
          x = hof_idv,
          y = ZCAF_5y_Donation
        )
      )
  }
  p <-
    p +
    geom_ribbon(
      data = newdata,
      mapping = aes(
        x = hof_idv,
        ymin = `Q2.5`,
        ymax = `Q97.5`
      ),
      fill = "grey",
      alpha = 0.5
    ) +
    geom_line(
      data = newdata,
      mapping = aes(
        x = hof_idv,
        y = Estimate
      )
    ) +
    labs(
      x = "Individualism (std.)",
      y = "Charitable donations (std.)"
    ) +
    theme_classic() +
    theme(legend.position = "none")
  # save
  ggsave(
    plot = p,
    filename = file,
    # 16:9 dimensions
    height = 9 / 3,
    width = 16 / 3,
    dpi = 300
  )
  return(p)
}
