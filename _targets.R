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

list(
  
  # AEO mapping ----
  tar_target(aeo_mapping_new_macro_csv, ),
  tar_target()
  
  
  macro = read_csv("mapping/aeo_mapping_new_macro_working.csv")
  old = read_csv("mapping/aeo_mapping_orig_tested_reorg.csv")
  all = rbind(macro, old)
  
  all_reorg = all %>% arrange(seriesId)

)
