source("setup.R")
obs <- read_observations()   # now defaults to American lobster
dplyr::glimpse(obs)

# functions/observations.R
# Reads + filters OBIS observations for a species (default: American lobster)

read_]observations <- function(scientificname = "Homarus americanus",
                              minimum_year = 1970,
                              basis_of_record = NULL,
                              minimum_individualCount = NULL,
                              ...) {
  
  # 1) Reading raw OBIS data and order months Jan..Dec
  x <- read_obis(scientificname, ...) |>
    dplyr::mutate(month = factor(month, levels = month.abb))

  # REQUIRED filters 
  
  # A) eventDate can't be NA
  if ("eventDate" %in% names(x)) {
    x <- x |> dplyr::filter(!is.na(eventDate))
  }
  
  # B) points must be inside the Brickman domain (using bbox + geom)
  if ("geom" %in% names(x)) {
    
    DB <- brickman_database()
    
    db_mask <- DB |>
      dplyr::filter(interval == "static", var == "mask") |>
      dplyr::slice(1)
    
    mask <- read_brickman(db_mask)
    bb <- sf::st_bbox(mask)
    
    x <- x |>
      dplyr::filter(
        !is.na(geom),
        sf::st_coordinates(geom)[,1] >= bb["xmin"],
        sf::st_coordinates(geom)[,1] <= bb["xmax"],
        sf::st_coordinates(geom)[,2] >= bb["ymin"],
        sf::st_coordinates(geom)[,2] <= bb["ymax"]
      )
  }
  
  
  # OPTIONAL filters (I am controling)
  
  # C) minimum year
  if (!is.null(minimum_year) && "year" %in% names(x)) {
    x <- x |> dplyr::filter(year >= minimum_year)
  }
  
  # D) basisOfRecord filter
  if (!is.null(basis_of_record) && "basisOfRecord" %in% names(x)) {
    x <- x |> dplyr::filter(basisOfRecord %in% basis_of_record)
  }
  
  # E) minimum individualCount filter
  if (!is.null(minimum_individualCount) && "individualCount" %in% names(x)) {
    x <- x |> dplyr::filter(!is.na(individualCount), individualCount >= minimum_individualCount)
  }
  
  return(x)
}

