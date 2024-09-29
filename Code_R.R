library(data.table)

economy <- fread("Glob_Economy_Ind.csv", sep = ",", header = TRUE)
summary(economy)
head(economy)

#savoir combien il y a de données manquantes dans chaque variable
na_counts <- sapply(economy, function(x) sum(is.na(x)))
print(na_counts)


# suppression des colonnes inutiles :
# CountryID (car une autre colonne contient les noms des pays)
# AMA exchange rate (car identique a IMF based exchange rate)
# changes in inventories (car il n'y a pas de données)

economy <- economy[, -c(1, 4, 10)]
head(economy)

#transformer les variables year, currency et country en factor
economy$Year <- as.factor(economy$Year)
economy$Country <- as.factor(economy$Country)
economy$Currency <- as.factor(economy$Currency)
summary(economy)

#modifier le nom des colonnes
colnames(economy) <- c("Pays", "Annee", "Taux_change", "Population", "Monnaie", 
                       "RNB_hab", "VA_agri", "VA_construction", "Exportation", "Depense_tot", "Depense_gouv", 
                       "Capital", "Capital_fixe", "Depense_menage", "Importation", "VA_manufacture", "VA_public", "VA_autre",
                       "VA_tot", "VA_transp", "VA_commerce", "RNB", "PIB")

#changer l'ordre des variables
library(dplyr)

economy <- economy %>%
  select(Pays, Annee, Population, Monnaie, Taux_change, PIB, RNB, RNB_hab, 
         Capital, Capital_fixe, Exportation, Importation, Depense_tot, 
         Depense_gouv, Depense_menage, VA_tot, VA_agri, VA_commerce, 
         VA_construction, VA_manufacture, VA_public, VA_transp, VA_autre)

print(economy)

###Obtenir les coordonnées de chaque pays
library(rnaturalearth)
library(sf)

#Nettoyer les données de la colonne pays 
economy <- economy %>%
  mutate(Pays = gsub("\\s*\\(.*?\\)", "", Pays))

# Charger les données géographiques des pays
world <- ne_countries(scale = "medium", returnclass = "sf")

# Calculer les centroïdes et extraire les coordonnées
world$centroid <- st_centroid(world$geometry)
world_coords <- world %>%
  mutate(lon = st_coordinates(centroid)[, 1],
         lat = st_coordinates(centroid)[, 2]) %>%
  select(subunit, sovereignt, admin, geounit, name, name_long, brk_name, formal_en, lon, lat)  # Garder uniquement les colonnes nécessaires

# Vérifier les noms des pays dans le jeu de données
economy <- economy %>%
  mutate(Pays = ifelse(Pays == "D.R. of the Congo", "Democratic Republic of the Congo", Pays)) %>%
  mutate(Pays = ifelse(Pays == "State of Palestine", "Palestine", Pays)) %>%
  mutate(Pays = ifelse(Pays == " China, Hong Kong SAR ", "Hong Kong", Pays))%>%
  mutate(Pays = ifelse(Pays == "D.P.R. of Korea", "Democratic People's Republic of Korea", Pays))%>%
  mutate(Pays = ifelse(Pays == "Lao People's DR", "Laos", Pays))%>%
  mutate(Pays = ifelse(Pays == " China, Macao SAR ", "Macao", Pays))%>%
  mutate(Pays = ifelse(Pays == "Former Netherlands Antilles", "Sint Maarten", Pays))%>%
  mutate(Pays = ifelse(Pays == "St. Vincent and the Grenadines", "Saint Vincent and the Grenadines", Pays))%>%
  mutate(Pays = ifelse(Pays == "Viet Nam", "Vietnam", Pays))%>%
  mutate(Pays = ifelse(Pays == "Eswatini", "eSwatini", Pays))%>%
  mutate(Pays = ifelse(Pays == "Türkiye", "Turkey", Pays))%>%
  mutate(Pays = ifelse(Pays == "U.R. of Tanzania: Mainland", "Tanzania", Pays))%>%
  mutate(Pays = ifelse(Pays == "Yemen Democratic", "Yemen", Pays))%>%
  mutate(Pays = ifelse(Pays == "Yemen Arab Republic", "Yemen", Pays))%>%
  mutate(Pays = ifelse(Pays == "Zanzibar", "Tanzania", Pays))


