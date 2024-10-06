#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#



# Assurez-vous d'avoir ces packages installés
# install.packages("FactoMineR")
# install.packages("factoextra")
library(FactoMineR)
library(factoextra)

function(input, output, session) {
  
  # Partie descriptive (inchangée)
  country_data <- reactive({
    economy %>%
      filter(Pays == input$country)
  })
  
  # Graphique temporel
  output$timePlot <- renderPlot({
    var_selected <- input$variable
    
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
    var_selected <- input$variable
    economy_pays <- economy %>%
      group_by(Pays) %>%
      slice(1) %>%
      filter(!is.na(lon) & !is.na(lat))
    
    palette <- colorNumeric(palette = "YlOrRd", domain = economy_pays[[var_selected]], na.color = "transparent")
    
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
  
  # Topogram
  output$topogramPlot <- renderPlot({
    cartogram_data <- reactive_cartogram()
    
    if (is.null(cartogram_data)) return(NULL)
    
    ggplot(cartogram_data) +
      geom_sf(aes(fill = .data[[input$variable]]), color = "green") +
      scale_fill_viridis_c(option = input$palette, name = input$variable) +
      labs(title = paste("Topogramme de", input$variable)) +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
  
  
  
  
  ### Partie clustering avec HCPC
  observeEvent(input$run_cluster, {
    req(input$cluster_vars)  # Vérifiez que les variables de clustering sont sélectionnées
    
    # Vérifiez que deux variables ou plus sont sélectionnées
    if (length(input$cluster_vars) < 2) {
      showNotification("Veuillez sélectionner au moins deux variables pour le clustering.", type = "error")
      return(NULL)
    }
    
    output$clusteringPlot <- renderPlot({
      # Extraire les données des variables sélectionnées
      data <- economy[, input$cluster_vars, drop = FALSE]
      
      # Vérifiez et nettoyez les données (supprimez les lignes avec des NA)
      data <- na.omit(data)
      
      # Assurez-vous qu'il y a assez de données après nettoyage
      if (nrow(data) < 2) {
        showNotification("Pas assez de données après nettoyage.", type = "error")
        return(NULL)
      }
      
      # Normaliser les données pour éviter que certaines variables dominent le clustering
      data_scaled <- scale(data)
      
      # Appliquer la PCA
      pca_result <- PCA(data_scaled, graph = FALSE)  # PCA sans graphique
      
      # Appliquer HCPC
      hcpc_result <- HCPC(pca_result, nb.clust = input$num_clusters, graph = FALSE)
      
      # Visualiser les résultats de clustering
      fviz_cluster(hcpc_result, geom = "point", ellipse.type = "convex") +
        labs(title = paste("Clustering HCPC avec", input$num_clusters, "clusters"))
    })
    
    # Résumé des clusters
    output$cluster_summary <- renderTable({
      data <- economy[, input$cluster_vars, drop = FALSE]
      
      # Vérifiez et nettoyez les données
      data <- na.omit(data)
      if (nrow(data) < 2) {
        showNotification("Pas assez de données après nettoyage.", type = "error")
        return(NULL)
      }
      
      # Normaliser les données
      data_scaled <- scale(data)
      
      # Appliquer la PCA
      pca_result <- PCA(data_scaled, graph = FALSE)  # PCA sans graphique
      
      # Appliquer HCPC
      hcpc_result <- HCPC(pca_result, nb.clust = input$num_clusters, graph = FALSE)
      
      # Créer un tableau de résumé des clusters
      cluster_summary <- as.data.frame(hcpc_result$data.clust)
      cluster_summary$cluster <- hcpc_result$clust
      return(cluster_summary)
    })
    
    output$country_clusters <- renderTable({
      data <- economy[, input$cluster_vars, drop = FALSE]
      data <- na.omit(data)
      
      if (nrow(data) < 2) {
        showNotification("Pas assez de données après nettoyage.", type = "error")
        return(NULL)
      }
      
      data_scaled <- scale(data)
      pca_result <- PCA(data_scaled, graph = FALSE)  # PCA sans graphique
      hcpc_result <- HCPC(pca_result, nb.clust = input$num_clusters, graph = FALSE)
      
      # Créer un tableau avec les pays et leurs clusters
      cluster_results <- data.frame(Pays = economy$Pays, cluster = hcpc_result$clust)
      return(cluster_results)
    })
  })
}











