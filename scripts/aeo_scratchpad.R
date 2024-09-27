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
eia_metadata("aeo/2023")

# explore options for facets within a subdirectory
eia_facets("aeo/2023", "seriesId")


aeo = read_csv("AEO_mapping_template.csv") %>%
  mutate(Series_template = tolower(Series_template),
         Series_template = str_replace_all(Series_template, "_na", "_NA"))

seriesIDs = aeo$Series_template

aeo_pull = list()

for(i in length(seriesIDs)) {
  aeo_pull_i <- eia_data(
    dir = "aeo/2023",
    data = 'value',
    facets = c(scenario = 'ref2023',
               seriesId = seriesIDs[i]),
    freq = 'annual',
    start = '2025',
    end = '2035'
  )
  
  aeo_pull[[i]] = aeo_pull_i
}

aeo_pull_full = rbind(aeo_pull)















