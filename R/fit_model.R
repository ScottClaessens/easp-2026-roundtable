# function to fit the model
fit_model <- function(data, geographic_distance_matrix, 
                      linguistic_distance_matrix, response) {
  # function to convert distance matrix to covariance matrix
  convert_to_covariance_matrix <- function(distance_matrix) {
    # retain only necessary countries
    distance_matrix <- distance_matrix[data$iso2, data$iso2]
    # maximum distance = 1
    distance_matrix <- distance_matrix / max(distance_matrix)
    # convert to proximity matrix (covariance)
    1 - distance_matrix
  }
  # convert distance to covariance
  geographic_covariance_matrix <- 
    convert_to_covariance_matrix(geographic_distance_matrix)
  linguistic_covariance_matrix <- 
    convert_to_covariance_matrix(linguistic_distance_matrix)
  # get two copies of iso2 column in data
  data$iso2_geo <- data$iso2
  data$iso2_lin <- data$iso2
  # get model formula
  formula <- bf(
    paste0(
      response,
      " ~ 1 + (1 | gr(iso2_geo, cov = geo_cov)) + ",
      "(1 | gr(iso2_lin, cov = lin_cov)) + (1 | iso2)"
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
      geo_cov = geographic_covariance_matrix,
      lin_cov = linguistic_covariance_matrix
    ),
    family = gaussian(),
    prior = priors,
    backend = "cmdstanr",
    cores = 4,
    seed = 1
  )
}
