#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#



# Define UI for application that draws a histogram
fluidPage(
  titlePanel("Visualisation des indicateurs économiques"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Choisissez un pays :", choices = unique(economy$Pays)),
      selectInput("variable", "Choisissez une variable :", 
                  choices = c("PIB", "RNB", "Population", "Taux_change", 
                              "Capital", "Exportation", "Importation")),
      selectInput("chartType", "Type de visualisation :", 
                  choices = c("Graphique temporel", "Carte avec Leaflet"))
    ),
    
    mainPanel(
      conditionalPanel(
        condition = "input.chartType == 'Graphique temporel'",
        plotOutput("timePlot")
      ),
      conditionalPanel(
        condition = "input.chartType == 'Carte avec Leaflet'",
        leafletOutput("map", height = 600)  # Espace réservé pour la carte
      )
    )
  )
)
