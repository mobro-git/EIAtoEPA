# pull in necessary packages
source('packages.R')

# you will need to have an EIA API key (if you do not have a key: https://www.eia.gov/opendata/register.php/)
# add EIA API key to renviron file: usethis::edit_r_environ(), EIA_KEY=your_api_key

# to see all directories accessible from the api:
eia_dir()

# see all subdirectories for a given directory - NONE for international
eia_dir("international")

# Once you have gotten to the deepest subdirectory, you'll get the following message (only once):
# No further sub-directories to discover.
# Use `eia_metadata("international")` to explore this data.
eia_metadata("international")

# explore options for facets within a subdirectory
productId = eia_facets("international", "productId")
activityId = eia_facets("international", "activityId")
countryRegionId = eia_facets("international", "countryRegionId")
countryRegionTypeId = eia_facets("international", "countryRegionTypeId")
dataFlagId = eia_facets("international", "dataFlagId")
unit = eia_facets("international", "unit")
