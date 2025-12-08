# function to load distance matrix
load_distance_matrix <- function(file, log = FALSE) {
  # load distances and convert to matrix
  distance_matrix <-
    read_excel(file, na = "") |>
    dplyr::select(-ISO) |>
    as.matrix()
  # set column and row names
  rownames(distance_matrix) <- colnames(distance_matrix)
  # log distances?
  if (log) {
    distance_matrix <- log(distance_matrix)
  }
  # distances between 0 and 1
  distance_matrix <- distance_matrix / max(distance_matrix)
  # country has zero distance from itself
  diag(distance_matrix) <- 0
  # return distance matrix
  distance_matrix
}
