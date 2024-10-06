#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Partie UI
ui <- fluidPage(
  # Titre centré avec le texte "Indicateurs économiques globaux"
  tags$h1("Indicateurs économiques globaux", style = "text-align: center;"),
  
  # Application d'un style CSS pour agrandir les onglets
  tags$style(HTML("
    .nav-tabs > li > a {
      font-size: 18px;  /* Augmente la taille de la police */
      padding: 10px 20px;  /* Ajuste le padding pour plus d'espace */
    }
    .nav-tabs > li.active > a {
      background-color: #007bff;  /* Couleur de fond pour l'onglet actif */
      color: white;  /* Couleur du texte pour l'onglet actif */
    }
    .nav-tabs > li > a:hover {
      background-color: #0056b3;  /* Couleur de fond au survol */
      color: white;  /* Couleur du texte au survol */
    }
  ")),
  
  # Suppression du sidebarLayout pour un affichage plein écran
  tabsetPanel(type = "tabs",
              tabPanel("Visualisation", 
                       # Sous-onglets pour visualisation
                       tabsetPanel(type = "tabs", 
                                   tabPanel("Données Temporelles", 
                                            # Options pour le graphique temporel
                                            selectInput("temp_country", "Choisissez un pays :", choices = unique(economy$Pays)),
                                            selectInput("temp_variable", "Choisissez une variable :", 
                                                        choices = c("PIB", "RNB", "Population", "Taux_change")),  # Variables mises à jour
                                            selectInput("temp_palette", "Choisissez une palette:", 
                                                        choices = c("viridis", "magma", "plasma", "inferno", "cividis")),
                                            
                                            # Affichage du graphique temporel
                                            plotOutput("timePlot")  # Graphique temporel
                                   ),
                                   tabPanel("Carte", 
                                            # Ajout des sélections pour la variable et l'année
                                            selectInput("map_variable", "Choisissez une variable :", 
                                                        choices = c("PIB", "RNB", "Population", "Taux_change")),  # Variables mises à jour
                                            selectInput("map_year", "Choisissez une année :", choices = unique(economy$Annee)),
                                            leafletOutput("map")  # Carte interactive
                                   )
                       )
              ),
              tabPanel("Clustering", 
                       h4("Options de Clustering"),
                       # Variables pour le clustering
                       selectInput("cluster_vars", "Variables pour le clustering :", 
                                   choices = c("PIB", "RNB", "Population", "Taux_change"),  # Variables mises à jour
                                   multiple = TRUE),
                       # Nombre de clusters
                       numericInput("num_clusters", "Nombre de clusters :", value = 3, min = 2, max = 10),
                       # Bouton pour lancer le clustering
                       actionButton("run_cluster", "Lancer le clustering"),
                       
                       # Sorties du clustering
                       textOutput("cluster_message"),   # Message par défaut
                       plotOutput("clusteringPlot"),   # Graphique de clustering
                       plotOutput("pcaVarPlot"),       # Graphique des variables PCA
                       tableOutput("cluster_summary"),  # Résumé des clusters
                       tableOutput("country_clusters")  # Tableau des pays par cluster
              )
  )
)


















