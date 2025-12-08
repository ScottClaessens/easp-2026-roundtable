library(targets)
tar_option_set(packages = c("countrycode", "haven", "readxl", "tidyverse"))
tar_source()

# pipeline
list(
  # load gps data
  tar_target(data_file, "data/gps/country.dta", format = "file"),
  tar_target(data, load_gps_data(data_file)),
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
  # print session info
  tar_target(
    sessionInfo,
    writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
  )
)
