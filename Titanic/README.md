# Titanic Kaggle Challenge

## Results
Given data about the passengers aboard the Titanic, I was able to predict their survival
with **~80% accuracy**.

Model: Ensemble Random Forest Tree

**Top 20% of competitors in challenge**

## Other Models
- Model 1: **76.6% Accuracy** (Logistic Regression) (Replacing NAs with Average of the column)
- Model 2: **78.4% Accuracy** (Basic Decision Tree)
- Model 3: **79.4% Accuracy** (Decision Tree, with Feature Engineering)
- Model 4: **76.6% Accuracy** (Logistic Regression) (Replaced NAs using Decision Trees)

## Learning Outcomes
- Missing data and how to handle it
  - How missing data affects logistic regression vs trees
- Tested out the workflow I designed (see main folder for workflow)
- Packages
  - Amelia (Handling and visualizing missing data)
  - rpart (Decision Trees)
  - randomForest
  - dplyr (Cleaning and manipulating data)
