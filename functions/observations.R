# functions/read_observations.R

read_observations <- function(scientificname = "Homarus americanus",
                              minimum_year = 1970,
                              basis_of_record = NULL,
                              minimum_individualCount = NULL,
                              ...) {
  
  # Reading raw OBIS data (fetch/read step already clips to Brickman domain)
  x <- read_obis(scientificname, ...) |>
    dplyr::mutate(month = factor(month, levels = month.abb))
  
  # REQUIRED filtering: eventDate can't be NA
  if ("eventDate" %in% names(x)) {
    x <- x |> dplyr::filter(!is.na(eventDate))
  }
  
  # OPTIONAL filtering: minimum year
  if (!is.null(minimum_year) && "year" %in% names(x)) {
    x <- x |> dplyr::filter(year >= minimum_year)
  }
  
  # OPTIONAL filtering: basisOfRecord
  if (!is.null(basis_of_record) && "basisOfRecord" %in% names(x)) {
    x <- x |> dplyr::filter(basisOfRecord %in% basis_of_record)
  }
  
  # OPTIONAL filtering: minimum individualCount
  if (!is.null(minimum_individualCount) && "individualCount" %in% names(x)) {
    x <- x |> dplyr::filter(!is.na(individualCount),
                            individualCount >= minimum_individualCount)
  }
  
  return(x)
}
