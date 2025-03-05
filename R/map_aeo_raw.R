
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