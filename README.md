# Shiny - Visualisation des indicateurs économiques globaux

## Description du projet

Ce projet vise à explorer et visualiser des indicateurs économiques globaux à l'aide d'une application interactive développée en **R-Shiny**. L'application permet aux utilisateurs de :

-   explorer des données économiques pour différents pays sur plusieurs années;

-   générer des graphiques interactifs et des cartes pour comparer les performances économiques des pays;

-   appliquer des algorithmes de clustering pour regrouper des pays selon des indicateurs spécifiques.

L'objectif est de fournir un outil facile à utiliser pour l'analyse de données économiques et leur présentation visuelle.

## Jeu de Données

Le projet utilise le fichier `Glob_Economy_Ind.csv`, qui contient des indicateurs économiques clés pour différents pays. Les données couvrent la période de 1970 à 2021 et sont issues d'une source open data *National Accounts Main Aggregates Database*.

### Variables principales :

-   **Pays** : Le nom du pays.

-   **Annee** : L'année de l'enregistrement des données

-   **Population** : Nombre d'habitants dans le pays

-   **Produit Intérieur Brut (PIB)** : Valeur totale des biens et services produits dans le pays

-   **Revenu National Brut (RNB)** : Revenu total généré par les résidents d'un pays

-   **Taux de Change** : Taux de conversion de la monnaie locale en USD

-   **Exportation / Importation** : Valeur des biens et services exportés et importés par le pays

-   **Valeur Ajoutée (VA)** : Contribution des secteurs agricoles, industriels, et de services à l'économie

Les données permettent d'explorer des variables économiques majeures et leur évolution dans le temps.

## Fonctionnalités

### Visualisation Temporelle

-   Sélectionner un pays et un indicateur économique pour visualiser son évolution au fil du temps à l'aide de graphiques interactifs.

### Cartographie Interactive

-   Afficher une carte des pays en fonction d'un indicateur économique pour une année spécifique.

-   Modifier la palette de couleurs pour ajuster l'affichage visuel des données.

### Graphique Bivarié

-   Comparer deux indicateurs économiques pour un pays donné sous forme de graphique de dispersion.

### Clustering

-   Appliquer des techniques de clustering pour regrouper les pays en fonction de plusieurs indicateurs économiques.

-   Afficher les résultats du clustering avec un graphique PCA et un résumé des clusters.

## Structure des fichiers

-   `app.R` : Point d'entrée principal pour l'application Shiny

-   `global.R` : Chargement des données et préparation des variables globales

-   `ui.R` : Définition de l'interface utilisateur

-   `server.R` : Logique serveur pour le traitement des données et la génération des graphiques

-   `data` : Contient le fichier CSV des données économiques

-   `README.md` : Ce fichier, expliquant le projet

## Contributrices

<p align="right">

</p>

<a href="https://github.com/maudlesage/Shiny/graphs/contributors"> ![contrib.rocks image](https://contrib.rocks/image?repo=maudlesage/Shiny)

</a>

</p>

<!-- CONTACT -->

## Contact

Emma Da Costa Silva - emma.dacostasilva\@agrocampus-ouest.fr

Maud Lesage - maud.lesage\@agrocampus-ouest.fr

