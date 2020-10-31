library(tidyverse)
library(haven)
library(brms)
library(tidybayes)
library(statebins)

cleaned_post <- data.frame(read.csv(file = "inputs/cleaned_acs.csv"))

colnames(cleaned_post)
cleaned_post <- cleaned_post %>% select(race_ethnicity, gender, education, 
                       state, age_group)
head(cleaned_post)
cell_counts <- cleaned_post %>%
  group_by(race_ethnicity, gender, education, state, age_group) %>%
  summarise(n=sum(perwt))

head(cell_counts)
    
    
cell_counts

