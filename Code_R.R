library(data.table)

economy <- fread("Glob_Economy_Ind.csv", sep = ",", header = TRUE)
summary(economy)
head(economy)

#savoir combien il y a de données manquantes dans chaque variable
na_counts <- sapply(economy, function(x) sum(is.na(x)))
print(na_counts)


# suppression des colonnes inutiles :
# CountryID
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
