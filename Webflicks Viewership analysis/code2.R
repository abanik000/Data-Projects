Webflicks <- read.csv("~/Library/CloudStorage/OneDrive-BentleyUniversity/MA 255/DataAssignment2/Webflicks.csv")

library(dplyr)
library(knitr)
library(kableExtra)

# Summary statistics: Min, Max, Mean, Median, and SD for Views grouped by Release Schedule
summary_stats <- Webflicks %>%
  group_by(ReleaseSchedule) %>%
  summarise(
    Min_Views = min(Views),
    Max_Views = max(Views),
    Mean_Views = mean(Views),
    Median_Views = median(Views),
    SD_Views = sd(Views)
  )

# Format the summary statistics table
summary_stats %>%
  kable("html", caption = "Summary Statistics by Release Schedule") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), 
                full_width = F, 
                position = "center",
                font_size = 12)
summary(Webflicks)
#Barchart
# Average views by Release Schedule and Genre
average_views <- Webflicks %>%
  group_by(ReleaseSchedule, Genre) %>%
  summarise(AverageViews = mean(Views))
# Bar chart for average views
ggplot(average_views, aes(x = Genre, y = AverageViews, fill = ReleaseSchedule)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Average Views by Release Schedule and Genre", 
       x = "Genre", y = "Average Views (millions)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Bar chart for average views
ggplot(average_views, aes(x = Genre, y = AverageViews, fill = ReleaseSchedule)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Average Views by Release Schedule and Genre", 
       x = "Genre", y = "Average Views (millions)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Boxplot
ggplot(Webflicks) +
  geom_boxplot(aes(y = Views,
                   x = ReleaseSchedule,
                  fill = Genre)) 

Webflicks <- as.data.table(Webflicks)

#Assumptions
fit <- aov(Views ~ ReleaseSchedule + Genre,
           data=Webflicks)
#Homogenity
Webflicks$Residuals <- residuals(fit)
Webflicks$Predicted <- predict(fit)
plot(Residuals ~ Predicted,
     data = Webflicks)
#Normality
qqnorm(Webflicks$Residuals);qqline(Webflicks$Residuals)

#Two-way Anova
summary(fit)
pval_genre<-0.64806   #fail to reject genre

pval_releaseschedule<-0.00163 #reject Release schedule

#Post-Hoc Analysis for Genre                                
# Drop - Weekly
summary(aov(Views~ReleaseSchedule + Genre,
            data=Webflicks[ ReleaseSchedule %in% c("Drop", "Weekly")]))
# Analysis 2:
# Drop - DualDrop
summary(aov(Views~ReleaseSchedule + Genre,
            data=Webflicks[ ReleaseSchedule %in% c("Drop", "DualDrop")]))
#Analysis 3:
# Weekly - DualDrop
summary(aov(Views~ReleaseSchedule + Genre,
            data=Webflicks[ ReleaseSchedule %in% c("Weekly", "DualDrop")]))

# Uncorrected p-values
Drop_Weekly=0.00192
Drop_DualDrop=0.0036 
Weekly_DualDrop=0.863

#Corrected p-values
Corrected_Drop_Weekly=Drop_Weekly*3
Corrected_Drop_DualDrop=Drop_DualDrop*3
Corrected_Weekly_DualDrop=Weekly_DualDrop*3
#Drop
#EDA 1
# Numerical summaries of each factor level combination
Webflicks[,.(Mean = mean(Views)),
          by = c("ReleaseSchedule", "Genre")]
#EDA 2
ggplot(Webflicks) +
  geom_boxplot(aes(y = Views,
                   x = ReleaseSchedule,
                   fill = Genre))                   

#anticipated power
pwr.f2.test(u = 3, v = 174, f2 = 0.25^2,
            sig.level = 0.05, power = NULL) #0.7990022
