# function to fit the model
fit_model <- function(data, geographic_distance_matrix, 
                      linguistic_distance_matrix, response) {
  # countries with observed data for response
  obs_iso2 <- 
    data |>
    drop_na(!!sym(response)) |>
    pull(iso2)
  # subset distance matrices
  geo_dist <- geographic_distance_matrix[obs_iso2, obs_iso2]
  lin_dist <- linguistic_distance_matrix[obs_iso2, obs_iso2]
  # ensure matrices are symmetrical
  geo_dist[upper.tri(geo_dist)] <- t(geo_dist)[upper.tri(geo_dist)]
  lin_dist[upper.tri(lin_dist)] <- t(lin_dist)[upper.tri(lin_dist)]
  # maximum distance = 1
  geo_dist <- geo_dist / max(geo_dist)
  lin_dist <- lin_dist / max(lin_dist)
  # convert geographic distance to covariance (using matern kernel)
  geo_cov <-
    geoR::cov.spatial(
      geo_dist,
      cov.model = "matern",
      cov.pars = c(1, 0.2)
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
      geo_cov = round(geo_cov, 4),
      lin_cov = round(lin_cov, 4)
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
