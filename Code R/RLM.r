==============================================================================
# PROJET : Analyse de la Régression Linéaire Multiple Avancée
# DATASET : King County House Sales (kc_house_data.csv)
# ==============================================================================

# 1. Installation et Chargement des Bibliothèques
# ------------------------------------------------------------------------------
packages <- c("tidyverse", "corrplot", "car", "lmtest", "ggplot2", 
              "glmnet", "leaps", "sandwich", "stargazer", "spdep", "sf")

# Installation des packages manquants
install.packages(setdiff(packages, rownames(installed.packages())))
lapply(packages, library, character.only = TRUE)

# 2. Importation et Préparation des Données
# ------------------------------------------------------------------------------
# Note : Nous utilisons une simulation réaliste basée sur les paramètres du dataset King County
set.seed(42)
n <- 10000

# Simulation des variables explicatives
data <- data.frame(
  sqft_living = rnorm(n, 2000, 800),
  bedrooms = sample(1:6, n, replace = TRUE),
  bathrooms = round(runif(n, 1, 4) * 4) / 4,
  floors = sample(c(1, 1.5, 2, 2.5, 3), n, replace = TRUE),
  waterfront = rbinom(n, 1, 0.01),
  view = sample(0:4, n, replace = TRUE),
  condition = sample(1:5, n, replace = TRUE),
  grade = sample(5:12, n, replace = TRUE),
  yr_built = sample(1900:2015, n, replace = TRUE),
  lat = rnorm(n, 47.5, 0.1),
  long = rnorm(n, -122.2, 0.1)
)

# Génération de la variable cible avec une structure log-linéaire et hétéroscédasticité
error_sd <- 0.2 * (1 + data$sqft_living / 4000) # Hétéroscédasticité liée à la surface
data$price <- exp(12 + 0.0005 * data$sqft_living + 0.1 * data$grade + 
                  0.5 * data$waterfront - 0.001 * (2015 - data$yr_built) + 
                  rnorm(n, 0, error_sd))

data$log_price <- log(data$price)

# Conversion des variables ordinales en facteurs
data <- data %>%
  mutate(grade = factor(grade),
         view = factor(view),
         condition = factor(condition))

# 3. Modélisation par Régression Linéaire Multiple (MCO)
# ------------------------------------------------------------------------------
model_mco <- lm(log_price ~ sqft_living + bedrooms + bathrooms + floors + 
                waterfront + view + condition + grade + yr_built + lat + long, 
                data = data)

# Affichage du résumé du modèle
summary(model_mco)

# 4. Diagnostics Avancés
# ------------------------------------------------------------------------------
# Multicolinéarité
vif_values <- vif(model_mco)
print("VIF Values:")
print(vif_values)

# Hétéroscédasticité (Test de Breusch-Pagan)
bp_test <- bptest(model_mco)
print("Breusch-Pagan Test:")
print(bp_test)

# Correction par Erreurs Standards Robustes (White)
robust_se <- coeftest(model_mco, vcov = vcovHC(model_mco, type = "HC3"))
print("Coefficients avec erreurs standards robustes:")
print(robust_se)

# 5. Régression Régularisée (Ridge et Lasso)
# ------------------------------------------------------------------------------
X <- model.matrix(model_mco)[,-1]
Y <- data$log_price

# Lasso (alpha = 1) avec Validation Croisée
cv_lasso <- cv.glmnet(X, Y, alpha = 1)
best_lambda_lasso <- cv_lasso$lambda.min
lasso_final <- glmnet(X, Y, alpha = 1, lambda = best_lambda_lasso)
print(paste("Lambda optimal pour Lasso:", best_lambda_lasso))

# Ridge (alpha = 0)
cv_ridge <- cv.glmnet(X, Y, alpha = 0)
best_lambda_ridge <- cv_ridge$lambda.min
ridge_final <- glmnet(X, Y, alpha = 0, lambda = best_lambda_ridge)
print(paste("Lambda optimal pour Ridge:", best_lambda_ridge))

# 6. Test de Moran pour l'Autocorrélation Spatiale (Exemple)
# ------------------------------------------------------------------------------
# Création d'un objet spatial
coords <- data.frame(x = data$long, y = data$lat)
# Définition de la matrice de pondération spatiale (voisins les plus proches)
# Note: Cette partie nécessite les vraies coordonnées et peut être coûteuse en calcul.
nb <- dnearneigh(as.matrix(coords), 0, 0.05) 
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)
moran_test <- moran.test(residuals(model_mco), lw, zero.policy = TRUE)
print("Test de Moran:")
print(moran_test)

# 7. Affichage des Résultats (Utilisation de stargazer pour un tableau LaTeX)
# ------------------------------------------------------------------------------
# Création d'un tableau de comparaison des modèles
stargazer(model_mco, type = "text", title = "Comparaison du Modèle MCO", 
          dep.var.labels = "Log(Prix)", out = "table_mco.txt")

# Fin du script