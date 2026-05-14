# Device Usage Classification
Machine learning project for analyzing and classifying household device usage patterns using real-world time-series data.
The project combines SQL-based data validation, feature engineering, PCA, clustering, and supervised learning models.

## Project Overview
This project explores electricity consumption patterns of household devices and applies machine learning techniques to:
- Analyze daily and weekly usage behavior
- Reduce dimensionality using PCA
- Identify usage patterns through clustering
- Build classification models to predict usage groups

## Workflow
The project is structured as a complete data science pipeline:
1. Explanatory Data Analysis (EDA)
- SQL-based data validation and aggregation
- Visualization of daily and weekly usage patterns
2. Feature Engineering & PCA
- Creation of daily aggregated features
- Scaling and dimensionality reduction using PCA
3. Clustering
- K-means clustering on PCA components
- Identification of usage pattern groups
4. Supervised Classification
- Decision Tree
- Random Forest
- K-Nearest Neighbors (KNN)
- Model performance comparison

## Key Results
- Typical Daily Usage
- Typical Weekly Usage
- PCA Projection
- Clustering Results
- Model Comparison

## Project Structure
data/
- typical_day.csv
- typical_week.csv

scripts/
- 01_explanatory_visualization.R
- 02_feature_engineering_pca.R
- 03_clustering_analysis.R
- 04_supervised_classification.R

sql/
- eda_analysis.sql

results/
- plots and visual outputs

## Data
The original dataset used in this project is not included due to data access restrictions.
The repository includes derived dataets:
- typical_day.csv
- typical_week.csv

Technologies Used
- R (tidyverse, caret, randomForest, rpart etc.)
- SQL
- Data visualization (ggplot2)

## Key Insights
- Distinct usage patterns can be identified using clustering on PCA-transformed features
- Dimensionality reduction effectively captures most variance in a few components
- Random Forest outperforms simpler models in classification accuracy

## Notes
This project was developed as part of a data analysis and machine learning coursework.
