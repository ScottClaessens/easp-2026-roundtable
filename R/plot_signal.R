# function to plot geographic and linguistic signal
plot_signal <- function(fit, response) {
  # extract posterior samples
  post <- posterior_samples(fit)
  # calculate total variance
  total_variance <- 
    post$sd_iso2_geo__Intercept^2 +
    post$sd_iso2_lin__Intercept^2 +
    post$sigma^2
  # calculate signals
  tibble(
    `Geographic signal` = post$sd_iso2_geo__Intercept^2 / total_variance,
    `Linguistic signal` = post$sd_iso2_lin__Intercept^2 / total_variance
  ) |>
    pivot_longer(everything()) |>
    # plot
    ggplot(
      aes(
        x = value,
        y = factor(name, levels = c("Linguistic signal", "Geographic signal"))
      )
    ) +
    stat_slabinterval() +
    labs(
      x = "Proportion of variance explained",
      y = NULL
    ) +
    theme_classic()
}