# Initialiser un data frame pour conserver les coordonnées
coordinates <- data.frame()

#jointure unique
coordinates <- economy %>%
  left_join(world_coords %>% select(subunit, lon, lat), by = c("Pays" = "subunit"))%>%
  left_join(world_coords %>% select(name, lon, lat), by = c("Pays" = "name"))%>%
  left_join(world_coords %>% select(sovereignt, lon, lat), by = c("Pays" = "sovereignt"))%>%
  left_join(world_coords %>% select(admin, lon, lat), by = c("Pays" = "admin"))%>%
  left_join(world_coords %>% select(geounit, lon, lat), by = c("Pays" = "geounit"))%>%
  left_join(world_coords %>% select(name_long, lon, lat), by = c("Pays" = "name_long"))%>%
  left_join(world_coords %>% select(brk_name, lon, lat), by = c("Pays" = "brk_name"))%>%
  left_join(world_coords %>% select(formal_en, lon, lat), by = c("Pays" = "formal_en"))%>%
  mutate(
  lon = coalesce(lon.x, lon.y, lon.x.x, lon.y.y, lon.x.x.x, lon.y.y.y, lon.x.x.x.x, lon.y.y.y.y),
  lat = coalesce(lat.x, lat.y, lat.x.x, lat.y.y, lat.x.x.x, lat.y.y.y, lat.x.x.x.x, lat.y.y.y.y),
  geometry = coalesce(geometry.x, geometry.y, geometry.x.x, geometry.y.y, geometry.x.x.x, geometry.y.y.y, geometry.x.x.x.x, geometry.y.y.y.y)
  ) %>%
  # Retirer les colonnes temporaires
  select(-matches("^lon\\.|^lat\\.|^geometry\\.")) %>%
  select(-geometry)


# Ne garder que les colonnes du jeu de données economy avec lon et lat
economy <- coordinates %>%
  select(everything(), lon, lat)

# Identifier les lignes où lon et lat sont NA
na_rows <- economy %>%
  filter(is.na(lon) | is.na(lat)) %>%
  select(1)  

# Afficher les résultats
if (nrow(na_rows) > 0) {
  print("Les lignes avec des NA dans lon ou lat correspondent aux pays suivants :")
  print(na_rows)
} else {
  print("Aucun NA trouvé dans lon et lat.")
}
###il manque la position pour la Yugoslavie, Czechoslovakia et USSR


# ajout des coordonnées pour ces 3 pays qui n'existent plus 
# Ajouter les coordonnées manquantes pour Yugoslavie, Czechoslovakia, et USSR
economy$lon[economy$Pays == "Yugoslavie"] <- 20.4633
economy$lat[economy$Pays == "Yugoslavie"] <- 44.8176

economy$lon[economy$Pays == "Czechoslovakia"] <- 14.4378
economy$lat[economy$Pays == "Czechoslovakia"] <- 50.0755

economy$lon[economy$Pays == "USSR"] <- 37.6173
economy$lat[economy$Pays == "USSR"] <- 55.7558

economy$lon[economy$Pays == "France"] <- 1.8883
economy$lat[economy$Pays == "France"] <- 46.6034


# Vérifier les coordonnées ajoutées pour ces pays
economy[economy$Pays %in% c("Yugoslavie", "Czechoslovakia", "USSR"), ]




# Créer une carte simple pour visualiser les pays du jeu de données ######################################################################
#installer le package "htmlwidgets", "devtools", "leaflet", "dplyder" ##############################################
library(leaflet)

# Garder la première occurrence de chaque pays
economy_pays <- economy %>%
  group_by(Pays) %>%
  slice(1) # ou slice(n()) pour la dernière occurrence


# Créer la carte avec un seul marqueur par pays

leaflet(economy_pays) %>%
  addTiles() %>%
  addMarkers(~lon, ~lat, popup = ~Pays)


###############################################################################################"







