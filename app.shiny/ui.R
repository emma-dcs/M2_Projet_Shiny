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
  tags$h1("Indicateurs économiques globaux", style = "text-align: center; color: white;"),  # Couleur du texte du titre en blanc
  
  # Application d'un style CSS pour agrandir les onglets et ajouter un fond
  tags$style(HTML("
    body {
      background-color: #2c3e50;  /* Fond gris foncé */
      color: white;  /* Texte en blanc */
    }
    
    .nav-tabs > li > a {
      font-size: 18px;  /* Augmente la taille de la police */
      padding: 10px 20px;  /* Ajuste le padding pour plus d'espace */
      color: white;  /* Couleur du texte des onglets en blanc */
    }
    
    .nav-tabs > li.active > a {
      background-color: #b7950b;  /* Couleur de fond dorée pour l'onglet actif */
      color: white;  /* Couleur du texte en blanc pour l'onglet actif */
      border-color: #b7950b;  /* Assurer la même couleur pour la bordure */
    }
    
    .nav-tabs > li > a:hover {
      background-color: #b7950b;  /* Couleur de fond dorée au survol */
      color: #ffffff;  /* Couleur du texte blanche au survol */
    }
    
    .tab-content {
      background-color: #34495e;  /* Fond des panneaux gris un peu plus clair */
      padding: 20px;  /* Espace autour des contenus */
      border-radius: 8px;  /* Coins arrondis */
    }
  ")),
  
  # Suppression du sidebarLayout pour un affichage plein écran
  tabsetPanel(type = "tabs",
              tabPanel("Visualisation", 
                       # Sous-onglets pour visualisation
                       tabsetPanel(type = "tabs", 
                                   tabPanel("Données Temporelles", 
                                            # Options pour le graphique temporel
                                            selectInput("temp_country", "Choisissez un pays :", choices = sort(unique(economy$Pays))),
                                            selectInput("temp_variable", "Choisissez une variable :", 
                                                        # Liste complète des variables pour la visualisation
                                                        choices = c("Produit_Interieur_Brut_PIB", "Revenu_National_Brut_RNB", "Population", "Taux_de_change", 
                                                                    "Capital", "Exportation", "Importation")),
                                            selectInput("temp_color", "Choisissez une couleur :", 
                                                        choices = c("yellow", "purple", "green", "blue", "red", "black", "orange", "pink")),
                                            
                                            # Affichage du graphique temporel
                                            plotOutput("timePlot")  # Graphique temporel
                                   ),
                                   tabPanel("Carte", 
                                            # Ajout des sélections pour la variable et l'année
                                            selectInput("map_variable", "Choisissez une variable :", 
                                                        # Liste complète des variables pour la carte
                                                        choices = c("Produit_Interieur_Brut_PIB", "Revenu_National_Brut_RNB", "Population", "Taux_de_change", 
                                                                    "Capital", "Exportation", "Importation")),
                                            selectInput("map_year", "Choisissez une année :", choices = unique(economy$Annee)),
                                            
                                            # Ajout de la sélection pour la palette de couleurs
                                            selectInput("map_palette", "Choisissez une palette de couleurs :", 
                                                        choices = c("Super Dégradé", "YlOrRd", "Blues", "Greens", "Purples", "Reds", "BuPu", "GnBu")),
                                            
                                            # Affichage de la carte interactive
                                            leafletOutput("map")  # Carte interactive
                                   ),
                                   tabPanel("Graphique Bivarié", 
                                            h4("Options de Graphique Bivarié"),
                                            # Sélecteur pour la variable X
                                            selectInput("var_x", "Choisissez une variable pour l'axe X :", 
                                                        choices = c("Produit_Interieur_Brut_PIB", "Revenu_National_Brut_RNB", "Population", "Taux_de_change")),
                                            # Sélecteur pour la variable Y
                                            selectInput("var_y", "Choisissez une variable pour l'axe Y :", 
                                                        choices = c("Produit_Interieur_Brut_PIB", "Revenu_National_Brut_RNB", "Population", "Taux_de_change")),
                                            # Affichage du graphique bivarié
                                            plotOutput("bivariatePlot")  # Graphique bivarié
                                   )
                       )
              ),
              tabPanel("Clustering", 
                       h4("Options de Clustering"),
                       # Variables pour le clustering (sans "Capital", "Exportation", "Importation")
                       selectInput("cluster_vars", "Variables pour le clustering :", 
                                   choices = c("Produit_Interieur_Brut_PIB", "Revenu_National_Brut_RNB", "Population", "Taux_de_change"),  # Liste restreinte pour le clustering
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



















