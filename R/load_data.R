# function to load data
load_data <- function(gps_data_file, rhoads_data_file, rhoads_isocodes_file) {
  # read gps stata file
  data_gps <-
    read_dta(file = gps_data_file) |>
    # rename isocode column
    rename(iso3 = isocode) |>
    # get 2-digit iso code to match network data
    mutate(
      iso2 = countrycode::countrycode(
        sourcevar = iso3,
        origin = "iso3c",
        destination = "iso2c"
      )
    ) |>
    select(!c(country, iso3))
  # read rhoads et al. (2021) data
  data_rhoads <-
    read_excel(rhoads_data_file) |>
    # remove northern cyprus
    filter(Country != "Northern Cyprus") |>
    # link to 2-digit iso codes
    left_join(read_excel(rhoads_isocodes_file), by = "Country") |>
    select(c(Country, ISO2, `ZCAF_5y_$`, ZCAF_5y_Volunteering, ZCAF_5y_Everyday,
             ZBlood_per_adult_capita, ZKidney_donors_pmp, ZMarrow_per_capita,
             ZAnimal_reversed_lohi, altruism_average)) |>
    rename(
      iso2 = ISO2,
      ZCAF_5y_Donation = `ZCAF_5y_$`
    )
  # link datasets
  left_join(
    data_rhoads,
    data_gps,
    by = "iso2"
  ) |>
    # standardise all numeric variables
    mutate(across(ZCAF_5y_Donation:trust, function(x) as.numeric(scale(x))))
}
