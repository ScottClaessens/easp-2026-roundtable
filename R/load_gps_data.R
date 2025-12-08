# function to load global preferences data
load_gps_data <- function(data_file) {
  # read stata file
  read_dta(file = data_file) |>
    # rename isocode column
    rename(iso3 = isocode) |>
    # get 2-digit iso code to match network data
    mutate(
      iso2 = countrycode::countrycode(
        sourcevar = iso3,
        origin = "iso3c",
        destination = "iso2c"
      )
    )
}
