library(tidyverse)
library(haven)
library(brms)
library(tidybayes)
library(statebins)


#code used inspiration from:
#https://github.com/MJAlexander/marriage-name-change/blob/master/mncs_mrp.R
cleaned_post <- data.frame(read.csv(file = "inputs/cleaned_acs.csv"))

cleaned_post <- cleaned_post %>% select(race_ethnicity, gender, education, 
                       state, age_group, perwt)

cell_counts <- cleaned_post %>%
  group_by(race_ethnicity, gender, education, state, age_group) %>%
  summarise(n=sum(perwt)) %>%
  ungroup()

saveRDS(cell_counts, "inputs/cell_counts.RDS")

race_prop <- cell_counts %>% 
  ungroup %>%
  group_by(race_ethnicity) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()

gender_prop <- cell_counts %>% 
  ungroup %>%
  group_by(gender) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()

state_prop <- cell_counts %>% 
  ungroup %>%
  group_by(state) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()

age_prop <- cell_counts %>% 
  ungroup %>%
  group_by(age_group) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup()

education_prop <- cell_counts %>% 
  ungroup %>%
  group_by(education) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup() 



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

saveRDS(race_rest, file="processed_data/race_res.RDS")



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

saveRDS(gender_res, file="processed_data/gender_res.RDS")



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

saveRDS(state_res, file="processed_data/state_res.RDS")

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

saveRDS(age_res, file="processed_data/age_res.RDS")

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

saveRDS(education_res, file="processed_data/education_res.RDS")


head(state_res)
head(education_res)
head(age_res)
head(race_res)
head(gender_res)
