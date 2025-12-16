options(tidyverse.quiet = TRUE)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(
  packages = c("brms", "countrycode", "ggrepel", "haven",
               "patchwork", "readxl", "tidyverse")
)
tar_source()

# loop over response variables
mapping <- tar_map(
  values = tibble(
    response = c(
      "posrecip", "negrecip", "altruism", "trust", "ZCAF_5y_Donation",
      "ZCAF_5y_Volunteering", "ZCAF_5y_Everyday", "ZBlood_per_adult_capita",
      "ZKidney_donors_pmp", "ZMarrow_per_capita", "ZAnimal_reversed_lohi"
    )
  ),
  # fit model
  tar_target(fit, fit_model(data, geographic_distance_matrix,
                            linguistic_distance_matrix, response)),
  # calculate signals
  tar_target(signal, calculate_signal(fit, response))
)

# pipeline
list(
  # load data
  tar_target(gps_data_file, "data/gps/country.dta", format = "file"),
  tar_target(rhoads_data_file, "data/rhoads2021/GlobalAltruismData.xlsx", 
             format = "file"),
  tar_target(rhoads_isocodes_file, "data/rhoads2021/isocodes.xlsx", 
             format = "file"),
  tar_target(data, load_data(gps_data_file, rhoads_data_file,
                             rhoads_isocodes_file)),
  # load geographic distances
  tar_target(
    geographic_distance_matrix_file,
    "data/networks/1F Population Distance.xlsx",
    format = "file"
  ),
  tar_target(
    geographic_distance_matrix,
    load_distance_matrix(geographic_distance_matrix_file, log = TRUE)
  ),
  # load linguistic distances
  tar_target(
    linguistic_distance_matrix_file,
    "data/networks/2F Country Distance 1pml adj.xlsx",
    format = "file"
  ),
  tar_target(
    linguistic_distance_matrix,
    load_distance_matrix(linguistic_distance_matrix_file, log = FALSE)
  ),
  # loop over response variables
  mapping,
  tar_combine(signals, mapping[[2]]),
  # fit regression model (no control)
  tar_target(
    fit_regression_no_control,
    fit_model(data, geographic_distance_matrix, linguistic_distance_matrix, 
              response = "ZCAF_5y_Donation", predictor = "hof_idv",
              control = FALSE)
  ),
  # fit regression model (with control)
  tar_target(
    fit_regression_with_control,
    fit_model(data, geographic_distance_matrix, linguistic_distance_matrix, 
              response = "ZCAF_5y_Donation", predictor = "hof_idv",
              control = TRUE)
  ),
  # plot signals
  tar_target(plot_signals, plot_signal(signals)),
  # plot model predictions
  tar_target(
    plot_no_control,
    plot_model(
      data,
      fit_regression_no_control,
      file = "plots/fit_no_control.png"
    )
  ),
  tar_target(
    plot_no_control_western_europe,
    plot_model(
      data,
      fit_regression_no_control,
      region_vars = "Western Europe",
      file = "plots/fit_no_control_western_europe.png"
    )
  ),
  tar_target(
    plot_no_control_central_america,
    plot_model(
      data,
      fit_regression_no_control,
      region_vars = "Central America",
      file = "plots/fit_no_control_central_america.png"
    )
  ),
  tar_target(
    plot_with_control,
    plot_model(
      data,
      fit_regression_with_control,
      file = "plots/fit_with_control.png"
    )
  ),
  # print session info
  tar_target(
    sessionInfo,
    writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
  )
)
