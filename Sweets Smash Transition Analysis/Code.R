library(dplyr)
library(ggplot2)

sweets_data <- read.csv("~/Library/CloudStorage/OneDrive-BentleyUniversity/MA 255/DataAssignment1/Sweets.csv")
summary(sweets_data)
sweets_data$PlayTimeDifference <- sweets_data$PlayTimeAfter - sweets_data$PlayTimeBefore

summary_stats <- sweets_data %>%
  group_by(TransitionTreatment) %>%
  summarise(
    Mean = mean(PlayTimeDifference),
    SD = sd(PlayTimeDifference),
    Median = median(PlayTimeDifference),
    IQR = IQR(PlayTimeDifference)
  )
summary_stats

summary_stats <- sweets_data %>%
  summarise(
    Max_PlayTimeBefore = max(PlayTimeBefore, na.rm = TRUE),
    Min_PlayTimeBefore = min(PlayTimeBefore, na.rm = TRUE),
    Mean_PlayTimeBefore = mean(PlayTimeBefore, na.rm = TRUE),
    Max_PlayTimeAfter = max(PlayTimeAfter, na.rm = TRUE),
    Min_PlayTimeAfter = min(PlayTimeAfter, na.rm = TRUE),
    Mean_PlayTimeAfter = mean(PlayTimeAfter, na.rm = TRUE)
  )
summary_stats

# Boxplot
ggplot(sweets_data, aes(x = TransitionTreatment, y = PlayTimeDifference, fill = TransitionTreatment)) +
  geom_boxplot(alpha = 0.7) +  
  labs(
    title = "Boxplot of Playtime Differences by Transition Treatment",
    x = "Transition Treatment",
    y = "Playtime Difference (minutes)"
  ) +
  scale_fill_manual(values = c("Control" = "blue", "Treatment" = "red")) +
  theme(legend.position = "none")  


# Density plot for PlayTimeDifference by TransitionTreatment
ggplot(sweets_data, aes(x = PlayTimeDifference, fill = TransitionTreatment)) +
  geom_density(alpha = 0.5) +  # Set transparency to distinguish overlaps
  labs(
    title = "Density Plot of Playtime Differences by Transition Treatment",
    x = "Playtime Difference (minutes)",
    y = "Density"
  ) +
  theme_minimal() + 
  scale_fill_manual(values = c("Control" = "blue", "Treatment" = "red")) +
  theme(legend.title = element_blank()) 

# Scatter plot of PlayTimeBefore vs. PlayTimeAfter by Transition Treatment
ggplot(sweets_data, aes(x = PlayTimeBefore, y = PlayTimeAfter, color = TransitionTreatment)) +
  geom_point(size = 3, alpha = 0.7) + 
  labs(
    title = "Scatter Plot of Playtime Before vs. After Transition by Treatment",
    x = "Playtime Before Transition (minutes)",
    y = "Playtime After Transition (minutes)"
  ) +
  theme_minimal() +  # Optional: clean theme
  scale_color_manual(values = c("Control" = "blue", "Treatment" = "red")) +
  theme(legend.title = element_blank())  

#H0:μTreatment ≤ μControl
#Ha:μTreatment > μControl

# QQ plot 
qqnorm(sweets_data$PlayTimeDifference[sweets_data$TransitionTreatment == "Control"])
qqline(sweets_data$PlayTimeDifference[sweets_data$TransitionTreatment == "Control"])

qqnorm(sweets_data$PlayTimeDifference[sweets_data$TransitionTreatment == "Treatment"])
qqline(sweets_data$PlayTimeDifference[sweets_data$TransitionTreatment == "Treatment"])

# t-test 
t.test(x = sweets_data[sweets_data$TransitionTreatment == 'Treatment', "PlayTimeDifference"],
                         y = sweets_data[sweets_data$TransitionTreatment == 'Control', "PlayTimeDifference"],
                         alternative = 'greater',var.equal = TRUE)



