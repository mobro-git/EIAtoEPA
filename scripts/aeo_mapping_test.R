# pull in necessary packages
source('packages.R')

macro = read_csv("mapping/aeo_mapping_new_macro_working.csv")
old = read_csv("mapping/aeo_mapping_orig_tested_reorg.csv")
all = rbind(macro, old)

all_reorg = all %>% arrange(seriesId)
write_csv(all_reorg, "mapping/aeo_mapping_combo.csv")

map = all_reorg
id_list = unique(map$seriesId) 
length(id_list)

# eia2_data_big() errors out under the following conditions:
# more than 126 seriesId passed into seriesId facet
data_eia2 = eia2_data_big(
  route = "aeo/2023",
  data_cols = "value",
  facets = list(
    scenario = c("ref2023","highogs"),
    seriesId = id_list[4:129]) #[3:128]
)

length(unique(data_eia2$seriesId))

data_eia3 = eia2_data_big(
  route = "aeo/2023",
  data_cols = "value",
  facets = list(
    scenario = c("ref2023","highogs"),
    seriesId = unique(map$seriesId)) 
)

data_eia4 = eia2_data_big(
  route = "aeo/2023",
  data_cols = "value",
  facets = list(
    scenario = c("ref2023","highogs"),
    seriesId = c("trad_imp_ten_NA_cr_NA_usa_qbtu","trad_imp_ten_NA_lfl_NA_usa_qbtu" )) 
)

#------------------------------------------------------------------------------

## test data to work with

map = read_csv("mapping/aeo_mapping_combo.csv")

data_raw = eia_data(
  dir = "aeo/2023",
  data = "value",
  facets = list(
    scenario = c("ref2023","highogs","lowogs"),
    seriesId = unique(map$seriesId))
)

data_mapped = data_raw %>%
  left_join(map, by = "seriesId")

data_cleaned = data_mapped %>%
  rename(year = period,
         seriesName = seriesName.x) %>%
  select(-seriesName.y) %>%
  mutate(value = as.numeric(value) * multiplier) %>%
  filter(!is.na(variable)) %>%
  group_by(year,scenario,scenarioDescription,unit,category,variable) %>%
  summarise(value = sum(value)) %>%
  mutate(model = "AEO") %>%
  select(model,scenario,scenarioDescription,year,variable,unit,value,category)

