#Clustering of daily usage patterns.
#For reproducibility purposes, the PCA steps from the previous part
#are repeated here before clustering.
#Loading the packages.
library(tidyverse)
library(lubridate)
library(janitor)

#Loading the raw dataset.
device_usage <- read.csv("~/Desktop/device_classification_data.csv")

#Basic preprocessing.
device_usage <- device_usage |> 
  mutate(Time = ymd_hms(Time, tz = "UTC"),
         date = as.Date(Time)) |>
  clean_names()

#Creating daily feature table.
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

#Scaling the data.
daily_scaled <- daily_features |>
  select(-date) |>
  scale()

#Performing PCA.
pca <- prcomp(daily_scaled, center = FALSE, scale. = FALSE)

pca_df <- as.data.frame(pca$x)
pca_df$date <- daily_features$date

#Keeping the first two principal components for clustering.
pca_cluster_data <- pca_df |>
  select(PC1, PC2)

#Elbow method.
wss <- numeric(10)

for (k in 1:10) {
  wss[k] <- kmeans(pca_cluster_data, centers = k, nstart = 10)$tot.withinss
}

plot(
  1:10, wss, type = "b",
  xlab = "Number of Clusters",
  ylab = "Within-cluster Sum of Squares",
  main = "Elbow Method"
)

#Based on the elbow method, k=3 was selected.
#K-means clustering.
set.seed(123)
kmeans_result <- kmeans(pca_cluster_data, centers = 3, nstart = 25)

#Adding cluster labels.
pca_df$cluster <- as.factor(kmeans_result$cluster)

#Cluster sizes.
table(pca_df$cluster)

#Visualizing the clusters.
ggplot(pca_df, aes(x = PC1, y = PC2, colour = cluster)) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Clusters of Daily Energy Usage Patterns",
    x = "PC1",
    y = "PC2",
    color = "Cluster"
  ) +
  theme_minimal()

#Merging cluster labels with original features.
cluster_analysis <- daily_features
cluster_analysis$cluster <- pca_df$cluster

#Average usage per cluster.
cluster_summary <- cluster_analysis |>
  group_by(cluster) |>
  summarise(
    fridge = mean(fridge_mean),
    dishwasher = mean(dishwasher_mean),
    tumble_dryer = mean(tumbledryer_mean),
    washing_machine = mean(washingmachine_mean),
    kettle = mean(kettle_mean)
  )
cluster_summary
