#Ploting typical days/weeks and summarizing per-device usage.
#Loading the Packages.
library(tidyverse)

#Importing the typical_day dataset.
typ_day <- read_csv("typical_day.csv")

#Importing the typical_week dataset.
typ_week <- read_csv("typical_week.csv")

#Performing a quick check.
glimpse(typ_day)
glimpse(typ_week)

#Reshaping typ_day dataset to long format before ploting. 
typ_day_long <- typ_day |>
  pivot_longer(
    cols = starts_with("avg_"),
    names_to = "device",
    values_to = "avg_power"
  )

#Ploting the typ_day_long dataset.
ggplot(typ_day_long,
       aes(x = hour, y = avg_power, color = device)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Typical Daily Usage Profile per Device",
    x = "Hour of Day",
    y = "Average Power Consumption",
    color = "Device"
  ) +
  theme_minimal()

#Reshaping typ_week dataset to long format before ploting.
typ_week_long <- typ_week |>
  pivot_longer(
    cols = starts_with("avg_"),
    names_to = "device",
    values_to = "avg_power"
  )

#Ploting the typ_week_long dataset.
ggplot(typ_week_long,
       aes(x = weekday, y = avg_power, colour = device, group = device)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Typical Weekly Usage Profile per Device",
    x = "Day of Week (0 = Sunday)",
    y = "Average Power Consumption",
    color = "Device"
  ) +
  theme_minimal()

#Summary per device usage per day.
day_summary <- typ_day_long |>
  group_by(device) |>
  summarise(
    mean_daily = mean(avg_power, na.rm = TRUE),
    peak_hour = hour[which.max(avg_power)],
    peak_value = max(avg_power, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(mean_daily))

day_summary

#Converting weekdays from numbers to characters.
typ_week_long <- typ_week_long |>
  mutate(weekday = factor(weekday, levels = 0:6,
                          labels = c("Sun", "Mon", "Tue", "Wed", 
                                     "Thu", "Fri", "Sat")))

#Summary per device usage per weekday.
week_summary <- typ_week_long |>
  group_by(device) |>
  summarise(
    mean_weekly = mean(avg_power, na.rm = TRUE),
    peak_day = weekday[which.max(avg_power)],
    peak_value = max(avg_power, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(mean_weekly))

week_summary