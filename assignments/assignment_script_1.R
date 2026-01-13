# assignment_script_1.R
# Coding Assignment 5
# Goal: RCP4.5 (2055) SST at buoy M01 vs month

# 1) Seting up (loads packages + Brickman helper functions)
source("setup.R")

library(dplyr)
library(ggplot2)

# 2) Loading buoy locations + Brickman database
buoys_all <- gom_buoys()
DB <- brickman_database()

# 3) Keeping only buoy M01
buoy_m01 <- buoys_all |> filter(id == "M01")
if (nrow(buoy_m01) != 1) stop("Could not uniquely identify buoy M01 in gom_buoys().")

# 4) Scenario/year filter (the database usually uses 'RCP45' not 'RCP4.5')
scenario_target <- "RCP45"
if (!scenario_target %in% unique(DB$scenario)) scenario_target <- "RCP4.5"

db <- DB |>
  filter(
    scenario == scenario_target,
    year == "2055",
    interval == "mon"
  )

# 5) Reading monthly Brickman data into a stars object
covars <- read_brickman(db)

# 6) Extracting the point time-series at buoy M01 (wide form gives SST column)
x <- extract_brickman(covars, buoy_m01, form = "wide")

# 7) Making sure months plot in Jan..Dec order (not alphabetical)
x <- x |> mutate(month = factor(month, levels = month.abb))

# 8) Plotting SST vs month
p <- ggplot(x, aes(x = month, y = SST)) +
  geom_point() +
  labs(
    title = "RCP4.5 2055 SST at buoy M01",
    x = "Month",
    y = "SST (C)"
  )
print(p)


ggsave("images/M01_SST.png", plot = p, width = 7, height = 4)
