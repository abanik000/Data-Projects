library(readxl)
library(broom)  
library(ggplot2)
library(tidyverse)
library(fmsb)
library(dplyr)
library(ggalluvial)

data <-  read_excel("~/Downloads/Patients Data ( Used for Heart Disease Prediction ).xlsx")

# Ensure AlcoholDrinkers is a categorical variable
data$AlcoholDrinkers <- factor(data$AlcoholDrinkers, labels = c("No", "Yes"))

# Prepare the data for the heatmap
heatmap_data <- data %>%
  group_by(SmokerStatus, AlcoholDrinkers) %>%
  summarize(HeartAttackRate = mean(HadHeartAttack, na.rm = TRUE) * 100, .groups = "drop") %>%
  na.omit()

# Calculate the national average heart attack rate (proportion of 1s in HadHeartAttack)
national_avg <- mean(data$HadHeartAttack == 1, na.rm = TRUE) * 100

# Define custom labels for Smoking Status
labels <- c(
  "Current smoker - now smokes every day" = "Current Smoker",
  "Current smoker - now smokes some days" = "Semi-current Smoker",
  "Former smoker " = "Former Smoker",
  "Never smoked" = "Non-Smoker"
)

# Heatmap with red-yellow-green color scale
ggplot(heatmap_data, aes(x = SmokerStatus, y = AlcoholDrinkers, fill = HeartAttackRate)) +
  geom_tile(color = "white") +
  geom_text(aes(label = paste0(round(HeartAttackRate, 1), "%")),
            color = "black", size = 4) +  # Black text for better contrast
  scale_fill_gradientn(
    colors = c("green", "yellow", "red"),
    limits = c(min(heatmap_data$HeartAttackRate, na.rm = TRUE), max(heatmap_data$HeartAttackRate, na.rm = TRUE)),
    name = "Heart Attack %"
  ) +
  labs(
    title = "Smoking Amplifies Heart Attack Risk, Especially Among Non-Drinkers",
    subtitle = "Red: High heart attack rate, Yellow: Medium, Green: Low",
    x = "Smoking Status",
    y = "Alcohol Consumption"
  ) +
  scale_x_discrete(labels = labels, expand = expansion(mult = c(0.2, 0.2))) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    plot.margin = margin(2, 2, 2, 2),
    legend.title = element_text(size = 10)
  )


# Required libraries
library(ggplot2)
library(dplyr)
library(broom)

# Simulate data similar to your logistic regression results
data <- data.frame(
  term = c("Intercept", 
           "HadDiabetesYes", 
           "HadKidneyDisease", 
           "HadDiabetesNo, pre-diabetes or borderline diabetes", 
           "HadDiabetesYes, but only during pregnancy (female)"),
  odds_ratio = c(0.8, 2.5, 1.8, 1.0, 0.9),
  conf.low = c(0.7, 2.0, 1.4, 0.8, 0.6),
  conf.high = c(0.9, 3.0, 2.2, 1.2, 1.2)
)

# Reverse the factor levels to plot in correct order
data <- data %>% 
  mutate(term = factor(term, levels = rev(term)))

# Create the plot
ggplot(data, aes(x = odds_ratio, y = term)) +
  geom_point(color = "blue", size = 3) +  
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2, color = "blue") +  
  geom_vline(xintercept = 1, linetype = "dashed", color = "red") + 
  labs(
    title = "Diabetes and Kidney Disease Significantly Elevate Heart Attack Risk",
    x = "Odds Ratio (95% CI)",
    y = "Clinical Condition"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(linetype = "dotted", color = "gray")
  )

# Load necessary libraries
library(dplyr)
library(broom)

# Fit logistic regression model
model <- glm(
  HadHeartAttack ~ HadDiabetes + HadKidneyDisease + HadStroke,
  data = data,
  family = binomial
)

# Summarize the results
summary(model)

# Extract coefficients and their significance
tidy_model <- tidy(model) %>%
  mutate(
    OddsRatio = exp(estimate),  # Convert log-odds to odds ratios
    Significant = ifelse(p.value < 0.05, "Yes", "No")  # Mark significant predictors
  )

print(tidy_model)



#Alluvial
# Simulated data for selected states
data <- data.frame(
  State = c("Florida", "Florida", "Texas", "Texas", "Maine", "Maine", "Washington", "Washington", "Ohio", "Ohio"),
  Sex = c("Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female"),
  HadHeartAttack = c("Yes", "No", "Yes", "No", "Yes", "No", "Yes", "No", "Yes", "No"),
  Count = c(300, 200, 400, 300, 100, 150, 250, 220, 350, 330) # Example counts
)

