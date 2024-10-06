#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


server <- function(input, output, session) {
  
  # Partie descriptive (inchangée)
  country_data <- reactive({
    economy %>%
      filter(Pays == input$temp_country)  # Utiliser le pays choisi dans l'onglet temporel
  })
  
  #graphique temporel
  output$timePlot <- renderPlot({
    var_selected <- input$temp_variable  # Utiliser la variable choisie dans l'onglet temporel
    
    # Créer la couleur en fonction de la sélection de l'utilisateur (input$temp_color)
    color_selected <- input$temp_color  # Couleur choisie
    
    ggplot(country_data(), aes(x = Annee, y = !!sym(var_selected), group = 1)) +
      geom_line(color = color_selected) +  # Appliquer la couleur de la sélection
      geom_point(color = color_selected) +  # Appliquer la couleur de la sélection
      labs(title = paste("Évolution de", var_selected, "pour", input$temp_country),
           x = "Année", y = var_selected) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            plot.title = element_text(hjust = 0.5, size = 20))  # Centre et agrandit le titre
  })
  
  #graphique bivarié
  output$bivariatePlot <- renderPlot({
    req(input$var_x, input$var_y)  # Assurez-vous que les variables sont sélectionnées
    
    ggplot(economy, aes_string(x = input$var_x, y = input$var_y)) +
      geom_point(color = "blue", alpha = 0.5) +  # Points de dispersion
      labs(title = paste("Graphique Bivarié de", input$var_y, "vs", input$var_x),
           x = input$var_x, y = input$var_y) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 20))  # Centre le titre
  })
  
  
  # Carte interactive avec Leaflet
  output$map <- renderLeaflet({
    req(input$map_variable)  # S'assurer qu'une variable de carte est sélectionnée
    req(input$map_year)      # S'assurer qu'une année est sélectionnée
    
    economy_pays <- economy %>%
      filter(Annee == input$map_year) %>%
      group_by(Pays) %>%
      slice(1) %>%
      filter(!is.na(lon) & !is.na(lat))
    
    custom_palette <- colorRampPalette(c("blue", "yellow", "red"))(100)
    
    palette <- if (input$map_palette == "Super Dégradé") {
      colorNumeric(
      palette = custom_palette, 
      domain = economy_pays[[input$map_variable]],
      na.color = "transparent")
    } else {
      colorNumeric(
        palette = input$map_palette, 
        domain = economy_pays[[input$map_variable]], 
        na.color = "transparent")
    }
                   
    
    leaflet(economy_pays) %>%
      addTiles() %>%
      addCircleMarkers(
        ~lon, ~lat,
        popup = ~paste("Pays:", Pays, "<br>", input$map_variable, ":", economy_pays[[input$map_variable]]),
        color = ~palette(economy_pays[[input$map_variable]]),
        radius = 5,
        stroke = FALSE, fillOpacity = 0.8
      ) %>%
      addLegend("bottomright", 
                pal = palette, 
                values = economy_pays[[input$map_variable]],
                title = if(input$map_variable == "Population") {
                  "Population"
                } else {
                  paste(input$map_variable, " (USD)")
                },
                opacity = 1)
  })
  
  # Partie clustering avec PCA
  observeEvent(input$run_cluster, {
    req(input$cluster_vars)  # Vérifiez que les variables de clustering sont sélectionnées
    
    # Extraire les données des variables sélectionnées
    data <- economy[, input$cluster_vars, drop = FALSE]
    
    # Vérifiez et nettoyez les données (supprimez les lignes avec des NA)
    data <- na.omit(data)
    
    # Assurez-vous qu'il y a assez de données après nettoyage
    if (nrow(data) < 2) {
      showNotification("Pas assez de données après nettoyage.", type = "error")
      return(NULL)
    }
    
    # Normaliser les données avant de faire la PCA
    data_scaled <- scale(data)  # Normalisation
    pca_result <- PCA(data_scaled, graph = FALSE)  # Effectuer la PCA
    
    # Effectuer le clustering
    set.seed(123)  # Pour la reproductibilité
    clusters <- kmeans(data_scaled, centers = input$num_clusters)
    
    # Ajouter les clusters au dataframe original
    economy$cluster <- as.factor(clusters$cluster)  # Assurez-vous que 'cluster' est de type factor
    
    # Tracer les individus sur le plan principal avec des couleurs différentes
    output$clusteringPlot <- renderPlot({
      fviz_pca_ind(pca_result, 
                   geom.ind = "point", 
                   pointsize = 2, 
                   col.ind = economy$cluster,  # Utilisez les clusters pour colorer les points
                   title = "Représentation des individus sur le plan principal") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5, size = 16),  # Centrer le titre
              legend.position = "bottom", 
              legend.title = element_blank()) +  # Enlever le titre de la légende
        scale_color_brewer(palette = "Set1")  # Choisir une palette de couleurs pour les clusters
    })
    
    # Graphique des variables PCA
    output$pcaVarPlot <- renderPlot({
      fviz_pca_var(pca_result, 
                   col.var = "black",  # Couleur des flèches des variables
                   title = "Représentation des variables sur le plan principal") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5, size = 16))  # Centrer le titre
    })
    
    # Résumé des clusters
    output$cluster_summary <- renderTable({
      cluster_summary <- data %>%
        mutate(cluster = economy$cluster) %>%
        group_by(cluster) %>%
        summarise(across(everything(), list(mean = mean, sd = sd), na.rm = TRUE))
      
      return(cluster_summary)
    })
    
    # Tableau des pays par cluster
    output$country_clusters <- renderTable({
      req(economy$cluster)  # Vérifiez que la colonne cluster existe
      
      # Créer un tableau avec le pays et le numéro de cluster
      data <- economy %>%
        select(Pays, cluster) %>%
        distinct() %>%
        arrange(cluster)  # Trier par cluster
      
      # Créer une nouvelle colonne pour chaque pays dans les clusters
      country_by_cluster <- data %>%
        group_by(cluster) %>%
        summarise(Pays = paste(Pays, collapse = ", ")) %>%
        ungroup()
      
      # Renommer les colonnes pour plus de clarté
      colnames(country_by_cluster)[1] <- "Cluster"
      
      return(country_by_cluster)
    })
  })
}

















