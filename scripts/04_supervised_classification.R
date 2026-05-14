#Device usage classification using supervised learning
#For reproducibility purposes, the preprocessing, PCA
#and clustering stages are repeated here before
#supervised classification.
#Loading packages
library(tidyverse)
library(lubridate)
library(janitor)
library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)

#Part 1: Data Preprocessing
#Loading the dataset.
device_usage <- read.csv("device_classification_data.csv")

#Creating a new column containing only the dates.
device_usage <- device_usage |> 
  mutate(Time = ymd_hms(Time, tz = "UTC"),
         date = as.Date(Time)) |>
  clean_names()

#Extracting daily features for each device.
daily_features <- device_usage |>
  group_by(date) |>
  summarise(
    fridge_mean = mean(fridge, na.rm = TRUE),
    dishwasher_mean = mean(dishwasher, na.rm = TRUE),
    tumbledryer_mean = mean(tumble_dryer, na.rm = TRUE),
    washingmachine_mean = mean(washing_machine, na.rm = TRUE),
    kettle_mean = mean(kettle, na.rm = TRUE),
    .groups = "drop"
  )

#Part 2: PCA
#Scaling the data.
daily_scaled <- daily_features |>
  select(-date) |>
  scale()

#Performing PCA on the scaled data.
pca <- prcomp(daily_scaled, center = FALSE, scale. = FALSE)

pca_df <- as.data.frame(pca$x)
pca_df$date <- daily_features$date

#Part 3: Clustering
#Keeping the first two principal components for clustering.
pca_cluster_data <- pca_df |>
  select(PC1, PC2)

set.seed(123)
kmeans_result <- kmeans(pca_cluster_data, centers = 3, nstart = 25)

pca_df$cluster <- as.factor(kmeans_result$cluster)

#Part 4: Classification
#Creating classification dataset
cluster_analysis <- daily_features
cluster_analysis$cluster <- pca_df$cluster

classification_data <- cluster_analysis |>
  select(
    fridge_mean,
    dishwasher_mean,
    tumbledryer_mean,
    washingmachine_mean,
    kettle_mean,
    cluster
  )

classification_data$cluster <- as.factor(classification_data$cluster)

#Split in training and test set
set.seed(123)

train_index <- createDataPartition(
  classification_data$cluster,
  p = 0.7,
  list = FALSE
)

train_data <- classification_data[train_index, ]
test_data <- classification_data[-train_index, ]

#Decision Tree
tree_model <- rpart(
  cluster ~ .,
  data = train_data,
  method = "class"
)

rpart.plot(tree_model)

tree_pred <- predict(tree_model, test_data, type = "class")
tree_cm <- confusionMatrix(tree_pred, test_data$cluster)

#Random Forest
set.seed(123)

rf_model <- randomForest(
  cluster ~ .,
  data = train_data,
  ntree = 500,
  importance = TRUE
)

rf_pred <- predict(rf_model, test_data)
rf_cm <- confusionMatrix(rf_pred, test_data$cluster)

varImpPlot(rf_model)

#KNN
set.seed(123)

knn_model <- train(
  cluster ~ .,
  data = train_data,
  method = "knn",
  preProcess = c("center", "scale"),
  tuneLength = 10
)

knn_pred <- predict(knn_model, test_data)
knn_cm <- confusionMatrix(knn_pred, test_data$cluster)

#Model Comparison
model_comparison <- data.frame(
  Model = c("Desicion Tree", "Random Forest", "KNN"),
  Accuracy = c(
    tree_cm$overall["Accuracy"],
    rf_cm$overall["Accuracy"],
    knn_cm$overall["Accuracy"]
  )
)

model_comparison

#Accuracy comparison plot
ggplot(model_comparison, aes(x = Model, y = Accuracy)) +
  geom_col() +
  geom_text(aes(label = round(Accuracy, 3)), vjust = -0.3) +
  ylim(0, 1) +
  labs(
    title = "Classifier Accuracy Comparison",
    x = "Model",
    y = "Accuracy"
  ) +
  theme_minimal()
