#### Preamble ####
# Purpose: Calculate cell counts and make predictions for each demographic factor
# Author: James Bao, Alan Chen
# Date: 25 October 2020
# Contact: alan.chen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have cleaned post-stratification dataset saved to inputs
# - Don't forget to gitignore it!

library(tidyverse)
library(haven)
library(brms)
library(tidybayes)
library(statebins)


# Code inspired by:
# https://github.com/MJAlexander/marriage-name-change/blob/master/mncs_mrp.R
# Read in cleaned post-stratification data
cleaned_post <- data.frame(read.csv(file = "inputs/cleaned_acs.csv"))
# Select variables of interest
cleaned_post <- cleaned_post %>% select(race_ethnicity, gender, education, 
                       state, age_group, perwt)
# Calculate cell counts from post-stratification data
cell_counts <- cleaned_post %>%
  group_by(race_ethnicity, gender, education, state, age_group) %>%
  summarise(n=sum(perwt)) %>%
  ungroup()
# Save calculated counts
saveRDS(cell_counts, "inputs/cell_counts.RDS")

# Calculate proportions by race 
race_prop <- cell_counts %>% 
  ungroup %>%
  group_by(race_ethnicity) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()
# Calculate proportions by gender
gender_prop <- cell_counts %>% 
  ungroup %>%
  group_by(gender) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()
# Calculate proportions by state
state_prop <- cell_counts %>% 
  ungroup %>%
  group_by(state) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()
# Calculate proportions by age
age_prop <- cell_counts %>% 
  ungroup %>%
  group_by(age_group) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()
# Calculate proportions by education
education_prop <- cell_counts %>% 
  ungroup %>%
  group_by(education) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup() 


# Get results and plot predictions for each factor of race
race_res <- model %>%
  add_predicted_draws(newdata = race_prop, allow_new_levels=TRUE) %>%
  rename(vote_biden_predict = .prediction) %>%
  mutate(vote_biden_predict_prop = vote_biden_predict*prop) %>%
  group_by(race_ethnicity, .draw) %>%
  summarise(vote_biden_predict = sum(vote_biden_predict_prop)) %>%
  group_by(race_ethnicity) %>%
  summarise(mean = mean(vote_biden_predict), 
            lower = quantile(vote_biden_predict, 0.025), 
            upper = quantile(vote_biden_predict, 0.975))
# Save to processed data file
saveRDS(race_rest, file="processed_data/race_res.RDS")


# Get results and plot predictions for each factor of gender
gender_res <- model %>%
  add_predicted_draws(newdata = gender_prop, allow_new_levels=TRUE) %>%
  rename(vote_biden_predict = .prediction) %>%
  mutate(vote_biden_predict_prop = vote_biden_predict*prop) %>%
  group_by(gender, .draw) %>%
  summarise(vote_biden_predict = sum(vote_biden_predict_prop)) %>%
  group_by(gender) %>%
  summarise(mean = mean(vote_biden_predict), 
            lower = quantile(vote_biden_predict, 0.025), 
            upper = quantile(vote_biden_predict, 0.975))
# Save to processed data file
saveRDS(gender_res, file="processed_data/gender_res.RDS")


# Get results and plot predictions for each state
state_res <- model %>%
  add_predicted_draws(newdata = state_prop, allow_new_levels=TRUE) %>%
  rename(vote_biden_predict = .prediction) %>%
  mutate(vote_biden_predict_prop = vote_biden_predict*prop) %>%
  group_by(state, .draw) %>%
  summarise(vote_biden_predict = sum(vote_biden_predict_prop)) %>%
  group_by(state) %>%
  summarise(mean = mean(vote_biden_predict), 
            lower = quantile(vote_biden_predict, 0.025), 
            upper = quantile(vote_biden_predict, 0.975))
# Save to processed data file
saveRDS(state_res, file="processed_data/state_res.RDS")

# Get results and plot predictions for each age group
age_res <- model %>%
  add_predicted_draws(newdata = age_prop, allow_new_levels=TRUE) %>%
  rename(vote_biden_predict = .prediction) %>%
  mutate(vote_biden_predict_prop = vote_biden_predict*prop) %>%
  group_by(age_group, .draw) %>%
  summarise(vote_biden_predict = sum(vote_biden_predict_prop)) %>%
  group_by(age_group) %>%
  summarise(mean = mean(vote_biden_predict), 
            lower = quantile(vote_biden_predict, 0.025), 
            upper = quantile(vote_biden_predict, 0.975))
# Save to processed data file
saveRDS(age_res, file="processed_data/age_res.RDS")

# Get results and plot predictions for each factor of education
education_res <- model %>%
  add_predicted_draws(newdata = education_prop, allow_new_levels=TRUE) %>%
  rename(vote_biden_predict = .prediction) %>%
  mutate(vote_biden_predict_prop = vote_biden_predict*prop) %>%
  group_by(education, .draw) %>%
  summarise(vote_biden_predict = sum(vote_biden_predict_prop)) %>%
  group_by(education) %>%
  summarise(mean = mean(vote_biden_predict), 
            lower = quantile(vote_biden_predict, 0.025), 
            upper = quantile(vote_biden_predict, 0.975))
# Save to processed data file
saveRDS(education_res, file="processed_data/education_res.RDS")
