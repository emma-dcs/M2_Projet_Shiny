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
  # Titre centré 
  tags$h1("Indicateurs économiques globaux", style = "text-align: center; color: white;"),
  
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
  
  
  tabsetPanel(type = "tabs",
              tabPanel("Description", 
                       tabsetPanel(type = "tabs",
                                   tabPanel("Description du projet", 
                                            h2("Description du projet"),
                                            p("Ce projet vise à explorer et visualiser des indicateurs économiques globaux à l'aide d'une application interactive développée en ", strong("R-Shiny"), ". L'application permet aux utilisateurs de :"),
                                            tags$ul(
                                              tags$li("explorer des données économiques pour différents pays sur plusieurs années;"),
                                              tags$li("générer des graphiques interactifs et des cartes pour comparer les performances économiques des pays;"),
                                              tags$li("appliquer des algorithmes de clustering pour regrouper des pays selon des indicateurs spécifiques.")
                                            ),
                                            p("L'objectif est de fournir un outil facile à utiliser pour l'analyse de données économiques et leur présentation visuelle.")
                                   ),
                                   tabPanel("Jeu de Données", 
                                            h2("Jeu de Données"),
                                            p("Le projet utilise le fichier ", strong("Glob_Economy_Ind.csv"), ", qui contient des indicateurs économiques clés pour différents pays. Les données couvrent la période de 1970 à 2021 et sont issues d'une source open data ", em("National Accounts Main Aggregates Database"), "."),
                                            h3("Variables principales :"),
                                            tags$ul(
                                              tags$li(strong("Pays"), ": Le nom du pays."),
                                              tags$li(strong("Annee"), ": L'année de l'enregistrement des données."),
                                              tags$li(strong("Population"), ": Nombre d'habitants dans le pays."),
                                              tags$li(strong("Produit Intérieur Brut (PIB)"), ": Valeur totale des biens et services produits dans le pays."),
                                              tags$li(strong("Revenu National Brut (RNB)"), ": Revenu total généré par les résidents d'un pays."),
                                              tags$li(strong("Taux de Change"), ": Taux de conversion de la monnaie locale en USD."),
                                              tags$li(strong("Exportation / Importation"), ": Valeur des biens et services exportés et importés par le pays."),
                                              tags$li(strong("Valeur Ajoutée (VA)"), ": Contribution des secteurs agricoles, industriels, et de services à l'économie.")
                                            ),
                                            p("Les données permettent d'explorer des variables économiques majeures et leur évolution dans le temps.")
                                   ),
                                   tabPanel("Fonctionnalités", 
                                            h2("Fonctionnalités"),
                                            h3("Visualisation Temporelle"),
                                            p("Sélectionner un pays et un indicateur économique pour visualiser son évolution au fil du temps à l'aide de graphiques interactifs."),
                                            
                                            h3("Cartographie Interactive"),
                                            p("Afficher une carte des pays en fonction d'un indicateur économique pour une année spécifique. Modifier la palette de couleurs pour ajuster l'affichage visuel des données."),
                                            
                                            h3("Graphique Bivarié"),
                                            p("Comparer deux indicateurs économiques pour un pays donné sous forme de graphique de dispersion."),
                                            
                                            h3("Clustering"),
                                            p("Appliquer des techniques de clustering pour regrouper les pays en fonction de plusieurs indicateurs économiques. Afficher les résultats du clustering avec un graphique PCA et un résumé des clusters.")
                                   )
                       )
              ),
              tabPanel("Visualisation", 
                       # Sous-onglets pour visualisation
                       tabsetPanel(type = "tabs", 
                                   tabPanel("Données Temporelles", 
                                            # Options pour le graphique temporel
                                            selectInput("temp_country", "Choisissez un pays :", choices = sort(unique(economy$Pays))),
                                            selectInput("temp_variable", "Choisissez une variable :", 
                                                        # Liste complète des variables pour la visualisation
                                                        choices = c("Taux_de_change", "Population", "Monnaie", 
                                                                    "RNB_hab", "VA_agri", "VA_construction", "Exportation", "Depense_tot", "Depense_gouv", 
                                                                    "Capital", "Capital_fixe", "Depense_menage", "Importation", "VA_manufacture", "VA_public", "VA_autre",
                                                                    "VA_tot", "VA_transp", "VA_commerce", "Revenu_National_Brut_RNB", "Produit_Interieur_Brut_PIB")),
                                            selectInput("temp_color", "Choisissez une couleur :", 
                                                        choices = c("yellow", "purple", "green", "blue", "red", "black", "orange", "pink")),
                                            
                                            # Affichage du graphique temporel
                                            plotOutput("timePlot")
                                   ),
                                   tabPanel("Carte", 
                                            # Ajout des sélections pour la variable et l'année
                                            selectInput("map_variable", "Choisissez une variable :", 
                                                        # Liste complète des variables pour la carte
                                                        choices = c("Taux_de_change", "Population", "Monnaie", 
                                                                    "RNB_hab", "VA_agri", "VA_construction", "Exportation", "Depense_tot", "Depense_gouv", 
                                                                    "Capital", "Capital_fixe", "Depense_menage", "Importation", "VA_manufacture", "VA_public", "VA_autre",
                                                                    "VA_tot", "VA_transp", "VA_commerce", "Revenu_National_Brut_RNB", "Produit_Interieur_Brut_PIB")),
                                            selectInput("map_year", "Choisissez une année :", choices = unique(economy$Annee)),
                                            
                                            # Ajout de la sélection pour la palette de couleurs
                                            selectInput("map_palette", "Choisissez une palette de couleurs :", 
                                                        choices = c("Super Dégradé", "YlOrRd", "Blues", "Greens", "Purples", "Reds", "BuPu", "GnBu")),
                                            
                                            # Affichage de la carte interactive
                                            leafletOutput("map")
                                   ),
                                   tabPanel("Graphique Bivarié", 
                                            h4("Options de Graphique Bivarié"),
                                            selectInput("temp_country", "Choisissez un pays :", choices = sort(unique(economy$Pays))),
                                            # Ajout des sélections pour la variable X
                                            selectInput("var_x", "Choisissez une variable pour l'axe X :", 
                                                        choices = c("Annee", "Taux_de_change", "Population", "Monnaie", 
                                                                    "RNB_hab", "VA_agri", "VA_construction", "Exportation", "Depense_tot", "Depense_gouv", 
                                                                    "Capital", "Capital_fixe", "Depense_menage", "Importation", "VA_manufacture", "VA_public", "VA_autre",
                                                                    "VA_tot", "VA_transp", "VA_commerce", "Revenu_National_Brut_RNB", "Produit_Interieur_Brut_PIB")),
                                            # Ajout des sélections pour la variable Y
                                            selectInput("var_y", "Choisissez une variable pour l'axe Y :", 
                                                        choices = c("Annee", "Taux_de_change", "Population", "Monnaie", 
                                                                    "RNB_hab", "VA_agri", "VA_construction", "Exportation", "Depense_tot", "Depense_gouv", 
                                                                    "Capital", "Capital_fixe", "Depense_menage", "Importation", "VA_manufacture", "VA_public", "VA_autre",
                                                                    "VA_tot", "VA_transp", "VA_commerce", "Revenu_National_Brut_RNB", "Produit_Interieur_Brut_PIB")),
                                            # Affichage du graphique bivarié
                                            plotOutput("bivariatePlot") 
                                   )
                       )
              ),
              tabPanel("Clustering", 
                       h4("Options de Clustering"),
                       # Variables pour le clustering (sans "Capital", "Exportation", "Importation")
                       selectInput("cluster_vars", "Variables pour le clustering :", 
                                   choices = c("Taux_de_change", "Population", 
                                               "RNB_hab", "VA_agri", "VA_construction", "Depense_tot", "Depense_gouv", 
                                               "Capital_fixe", "Depense_menage", "VA_manufacture", "VA_public", "VA_autre",
                                               "VA_tot", "VA_transp", "VA_commerce", "Revenu_National_Brut_RNB", "Produit_Interieur_Brut_PIB"),  # Liste restreinte pour le clustering
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