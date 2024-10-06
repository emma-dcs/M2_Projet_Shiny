#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


fluidPage(
  titlePanel("Visualisation des indicateurs économiques et Clustering"),
  
  # Organiser l'application en onglets
  tabsetPanel(
    
    # Onglet descriptif
    tabPanel(
      "Descriptif",
      
      sidebarLayout(
        sidebarPanel(
          selectInput("country", "Choisissez un pays :", choices = unique(economy$Pays)),
          selectInput("variable", "Choisissez une variable :", 
                      choices = c("PIB", "RNB", "Population", "Taux_change", 
                                  "Capital", "Exportation", "Importation")),
          selectInput("palette", "Choisissez une palette:", 
                      choices = c("viridis", "magma", "plasma", "inferno", "cividis")),
          selectInput("chartType", "Type de visualisation :", 
                      choices = c("Graphique temporel", "Carte avec Leaflet", "Topogram")),
          selectInput("year", "Choisissez une année :", choices = unique(economy$Annee))
        ),
        
        mainPanel(
          conditionalPanel(
            condition = "input.chartType == 'Graphique temporel'",
            plotOutput("timePlot")
          ),
          conditionalPanel(
            condition = "input.chartType == 'Carte avec Leaflet'",
            leafletOutput("map", height = 600)
          ),
          conditionalPanel(
            condition = "input.chartType == 'Topogram'",
            plotOutput("topogramPlot")
          )
        )
      )
    ),
    
    # Onglet de clustering
    tabPanel(
      "Clustering",
      
      sidebarLayout(
        sidebarPanel(
          selectInput("cluster_vars", "Variables pour le clustering :", 
                      choices = c("PIB", "RNB", "Population", "Taux_change", 
                                  "Capital", "Exportation", "Importation"),
                      multiple = TRUE),
          numericInput("num_clusters", "Nombre de clusters :", value = 3, min = 2, max = 10),
          actionButton("run_cluster", "Lancer le clustering")
        ),
        
        mainPanel(
          plotOutput("clusteringPlot", height = 500),
          tableOutput("cluster_summary"),
          fluidRow(
            box(tableOutput("country_clusters"), width = 12)
          )
        )
      )
    )
  )
)




