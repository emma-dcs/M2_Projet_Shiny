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



#Code du topogram qui fonctionne mais ne fait pas apparaitre la carte
##################################
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
  
  # Préparation des données pour le topogram
  economy_sf_data <- economy_sf() %>%
    filter(!is.na(!!sym(var_selected)))  # Filtrer les données manquantes pour la variable sélectionnée
  
  # Générer le topogram
  topogram_obj <- topogram(
    sfobj = economy_sf_data,
    value = var_selected,
    label = "Pays",
    palette = palette_selected
  )
  
  # Afficher le topogram
  plot(topogram_obj)
})
###########################"




reactive_cartogram <- reactive({
  req(input$variable)  # Vérifier que l'entrée existe
  
  # Déformer la carte en fonction de la variable choisie
  cartogram_cont(world, weight = input$variable)
})

# Générer et afficher le topogram
output$topogramPlot <- renderPlot({
  req(input$variable)  # Vérifier que l'entrée existe
  
  # Récupérer les données déformées
  cartogram_data <- reactive_cartogram()
  
  # Générer le graphique avec ggplot2
  ggplot(cartogram_data) +
    geom_sf(aes(fill = .data[[input$variable]]), color = "white") +
    scale_fill_viridis_c(option = input$palette, name = input$variable) +
    labs(title = paste("Topogramme de", input$variable)) +
    theme_minimal() +
    theme(legend.position = "bottom")
})


centroids <- centroids %>%
  mutate(PIB = gsub("\\s*\\(.*?\\)", "", PIB))


centroids[6,6]
#######
names(centroids)

observe({
  req(input$variable)  # Vérifie que l'entrée existe
  if (!(input$variable %in% names(centroids))) {
    showNotification("La variable choisie n'existe pas dans les données.", type = "error")
  }
})

is.numeric(filtered_centroids[[input$variable]])





##ligne 78 topogram 

# Vérifier qu'il y a au moins une ligne après le filtrage
if (nrow(filtered_centroids) == 0) {
  stop("Aucune donnée disponible pour l'année et la variable sélectionnées.")
} else if (nrow(filtered_centroids) > 1) {
  # Si plusieurs valeurs, calculer la moyenne
  weight_values <- filtered_centroids %>% 
    dplyr::summarise(mean_weight = mean(!!sym(input$variable), na.rm = TRUE)) %>% 
    print(mean_weight) %>%
    dplyr::pull(mean_weight)
} else {
  # Si une seule valeur, l'extraire directement
  weight_values <- filtered_centroids %>% dplyr::pull(!!sym(input$variable))
}


# Afficher les valeurs de poids pour déboguer
print(paste("Valeurs de poids extraites:", paste(weight_values, collapse = ", ")))

# Vérifiez si weight_values a plus d'une valeur
if (length(weight_values) > 1) {
  weight_values <- weight_values[1]
}

# Vérification de la valeur de poids avant de passer à cartogram_cont
if (length(weight_values) != 1 || is.na(weight_values) || !is.numeric(weight_values)) {
  stop("La valeur du poids n'est pas valide.")
}

print("Poids : ", weight_values)


###



filtered_centroids <- st_as_sf(filtered_centroids, coords = c("lon", "lat"), crs = 4326)

# Transformez les coordonnées en projection Mercator
f_c <- st_transform(filtered_centroids, crs = 3857)

#calcul des centroides dans le système projeté 
filtered_centroids <- st_point_on_surface(f_c)

fc <- st_transform(filtered_centroids, 26916)

fc <- fc %>%
  mutate(Population = gsub("\\s*\\(.*?\\)", "", Population))
fc <- fc %>%
  dplyr::mutate(Population = as.numeric(Population))
for (col in names(fc)) {
  if (is.numeric(fc[[col]])) {
    fc[[col]][is.na(fc[[col]])] <- 0
    fc[[col]] <- as.integer(ceiling(fc[[col]]))
    fc[[col]][is.na(fc[[col]])] <- 0
  }
}
fc_carto <- cartogram_cont(fc, weight = "Population", itermax = 5)


# Vérifier les valeurs infinies
infinite_values <- any(is.infinite(fc$Population))
print(paste("La colonne Population contient des valeurs infinies :", infinite_values))

#Vérifier les valeurs uniques
unique_values <- unique(fc$Population)
print(unique_values)


sum(is.na(fc$Population)) 
unique(fc$Population)

# Compter le nombre de NaN
nan_count <- sum(is.nan(fc$Population))
print(paste("Nombre de NaN dans Population :", nan_count))

# Vérifier la présence de NaN
contains_nan <- any(is.nan(fc$Population))
print(paste("La colonne Population contient des NaN :", contains_nan))