# Reorder the State variable to separate Texas and Ohio
data$State <- factor(data$State, levels = c("Florida", "Texas", "Maine", "Ohio", "Washington"))

# Create the Alluvial Diagram with Custom Order
ggplot(data, 
       aes(axis1 = State, axis2 = Sex, axis3 = HadHeartAttack, y = Count)) +
  geom_alluvium(aes(fill = State), width = 1/12) +
  geom_stratum(width = 1/12, fill = "grey", color = "black") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 3, color = "black") +
  scale_x_discrete(
    limits = c("State", "Sex", "Heart Attack"),
    expand = c(0.1, 0.1)
  ) +
  labs(
    title = "Texas and Ohio Lead in Male Heart Attack Cases: Gender Gaps Across States",
    y = "Count of Patients",
    x = ""
  ) +
  annotate("text", x = 2.2, y = 870, label = "High male heart attack rate in Texas", color = "red", size = 3.5, hjust = 0) +
  annotate("text", x = 2.2, y = 500, label = "High male heart attack rate in Ohio", color = "red", size = 3.5, hjust = 0) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 10, face = "bold"),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.text.y = element_blank()
  )

# Load necessary libraries
library(ggplot2)
library(ggalluvial)

# Create the data
data <- data.frame(
  State = c("Florida", "Florida", "Maine", "Maine", "Ohio", "Ohio", "Texas", "Texas", "Washington", "Washington"),
  Sex = c("Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female"),
  NormalizedRate = c(0.000047, 0.000027, 0.000779, 0.000329, 0.000073, 0.000042, 0.000025, 0.000015, 0.000086, 0.000042)
)

# Plot the alluvial chart
ggplot(data = data, 
       aes(axis1 = State, axis2 = Sex, y = NormalizedRate)) +
  geom_alluvium(aes(fill = State), width = 1/12) +
  geom_stratum(width = 1/12, fill = "grey", color = "black") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 3) +
  scale_x_discrete(limits = c("State", "Sex"), expand = c(0.1, 0.1)) +
  labs(title = "Male Heart Attack Rates Dominate Across States, with Maine Leading the Charge", 
       y = "Normalized Heart Attack Rate (%)", 
       x = "") +
  annotate("text", x = 1.5, y = 0.001, label = "Maine shows the highest male rates", 
           size = 4, color = "red", fontface = "bold", angle = 0)+
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 14))

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(broom)

# Fit logistic regression model
model <- glm(
  HadHeartAttack ~ HadDiabetes + HadKidneyDisease + HadStroke,
  data = data,
  family = binomial
)

# Extract coefficients, calculate odds ratios, and identify significance
tidy_model <- tidy(model) %>%
  mutate(
    OddsRatio = exp(estimate),  # Convert log-odds to odds ratios
    LowerCI = exp(conf.low),    # Calculate lower bound of 95% CI
    UpperCI = exp(conf.high),   # Calculate upper bound of 95% CI
    Significant = ifelse(p.value < 0.05, "Yes", "No")  # Mark significant predictors
  )

# Add confidence intervals for odds ratios
tidy_model <- tidy_model %>%
  mutate(
    LowerCI = exp(estimate - 1.96 * std.error),
    UpperCI = exp(estimate + 1.96 * std.error)
  )
short_labels <- c(
  "HadDiabetesYes" = "Diabetes",
  "HadKidneyDisease" = "Kidney Disease",
  "HadDiabetesNo, pre-diabetes or borderline diabetes" = "Pre-diabetes",
  "HadDiabetesYes, but only during pregnancy (female)" = "Pregnancy Diabetes"
)


# Plot the Odds Ratio chart
ggplot(tidy_model, aes(x = OddsRatio, y = term)) +
  geom_point(aes(color = Significant), size = 3) +
  geom_errorbarh(aes(xmin = LowerCI, xmax = UpperCI), height = 0.4, color = "blue") +
  geom_vline(xintercept = 1, linetype = "dashed", color = "red") +
  scale_x_log10() +
  labs(
    title = 'Diabetes and Stroke Significantly Elevate Heart Attack Risk, While Pregnancy Diabetes Shows Reduced Odds',
    x = "Odds Ratio (log scale)",
    y = "Predictor Variables"
  ) +
  scale_y_discrete(labels = short_labels) + # Update labels
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(linetype = "dotted", color = "gray"),
    legend.position = "bottom"
  )
