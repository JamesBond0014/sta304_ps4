#### Preamble ####
# Purpose: Calculate popular vote predictions
# Author: James Bao, Alan Chen
# Date: 25 October 2020
# Contact: alan.chen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Saved predictions for each demographic variable and trained model

library(tidyverse)
library(haven)
library(brms)
library(tidybayes)
library(statebins)
library(dplyr)

# Load cell counts and trained model
cell_counts <- readRDS("inputs/cell_counts.RDS")
model <- readRDS("model/4chains_3000iter_.rds")

# Load the summarized results for each variable we used
race_res <- readRDS("processed_data/race_res.RDS")
gender_res <- readRDS("processed_data/gender_res.RDS")
state_res <- readRDS("processed_data/state_res.RDS")
age_res <- readRDS("processed_data/age_res.RDS")
education_rest <- readRDS("processed_data/age_res.RDS")

# Calculate proportion each cell makes up
overall_prop <- cell_counts %>%
  mutate(prop = n/sum(n))

# Make predictions on the post stratification data set
overall_prop$predict <- predict(model, type = "response", newdata = overall_prop)
# Determine vote based on probability (respondent would vote for Biden if probability > 0.5)
overall_prop$vote_biden <- if_else(overall_prop$predict[,1] > 0.5, 1, 0)
# Determine popular vote using calculated proportions of cell counts
overall_prop$vote_weight <- overall_prop$vote_biden * overall_prop$prop
# Save result to processed_data folder
saveRDS(overall_prop, file='processed_data/predictions.RDS')
