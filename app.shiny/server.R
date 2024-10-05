#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

function(input, output, session) {
  
  # Filtrer les données pour le pays sélectionné
  country_data <- reactive({
    economy %>%
      filter(Pays == input$country)
  })
  
  # Générer un graphique de l'évolution dans le temps d'une variable sélectionnée
  output$timePlot <- renderPlot({
    var_selected <- input$variable
    
    # Utilisation du sous-ensemble traditionnel au lieu de `.data`
    ggplot(country_data(), aes(x = Annee, y = !!sym(var_selected), group = 1)) +
      geom_line(color = "blue") +
      geom_point(color = "red") +
      labs(title = paste("Évolution de", var_selected, "pour", input$country),
           x = "Année", y = var_selected) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Carte interactive avec Leaflet
  output$map <- renderLeaflet({
    # Choix de la variable pour la palette
    var_selected <- input$variable
    
    # Mise à jour du jeu de données pour inclure uniquement les pays avec des latitudes et longitudes non manquantes
    economy_pays <- economy %>%
      group_by(Pays) %>%
      slice(1) %>%
      filter(!is.na(lon) & !is.na(lat))
    
    # Générer une palette de couleurs basée sur la variable sélectionnée
    palette <- colorNumeric(palette = "YlOrRd", domain = economy_pays[[var_selected]], na.color = "transparent")
    
    # Créer la carte avec les cercles colorés selon la variable sélectionnée
    leaflet(economy_pays) %>%
      addTiles() %>%
      addCircleMarkers(
        ~lon, ~lat,
        popup = ~paste("Pays:", Pays, "<br>", var_selected, ":", economy_pays[[var_selected]]),
        color = ~palette(economy_pays[[var_selected]]),
        radius = 5,
        stroke = FALSE, fillOpacity = 0.8
      ) %>%
      addLegend("bottomright", pal = palette, values = economy_pays[[var_selected]],
                title = paste(var_selected, "(USD)"),
                opacity = 1)
  })
  
  
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
  

}


