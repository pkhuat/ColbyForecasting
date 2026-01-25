# assignment_script_2.R
# C02 Background Coding Assignment - Homarus americanus

# Setup
source("setup.R")

# Read your model input (presence + background points)
model_input <- read_model_input(scientificname = "Homarus americanus")

# Step 1: Randomly select 1 presence and 1 background per month (24 points)
sampled_points <- model_input |>
  group_by(month, class) |>
  slice_sample(n = 1) |>
  ungroup() |>
  mutate(point = rep(c("p1", "p2"), times = 12))

# Step 2: Read Brickman present monthly data with depth
db <- brickman_database() |>
  filter(scenario == "PRESENT", interval == "mon")
brickman_data <- read_brickman(db, add = c("depth"))

# Step 3: Extract environmental values at each point
extracted_values <- extract_brickman(brickman_data, sampled_points, form = "wide")

# Step 4: Check what columns we got
names(extracted_values)

# Step 5: Add just the environmental columns to sampled points
result <- sampled_points |>
  bind_cols(extracted_values |> select(depth, SSS, SST, Tbtm))

# View the result
print(result, n = 24)
