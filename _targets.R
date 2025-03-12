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
  
  ## mapping 
  tar_target(aeo_mapping_csv, "mapping/aeo_mapping.csv", format = "file"),
  aeo_mapping = read_csv(aeo_mapping_csv),
  
  ## data 
  aeo_raw = get_aeo_raw(aeo_mapping, config),
  aeo_mapped = map_aeo_raw(aeo_raw, aeo_mapping),
  
  # Electricity Data Browser ----
  
  ## mapping 
  tar_target(electricity_mapping_csv, "mapping/electricity_mapping.csv", format = "file"),
  electricity_mapping = read_csv(electricity_mapping_csv),
  
  ## data 
  electricity_raw = get_electricity_raw(electricity_mapping), 
  electricity_mapped = map_electricity_raw(electricity_raw, electricity_mapping),
  
  # Emissions ----
  
  ## mapping 
  tar_target(emissions_mapping_csv, "mapping/emissions_mapping.csv", format = "file"),
  emissions_mapping = read_csv(emissions_mapping_csv),
  
  ## data 
  
  # International ----
  
  ## mapping
  tar_target(international_mapping_csv, "mapping/international_mapping.csv", format = "file"),
  international_mapping = read_csv(international_mapping_csv),
  
  ## data 
  
  # State Energy Data System ----
  
  ## mapping 
  tar_target(seds_mapping_csv, "mapping/seds_mapping.csv", format = "file"),
  seds_mapping = read_csv(seds_mapping_csv),
  
  ## data 
  
  # Total Energy - Annual Energy Review ----
  
  ## mapping 
  tar_target(totalenergy_mapping_csv, "mapping/totalenergy_mapping.csv", format = "file"),
  totalenergy_mapping = read_csv(totalenergy_mapping_csv)
  
  ## data 

)
