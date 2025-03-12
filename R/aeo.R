
# get_aeo_raw()
# function to pull EIA data based on years and scenarios specified in config target and seriesIds in aeo_mapping target

get_aeo_raw = function(aeo_mapping, config) {
  
  # open list to store data for each AEO year
  list_data_raw <- list()
  
  for(year in unique(config$aeo_yr)) {
    
    message("Sending request for AEO ", year)
    
    data_raw = eia_data_big(
      dir = paste0("aeo/",year),
      data = "value",
      facets = list(
        scenario = c(paste0("ref",year), config$aeo_scen),
        seriesId = unique(aeo_mapping$seriesId))
    )
    
    data_raw_clean = data_raw %>%
      mutate(vintage = paste0("AEO ",year))
    
    list_data_raw[[as.character(year)]] <- data_raw_clean
    
  }
  
  # put them all together
  all_data_raw <- data.table::rbindlist(list_data_raw) %>%
    select(vintage, everything())
  return(all_data_raw)
  
}


# map AEO raw data to IPCC-style variables
map_aeo_raw = function(aeo_raw, aeo_mapping) {
  
  data_mapped = aeo_raw %>%
    left_join(aeo_mapping, by = "seriesId")
  
  data_cleaned = data_mapped %>%
    rename(year = period,
           seriesName = seriesName.x,
           model = vintage) %>%
    select(-seriesName.y) %>%
    mutate(value = as.numeric(value) * multiplier) %>%
    filter(!is.na(variable)) %>%
    group_by(year,scenario,scenarioDescription,unit,category,variable,model) %>%
    summarise(value = sum(value)) %>%
    select(model,scenario,scenarioDescription,year,variable,unit,value,category)
  
  return(data_cleaned)
  
}