#remotes::install_github("JohnCoene/packer")
#packer::npm_install()
#packer::bundle()

remotes::install_github("dreamRs/topogram")

library(topogram)
library(sf)

missing_coords <- economy %>%
  filter(is.na(lon) | is.na(lat))

print(missing_coords)




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


# Charger les bibliothèques nécessaires
library(sf)
library(ggplot2)
library(viridis)
library(dplyr)
library(rlang)

# Créer un petit jeu de données
economy <- data.frame(
  Pays = c("France", "Allemagne", "Espagne", "Italie", "Belgique"),
  Population = c(65273511, 83783942, 46754778, 60244639, 11589623),
  lon = c(1.8883, 10.4515, -3.7038, 12.5674, 4.3517),
  lat = c(46.6034, 51.1657, 40.4168, 41.8719, 50.8503)
)

# Convertir le dataframe en objet sf
economy_sf <- st_as_sf(economy, coords = c("lon", "lat"), crs = 4326)

# Transformer en projection Mercator
economy_mercator <- st_transform(economy_sf, crs = 4326)

# Créer le topogram
topogram <- function(sfobj, value, label, palette) {
  ggplot(data = sfobj) +
    geom_sf(aes(fill = !!sym(value)), color = "white") +
    scale_fill_viridis_c(option = palette, name = value) +
    geom_sf_text(aes(label = glue::glue("{!!sym(label[1])}: {!!sym(label[2])}")), size = 3, na.rm = TRUE) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.margin = margin(10, 10, 10, 10)
    ) +
    labs(title = "Topogram des populations par pays", x = NULL, y = NULL)
}

# Générer le topogram
topogram(
  sfobj = economy_mercator,
  value = "Population",
  label = "paste(Pays, ':', Population)",
  palette = "D"
)

st_is_valid(economy_mercator)














# Créer le topogram
output$topogramPlot <- renderPlot({
  topogram(economy_mercator, "Population", c("Pays", "Population"), "D")
})

# Définir la fonction topogram
topogram <- function(sfobj, value, label, palette) {
  ggplot(data = sfobj) +
    geom_sf(aes(fill = !!sym(value)), color = "white") +
    scale_fill_viridis_c(option = palette, name = value) +
    geom_sf_text(aes(label = paste(!!sym(label[1]), ":", !!sym(label[2]))), size = 3, na.rm = TRUE) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.margin = margin(10, 10, 10, 10)
    ) +
    labs(title = "Topogram des populations par pays", x = NULL, y = NULL)
}















# Fonction pour créer le topogram
topogram <- function(sfobj, value, label, palette) {
  ggplot(data = sfobj) +
    geom_sf(aes(fill = !!sym(value)), color = "white") +
    scale_fill_viridis_c(option = palette, name = value) +
    geom_sf_text(aes(label = paste(!!sym(label[1]), ":", !!sym(label[2]))), size = 3, na.rm = TRUE) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.margin = margin(10, 10, 10, 10)
    ) +
    labs(title = "Topogram des populations par pays", x = NULL, y = NULL)
}

# Générer le topogram
output$topogramPlot <- renderPlot({
  topogram(
    sfobj = economy_mercator,
    value = "Population",
    label = c("Pays", "Population"),
    palette = "D"
  )
})

# Combiner les graphiques
output$combinedPlot <- renderPlot({
  topogram_plot <- topogram(
    sfobj = economy_mercator,
    value = "Population",
    label = c("Pays", "Population"),
    palette = "D"
  )
  
  # Vous pouvez ajuster le layout ici
  grid.arrange(output$map(), topogram_plot, ncol = 2)
})







#test 3
#topogram
topogram <- function(sfobj, value, label, palette) {
  ggplot(data = sfobj) +
    geom_sf(aes(fill = !!sym(value)), color = "white") +
    scale_fill_viridis_c(option = palette, name = value) +
    geom_sf_text(aes(label = !!sym(label)), size = 3, na.rm = TRUE) +  # Ajout des labels
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.margin = margin(10, 10, 10, 10)
    ) +
    labs(title = paste("Topogram de", value, "par pays"), x = NULL, y = NULL)
}

# Charger et préparer les données sf avec des coordonnées valides
economy_sf <- reactive({
  economy %>%
    filter(!is.na(lon) & !is.na(lat)) %>%  # Suppression des NA dans les coordonnées
    st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
    st_transform(crs = 3857)  # Transformation en projection Mercator
})

# Générer le topogram et l'afficher
output$topogramPlot <- renderPlot({
  # Récupérer les variables sélectionnées
  var_selected <- input$variable
  palette_selected <- input$palette
  
  # Vérification que la palette est bien une chaîne de caractère unique
  if (!palette_selected %in% c("A", "B", "C", "D", "E")) {
    palette_selected <- "D"  # Mettre une valeur par défaut si non valide
  }
  
  # Appeler la fonction topogram avec les données transformées
  topogram(
    sfobj = economy_sf(),
    value = var_selected,
    label = "Pays",
    palette = palette_selected
  )
})
