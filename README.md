# House Price Modeling (Econometrics & Statistics) — King County (Seattle)

This repository contains my Statistics & Econometrics project on **house price modeling** using the **King County House Sales** dataset (Seattle area, 2014–2015).

## Project goals
- Understand the main factors that influence house prices
- Build an **OLS multiple linear regression** model
- Validate the model with proper **diagnostics** (VIF, heteroskedasticity tests, normality)
- Use **robust standard errors (White/HC3)** when assumptions are violated

## Repository structure
- **Rapport/** : final report (PDF)
- **Presentation/** : project slides (PPTX)
- **Code R/** : R scripts used for data prep, modeling and tests
- **References/** : papers / links / sources used
- **Dataset/** : dataset files (if included). If not present, see the note below.

## Dataset
The dataset used is **King County House Sales** (Seattle, USA, 2014–2015).  
If `Dataset/` is not included in this repo (file size), you can download it from the original public source ([Kaggle / public datasets](https://www.kaggle.com/datasets/harlfoxem/housesalesprediction)).

## How to run (R)
1. Open RStudio
2. Set the working directory to this repo folder
3. Run the scripts in `Code R/` (start with the main script if provided)

## Tools
- R / RStudio
- OLS regression + diagnostics (VIF, Breusch–Pagan, robust SE)

## Author
**Mohamed Ben Akka Ouayad**  
GitHub: https://github.com/akka-ben
