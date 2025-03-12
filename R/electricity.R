
# get_electricity_raw()
# function to pull EIA data based on parameters specified in electricity_mapping target

get_electricity_raw = function(electricity_mapping) {
  
  # open list to store data for each AEO year
  list_data_raw <- list()
  
  for (subdir in unique(electricity_mapping$subdirectory)) {
    for (data_val in unique(electricity_mapping$data)) {
      
      df = electricity_mapping %>%
        filter(subdirectory == subdir & data == data_val)
      
      data_raw = eia_data_big(
        dir = paste0("electricity/", unique(df$subdirectory)),
        freq = unique(df$frequency),
        data = unique(df$data),
        facets = list(
          fueltypeid = unique(df$fueltypeid),
          sectorid = unique(df$sectorid),
          location = unique(df$location)
        )
      )
      
      data_raw_clean = data_raw %>%
        pivot_longer(cols = .data[[data_val]], names_to = "data", values_to = "value") %>%
        rename_at(vars(matches('unit')), ~ 'unit') %>%
        select(data, everything())
      
      list_data_raw[[as.character(data_val)]] <- data_raw_clean %>%
        mutate(source = paste0(unique(electricity_mapping$source,"_",Sys.Date())))
      }
  }
  
  # put them all together
  all_data_raw <- data.table::rbindlist(list_data_raw) %>%
    select(source, everything())
  return(all_data_raw)
  
}


# map AEO raw data to IPCC-style variables
map_electricity_raw = function(electricity_raw, electricity_mapping) {
  
  data_mapped = electricity_mapping %>%
    mutate(sectorid = as.character(sectorid)) %>%
    left_join(electricity_raw, by = c("location","sectorid","fueltypeid","source","data"))
  
  data_cleaned = data_mapped %>%
    rename(year = period,
           model = source,
           region = location) %>%
    mutate(value = as.numeric(value) * multiplier,
           scenario = "historic") %>%
    filter(!is.na(variable)) %>%
    group_by(year,scenario,unit,variable,model,region) %>%
    summarise(value = sum(value)) %>%
    select(model,scenario,year,variable,unit,value,region)
  
  return(data_cleaned)
  
}
