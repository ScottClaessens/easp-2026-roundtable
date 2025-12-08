# function to fit the model
fit_model <- function(data, geographic_distance_matrix, 
                      linguistic_distance_matrix, response) {
  # subset distance matrices to data
  geo_dist <- geographic_distance_matrix[data$iso2, data$iso2]
  lin_dist <- linguistic_distance_matrix[data$iso2, data$iso2]
  # maximum distance = 1
  geo_dist <- geo_dist / max(geo_dist)
  lin_dist <- lin_dist / max(lin_dist)
  # convert geographic distance to covariance (using matern kernel)
  # kernel parameters assume r = 0.36 at 1000km, r = 0.13 at 2000km,
  # r = 0.05 at 3000km, and r < 0.02 beyond 4000km
  geo_cov <-
    geoR::cov.spatial(
      geo_dist,
      cov.model = "matern",
      cov.pars = c(1, 0.05)
    )
  # convert linguistic distance to covariance (assuming brownian motion)
  lin_cov <- 1 - lin_dist
  # get two copies of iso2 column in data
  data$iso2_geo <- data$iso2
  data$iso2_lin <- data$iso2
  # get model formula
  formula <- bf(
    paste0(
      response,
      " ~ 1 + (1 | gr(iso2_geo, cov = geo_cov)) + ",
      "(1 | gr(iso2_lin, cov = lin_cov))"
    )
  )
  # get priors
  priors <- c(
    prior(normal(0, 0.1), class = Intercept),
    prior(exponential(5), class = sd),
    prior(exponential(5), class = sigma)
  )
  # fit model
  brm(
    formula = formula,
    data = data,
    data2 = list(
      geo_cov = geo_cov,
      lin_cov = lin_cov
    ),
    family = gaussian(),
    prior = priors,
    backend = "cmdstanr",
    iter = 4000,
    control = list(adapt_delta = 0.99),
    cores = 4,
    seed = 1
  )
}
