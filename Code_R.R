#remotes::install_github("JohnCoene/packer")
#packer::npm_install()
#packer::bundle()

remotes::install_github("dreamRs/topogram")
library(topogram)
library(sf)

economy_sf <- st_as_sf(economy, coords = c("lon", "lat"), crs = 4326)
economy_mercator <- st_transform(economy_sf, crs = 3857)
topogram(
  sfobj = economy_mercator,
  value = "Population",
  label = "{Pays}: {Population}",
  palette = "Blues",
  width = 400,
  height = 200
)
#il faudra permettre à l'utilisateur de changer la valeur de value
# et de modifier le Texte pour l'info-bulle

topogram(
  data = economy_mercator,           # Le jeu de données contenant les variables
  geojson = economy_sf,   # Coordonnées géographiques des pays (GeoJSON)
  key = "Pays",             # La correspondance des noms de pays
  value = Population
)


