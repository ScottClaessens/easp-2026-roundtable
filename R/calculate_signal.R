# function to calculate geographic and linguistic signal
calculate_signal <- function(fit, response) {
  # extract posterior samples
  post <- posterior_samples(fit)
  # calculate total variance
  total_variance <- 
    post$sd_iso2_geo__Intercept^2 +
    post$sd_iso2_lin__Intercept^2 +
    post$sigma^2
  # calculate median signals
  tibble(
    Response = response,
    `Geographic signal` = median(
      post$sd_iso2_geo__Intercept^2 / total_variance
    ),
    `Linguistic signal` = median(
      post$sd_iso2_lin__Intercept^2 / total_variance
    ),
    Residual = 1 - (`Geographic signal` + `Linguistic signal`)
  )
}
