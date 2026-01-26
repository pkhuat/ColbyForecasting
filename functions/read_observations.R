# functions/read_observations.R

read_observations <- function(scientificname = "Homarus americanus",
                              minimum_year = 1970,
                              basis_of_record = NULL,
                              minimum_individualCount = NULL,
                              ...) {
  
  # Read raw OBIS data (already clipped to Brickman domain by the fetch/read step)
  x <- read_obis(scientificname, ...) |>
    dplyr::mutate(month = factor(month, levels = month.abb))
  
  # REQUIRED filters (no user input needed)
  if ("eventDate" %in% names(x)) {
    x <- x |> dplyr::filter(!is.na(eventDate))
  }
  
  # OPTIONAL filters (only apply if user provides them)
  if (!is.null(minimum_year) && "year" %in% names(x)) {
    x <- x |> dplyr::filter(year >= minimum_year)
  }
  
  if (!is.null(basis_of_record) && "basisOfRecord" %in% names(x)) {
    x <- x |> dplyr::filter(basisOfRecord %in% basis_of_record)
  }
  
  if (!is.null(minimum_individualCount) && "individualCount" %in% names(x)) {
    x <- x |> dplyr::filter(!is.na(individualCount),
                            individualCount >= minimum_individualCount)
  }
  
  return(x)
}
