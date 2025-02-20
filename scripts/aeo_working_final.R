# pull in necessary packages
source('packages.R')

#------------------------------------------------------------------------------

## test data to work with

map = read_csv("mapping/aeo_mapping.csv")

data_raw_5000_2023 = eia_data(
  dir = "aeo/2023",
  data = "value",
  facets = list(
    scenario = c("ref2023","highogs","lowogs"),
    seriesId = unique(map$seriesId))
)

data_raw_all_2023 = eia_data_big(
  dir = "aeo/2023",
  data = "value",
  facets = list(
    scenario = c("ref2023","highogs","lowogs"),
    seriesId = unique(map$seriesId))
)

data_mapped_2023 = data_raw %>%
  left_join(map, by = "seriesId")

data_cleaned_2023 = data_mapped %>%
  rename(year = period,
         seriesName = seriesName.x) %>%
  select(-seriesName.y) %>%
  mutate(value = as.numeric(value) * multiplier) %>%
  filter(!is.na(variable)) %>%
  group_by(year,scenario,scenarioDescription,unit,category,variable) %>%
  summarise(value = sum(value)) %>%
  mutate(model = "AEO 2023") %>%
  select(model,scenario,scenarioDescription,year,variable,unit,value,category)

data_raw_all_2022 = eia_data_big(
  dir = "aeo/2022",
  data = "value",
  facets = list(
    scenario = c("ref2022","highogs","lowogs"),
    seriesId = unique(map$seriesId))
)

data_mapped_2022 = data_raw %>%
  left_join(map, by = "seriesId")

data_cleaned_2022 = data_mapped %>%
  rename(year = period,
         seriesName = seriesName.x) %>%
  select(-seriesName.y) %>%
  mutate(value = as.numeric(value) * multiplier) %>%
  filter(!is.na(variable)) %>%
  group_by(year,scenario,scenarioDescription,unit,category,variable) %>%
  summarise(value = sum(value)) %>%
  mutate(model = "AEO 2022S") %>%
  select(model,scenario,scenarioDescription,year,variable,unit,value,category)

data_cleaned_2022_2023 = rbind(data_cleaned_2022,data_cleaned_2023)
