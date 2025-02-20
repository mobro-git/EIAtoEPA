# pull in necessary packages
source('packages.R')

# you will need to have an EIA API key (if you do not have a key: https://www.eia.gov/opendata/register.php/)
# add EIA API key to renviron file: usethis::edit_r_environ(), EIA_KEY=your_api_key

# to see all directories accessible from the api:
eia_dir()

# see all subdirectories for a given directory, e.g. AEO
eia_dir("aeo")

# for each additional directory level/sublevel, keep exploring by adding "/"
eia_dir("aeo/2023")

# Once you have gotten to the deepest subdirectory, you'll get the following message (only once):
# No further sub-directories to discover.
# Use `eia_metadata("aeo/2023")` to explore this data.

# explore data available in a subdirectory
meta <- eia_metadata("aeo/2023")

# explore options for facets within a subdirectory
aeo_history = eia_facets("aeo/2023", "history")
aeo_scenario = eia_facets("aeo/2023", "scenario")
aeo_tableId = eia_facets("aeo/2023", "tableId")
aeo_seriesId = eia_facets("aeo/2023", "seriesId")
aeo_regionId = eia_facets("aeo/2023", "regionId")

# possible way to specify parameters for eia_data() function

# (1) 
aeo_dir = c("aeo/2023", "aeo/2022", "aeo/2021")
aeo_2023_scen = c("ref2023", "highogs", "lowogs", "lowmacro", "highmacro")

# (2) 
aeo_2023 = list(
  dir = "aeo/2023",
  scen = c("ref2023", "highogs", "lowogs", "lowmacro", "highmacro")
)
aeo_2022 = list(
  dir = "aeo/2022",
  scen = c("ref2022", "highogs", "lowogs", "lowmacro", "highmacro")
)





aeo_old = read_csv("AEO_mapping_template_newAPI.csv") %>%
  mutate(Series_template = tolower(Series_template),
         Series_template = str_replace_all(Series_template, "_na", "_NA")) 
write_csv(aeo_old, "mapping/aeo_mapping.csv")
aeo = read_csv("mapping/aeo_mapping.csv")

test123 = aeo %>%
  select(Series_Name,Series_template) %>%
  rename(id = Series_template) %>%
  distinct(id, Series_Name) %>%
  left_join(aeo_seriesId, by = "id")

seriesIDs = aeo$Series_template

aeo_pull = list()

for(i in length(seriesIDs)) {
  aeo_pull_i <- eia_data(
    dir = "aeo/2023",
    data = 'value',
    facets = c(scenario = 'ref2023',
               seriesId = seriesIDs[i],
               regionId = "United States"),
    freq = 'annual',
    start = '2025',
    end = '2035'
  )
  
  aeo_pull[[i]] = aeo_pull_i
}

aeo_pull_full = rbind(aeo_pull)


# single id test
pet_import_seriesid = "trad_imp_ten_NA_cr_NA_usa_qbtu"

aeo_pull_i <- eia_data(
  dir = "aeo/2023",
  data = 'value',
  facets = c(scenario = 'ref2023',
             seriesId = "trad_imp_ten_NA_cr_NA_usa_qbtu",
             regionId = "United States")
  # ,
  # freq = 'annual',
  # start = '2025',
  # end = '2035'
)

test = eia_data(dir = "aeo/2023",
         facets = c(scenario = "ref2023",
                    seriesId = "trad_imp_ten_NA_cr_NA_usa_qbtu"),
         freq = 'annual',
         start = '2022',
         end = '2050')

test_sm = eia_data(dir = "aeo/2023",
                facets = c(scenario = "ref2023",
                           seriesId = "trad_imp_ten_NA_cr_NA_usa_qbtu"))


usa = aeo_seriesId %>% filter(str_detect(id, "_usa")) %>% head(5)

ind = eia_data(
  dir = "aeo/2023",
  facets = list(
    scenario = c("ref2023","highogs"),
    seriesId = unique(usa$id))
)

tbl = eia_data(
  dir = "aeo/2023",
  facets = list(
    scenario = c("ref2023","highogs","lowogs","highmacro","lowmacro"),
    tableId = 9)
)

tbl2 = eia_data(
  dir = "aeo/2023",
  facets = list(
    scenario = c("ref2023","highogs","lowogs","highmacro","lowmacro"),
    tableId = 9),
  offset=5000
)

###


tbl3 = eia2_data_big(
  route = "aeo/2023",
  data_cols = "value",
  facets = list(
    scenario = c("ref2023","highogs","lowogs","highmacro","lowmacro"),
    tableId = 9)
)

tbl4 = eia2_data_big(
  route = "aeo/2023",
  data_cols = "value",
  facets = list(
    scenario = c("ref2023"),
    seriesId = unique(aeo$Series_template))
)



# errors out, doesnt seem that you can supply multiple scenarios and multiple seriesId, only one can have multiples?
tbl5 = eia2_data_big(
  route = "aeo/2023",
  data_cols = "value",
  facets = list(
    scenario = c("ref2023","highogs"),
    seriesId = unique(aeo$Series_template))
)

tbl6 = eia_data(
  dir = "aeo/2023",
  facets = list(
    scenario = c("ref2023","highogs","lowogs","highmacro","lowmacro"),
    seriesId = unique(aeo$Series_template))
)



