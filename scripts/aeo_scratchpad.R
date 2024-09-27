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


aeo_test <- eia_data(
  dir = "aeo/2023",
  data = 'value',
  facets = c(scenario = 'ref2023',
             seriesId = 'emi_co2_ten_NA_NA_NA_NA_millmetnco2'),
  freq = 'annual',
  start = '2025',
  end = '2035'
)

test = tolower("EMI_CO2_TEN_NA_NA_NA_NA_MILLMETNCO2")
