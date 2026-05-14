#Feature Engineering & Dimensionality reduction.
#Loading the raw dataset.
device_usage <- read.csv("device_classification_data.csv")

#Creating a new column containing only the dates.
library(lubridate)
device_usage <- device_usage |> 
  mutate(Time = ymd_hms(Time, tz = "UTC"),
         date = as.Date(Time))

#Cleaning the column headers.
library(janitor)
device_usage <- device_usage |>
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

#Quick sanity check.
glimpse(daily_features)
summary(daily_features)

#Scaling the data.
daily_scaled <- daily_features |>
  select(-date) |>
  scale()

#Performing PCA on the scaled data.
pca <- prcomp(daily_scaled, center = FALSE, scale. = FALSE)
summary(pca)

#Scree plot.
var_explained <- pca$sdev^2/ sum(pca$sdev^2)

plot(var_explained,
     type = "b",
     xlab = "Principal Component",
     ylab = "Proportion of Variance Explained",
     main = "Scree Plot"
  )

#Loadings.
loadings <- as.data.frame(pca$rotation)
loadings

#Cumulative variance.
cumsum(var_explained)

plot(cumsum(var_explained),
     type = "b",
     xlab = "Number of PCs",
     ylab = "Cumulative Variance Explained",
     main = "Cumulative Variance Explained")
abline(h = 0.8, lty = 2)
abline(h = 0.9, lty = 2)

#PCA plot.
pca_df <- as.data.frame(pca$x)
pca_df$date <- daily_features$date

ggplot(pca_df, aes( x = PC1, y = PC2)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Daily Energy Usage Patterns (PCA)",
    x = "PC1",
    y = "PC2"
  ) +
  theme_minimal()

