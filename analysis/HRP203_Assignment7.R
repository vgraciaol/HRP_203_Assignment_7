# HRP203_Assignment7.R
#------------------------------------------------------------------------------#
#   HRP 203: Methods for Reproducible Population Health and Clinical Research  #
#                               ASSIGNMENT 7                                   #
#                                                                              #
# Source:                                                                      #
# https://github.com/MethodsForReproducibleHealthResearch/Assignment7          #
#                                                                              #
# Authors:                                                                     #
#   Valeria Gracia Olvera, <vgracia@stanford.edu>                              #
#                                                                              #
# Created: 05/19/24                                                            #
# Last update: 05/19/24                                                        #
#------------------------------------------------------------------------------#
rm(list = ls())  # clean environment

# Load libraries ----------------------------------------------------------
library(ggplot2)
library(tidyverse)
library(GGally)
library(knitr)
library(tidyr)
library(jtools)

# Load data ---------------------------------------------------------------
df_cohort <- read.csv("data_raw/cohort.csv")
df_cohort <- df_cohort %>% 
  rename(sex = female)

# Transform discrete to factors
df_cohort$smoke <- factor(df_cohort$smoke, levels = c(1,0), 
                          labels = c("Yes", "No"))
df_cohort$sex <- factor(df_cohort$sex, levels = c(1,0), 
                           labels = c("Female", "Male"))
df_cohort$cardiac <- factor(df_cohort$cardiac, levels = c(1,0), 
                            labels = c("Yes", "No"))

# Descriptive statistics --------------------------------------------------
df_stats <- data.frame(rbind(c("Age (in years)", 
                               as.vector(round(summary(df_cohort$age)[c(1,3,4,6)],2))),
                             c("Cost ($)", 
                               as.vector(round(summary(df_cohort$cost)[c(1,3,4,6)],2)))))

colnames(df_stats) <- c("Variable", "Min", "Median", "Mean", "Max")
kable(df_stats, format = "pipe")

df_prop_table <- as.data.frame(prop.table(table(df_cohort$smoke, 
                             df_cohort$cardiac, 
                             df_cohort$sex)))
colnames(df_prop_table) <- c("Smoke", "Cardiac", "Sex", "Value")

df_prop_table <- df_prop_table %>% 
  pivot_wider(id_cols = c("Smoke","Cardiac"),
              names_from = "Sex", values_from = "Value")

kable(df_prop_table, format = "pipe")

# Analysis ----------------------------------------------------------------
# Plot the relationship between cost and all the other variables
df_plot <- read.csv("data_raw/cohort.csv")
df_plot <- df_plot %>% 
  rename(sex = female)

df_plot$smoke <- factor(df_plot$smoke, levels = c(1,0), 
                        labels = c("Smoke: Yes", "Smoke: No"))
df_plot$sex <- factor(df_plot$sex, levels = c(1,0), 
                      labels = c("Female", "Male"))
df_plot$cardiac <- factor(df_plot$cardiac, levels = c(1,0), 
                          labels = c("Cardiac episode: Yes", "Cardiac episode: No"))

ggplot(df_plot, aes(x = age, y = cost, color = cardiac)) +
  geom_point(size = 2, alpha = 0.25) +
  scale_colour_manual("", values = c("gray30", "firebrick3")) +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(smoke ~ sex) +
  geom_smooth(method = "lm", formula = y ~ x, se = F,
              linewidth = 1.5) +
  xlab("Age") + ylab("Cost ($)") +
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 0, 
                                   hjust = 0.5, 
                                   vjust = 0.5,
                                   colour = "black"),
        axis.text.y = element_text(colour = "black"),
        panel.background = element_rect(fill = "grey94", 
                                        size = 0.15, 
                                        linetype = "solid"),
        panel.border = element_rect(colour = "black", 
                                    fill = NA, 
                                    size = 0.7), 
        strip.background = element_rect(fill   = "transparent",
                                        colour = "transparent"),
        legend.justification = "center", 
        legend.position = "bottom",
        legend.text = element_text(size = 12),
        legend.direction = "horizontal", 
        legend.key = element_rect(fill   = "transparent", 
                                  colour = "transparent",
                                  size   = unit(3, "cm")))

ggsave("figs/fig_cost_vs_vars.jpg", width = 10, height = 10)

# Regression
lm_cohort <- lm(cost ~ age + sex + cardiac + smoke, data = df_cohort)
summary(lm_cohort)

summ(lm_cohort)
