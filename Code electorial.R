#PART 1
# Load required libraries
library(ggplot2)
library(dplyr)
library(broom)
library(stringr)

# Load the dataset
results_2016 <-  read.csv("~/Library/CloudStorage/OneDrive-BentleyUniversity/MA 250/results_2016.csv")
countypres <- read.csv("~/Library/CloudStorage/OneDrive-BentleyUniversity/MA 250/countypres_2000_2020.csv")

# Create the scatterplot with enhanced title and annotations
ggplot(results_2016, aes(x = median_age, y = per_capita_income, color = percent_black)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(
    title = "Income Trends by Age and Racial Composition in U.S. Counties(2016 Election Data)",
    x = "Median Age",
    y = "Per Capita Income",
    color = "Percent Black Population"
  ) +
  theme_minimal() +

  annotate("text", x = 45, y = 60000, label = "High-income, older populations", size = 3, color = "black") +
  annotate("text", x = 28, y = 15000, label = "Younger, lower-income populations", size = 3, color = "black") +
  annotate("text", x = 52, y = 20000, label = "Clusters with high white population", size = 3, color = "black", angle = 45) +

  theme(
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "right"
  )

#PART 2
# Load necessary libraries
library(ggplot2)
library(broom)
library(dplyr)
library(stringr)

# Build the linear model
model <- lm(percent_dem ~ median_age + percent_white + percent_black + percent_asian + 
              per_capita_income + median_rent + state, data = results_2016)

# Extract coefficients and filter out intercept and state terms
model_results <- tidy(model) %>%
  filter(!str_detect(term, "state")) %>%
  filter(term != "(Intercept)")

# Plot the coefficients with confidence intervals and annotations
ggplot(model_results, aes(x = estimate, y = term)) + 
  geom_pointrange(aes(xmin = estimate - std.error, xmax = estimate + std.error)) + 
  labs(
    title = "Influence of Demographic and Economic Factors on Democratic Vote Share (2016)",
    x = "Coefficient Estimate",
    y = "Predictor Variables",  caption = "Estimated impact of demographic and economic factors on 2016 Democratic vote share"
) + 
  theme_minimal() + 
 
  geom_vline(xintercept = 0, color = "red") + 

  annotate("text", x = 0.2, y = "percent_asian", label = "Strong Positive Influence", hjust = -0.1, size = 3, color = "blue") + 
  annotate("text", x = -0.05, y = "percent_white", label = "Negative Influence", hjust = 1.2, size = 3, color = "red") + 

  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12)
  )


#PART 3
# Filter and summarize data by year for Democratic votes
time_series_data <- countypres %>%
  group_by(year) %>%
  summarise(percent.dem = mean(percent.dem, na.rm = TRUE))

# Create time series plot with annotations
ggplot(time_series_data, aes(x = year, y = percent.dem)) +
  geom_line(color = "blue") +
  labs(
    title = "Changes in Democratic Vote Percentage Over Time (2000–2020)",
    x = "Year",
    y = "Democratic Vote Percentage"
  ) +
  theme_minimal() +
  # Add annotations for key points
  annotate("text", x = 2008, y = 0.414, label = "Peak in 2008", vjust = -1, size = 3, color = "black") +
  annotate("text", x = 2016, y = 0.35, label = "Significant Drop in 2016", vjust = -1, size = 3, color = "red") +
  annotate("text", x = 2018, y = 0.29, label = "Slight Recovery in 2020", vjust = -1, size = 3, color = "purple") +
  theme(
    plot.title = element_text(size = 14, face = "bold")
  )+
  ylim(0, NA)
