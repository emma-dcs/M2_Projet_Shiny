library(data.table)

economy <- fread("Glob_Economy_Ind.csv", sep = ",", header = TRUE)
summary(economy)
head(economy)

#savoir combien il y a de données manquantes dans chaque variable
na_counts <- sapply(economy, function(x) sum(is.na(x)))
print(na_counts)


# suppression des colonnes inutiles :
# CountryID
# Agriculture, hunting, forestry, fishing
# IMF based exchange rate (car identique a AMA exchange rate)
# changes in inventories

economy <- economy[, -c(1, 5, 9, 10)]
head(economy)

#transformer les variables year, currency et country en factor
economy$Year <- as.factor(economy$Year)
economy$Country <- as.factor(economy$Country)
economy$Currency <- as.factor(economy$Currency)
summary(economy)

