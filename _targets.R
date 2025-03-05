# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) 

source("packages.R")

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Set target options:
tar_option_set(
  packages = c("dplyr","readr","tidyverse","datasets","eia"), # packages to make available to targets
  error = "abridge"
)

tar_plan(
  
  # config ----
  config = list(
    aeo_yr = c(2019, 2020, 2021, 2022, 2023),
    aeo_scen = c( # !!! reference scenarios automatically selected
      # high and low oil and gas supply
      "highogs", "lowogs",
      # high and low economic growth
      "highmacro", "lowmacro"
      )
  ),
  
  # AEO ----
  
  ## mapping ----
  tar_target(aeo_mapping_csv, "mapping/aeo_mapping.csv", format = "file"),
  aeo_mapping = read_csv("mapping/aeo_mapping.csv"),
  
  ## data ----
  aeo_raw = get_aeo_raw(aeo_mapping, config),
  aeo_mapped = map_aeo_raw(aeo_raw, aeo_mapping)

)
