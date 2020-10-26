#### Preamble ####
# Purpose: Prepare and clean the survey data downloaded from Democracy Fund + UCLA Nationscape
# Author: Xinyi Zhang
# Date: 26 October 2020
# Contact: xinyicindy.zhang@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have downloaded the data from Democracy Fund + UCLA Nationscape
# and save the folder that you're interested in to inputs/data 
# - Don't forget to gitignore it!


#### Workspace setup ####
library(haven)
library(tidyverse)
# Read in the raw data (You might need to change this if you use a different dataset)
raw_data <- read_dta("inputs/data/ns20200625/ns20200625.dta")
# Add the labels
raw_data <- labelled::to_factor(raw_data)
# Recommended variables
# reduced_data <-
#   raw_data %>%
#   select(interest,
#          registration,
#          vote_2016,
#          vote_intention,
#          vote_2020,
#          ideo5,
#          employment,
#          foreign_born,
#          census_region,
#          hispanic,
#          education,
#          state,
#          race_ethnicity,
#          age,
#          gender,
#          household_income,
#          congress_district
#   )

# chosen variables
reduced_data <- 
  raw_data %>% 
  select(vote_intention,
         vote_2020,
         state,
         race_ethnicity,
         age,
         gender,
         household_income
  )

reduced_data = reduced_data[complete.cases(reduced_data), ]

# View factors for each variable of interest
table(reduced_data$state)
table(reduced_data$race_ethnicity)
table(reduced_data$age)
table(reduced_data$gender)
table(reduced_data$household_income)

table(reduced_data$vote_intention)
table(reduced_data$vote_2020)

# Maybe make some age-groups?
# Is vote a binary? If not, what are you going to do?
