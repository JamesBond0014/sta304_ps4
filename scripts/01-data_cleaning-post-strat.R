#### Preamble ####
# Purpose: Prepare and clean the survey data downloaded from IPUMS
# Author: Zakir Chaudry
# Date: 25 October 2020
# Contact: zakir.chaudry@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have downloaded the ACS data and saved it to inputs/data
# - Don't forget to gitignore it!


#### Workspace setup ####
library(haven)
library(tidyverse)
# Read in the raw data. 
raw_data <- read_dta("inputs/data/usa_00001.dta"
                     )
# Add the labels
raw_data <- labelled::to_factor(raw_data)

# Just keep some variables that may be of interest (change 
# this depending on your interests)
names(raw_data)


reduced_data <- 
  raw_data %>% 
  select(stateicp,
         race,
         age,
         sex,
         educ
  )


# Make ages strings so they're easier to work with
reduced_data$age <- as.character(reduced_data$age)

# Pattern match the irregular responses to more understandable types
reduced_data$age[grepl("less than", reduced_data$age)] <- "0"
reduced_data$age[grepl("( in 1980 and 1990)", reduced_data$age)] <- "90"
reduced_data$age[grepl("(100+ in 1960-1970)", reduced_data$age)] <- "100"
reduced_data$age[grepl("(115+ in the 1990 internal data)", reduced_data$age)
] <- "115"
reduced_data$age[grepl("(112+ in the 1980 internal data)", reduced_data$age)
] <- "112"


reduced_data$age <- as.factor(reduced_data$age)

# Converts responses to numeric values
reduced_data$age <- as.numeric(reduced_data$age)

# Remove those who are younger than the legal voting age
reduced_data <- reduced_data[reduced_data$age >= 18,]

# Break ages into 4 age groups
reduced_data$age_group <- cut(reduced_data$age, breaks = c(18, 29, 44, 60, 200),
                              labels = c("18-29","30-44","45-60","60+" ),
                              right=FALSE)


# Make education strings so they're easier to work with
reduced_data$education <- as.character(reduced_data$educ)

# Pattern match the irregular responses to more understandable types
reduced_data$education[
  grepl("5", reduced_data$education)&
    grepl("years of college", reduced_data$education)
] <- 'Graduate Education'

reduced_data$education[
  grepl("college", reduced_data$education)
] <- 'Post Secondary Degree'

reduced_data$education[
  grepl("no schooling", reduced_data$education)|
    grepl("grade", reduced_data$education)
] <- 'High School or less'


reduced_data$education <- as.factor(reduced_data$education)


# Make race/ethnicity strings so they're easier to work with
reduced_data$race_ethnicity <- as.character(reduced_data$race)

# Match races/ethnicities to survey data values
reduced_data$race_ethnicity <- plyr::mapvalues(
  reduced_data$race,
  c("white", "black/african american/negro", "american indian or alaska native",
    "chinese", "japanese", "other asian or pacific islander", "other race, nec",
    "two major races", "three or more major races" ),
  c("White", "Black, or African American", "American Indian or Alaska Native",
    "Asian (Chinese)", "Asian (Japanese)",  "Asian (Other)", "Some other race",
    "Some other race", "Some other race"))
reduced_data$race_ethnicity <- as.factor(reduced_data$race_ethnicity)



# Match gender to survey data values
reduced_data$gender <- plyr::mapvalues(reduced_data$sex,
                                       c("male","female"),
                                       c("Male", "Female"))


# Make states strings so they're easier to work with
reduced_data$state <- as.character(reduced_data$stateicp)

# Match state response to survey data value
reduced_data$state <- plyr::mapvalues(
  reduced_data$stateicp, c(tolower(state.name), "district of columbia"),
  c(state.abb, "DC"))

reduced_data$state <- as.factor(reduced_data$state)


# Only keep full responses
reduced_data = reduced_data[complete.cases(reduced_data), ]

# Get rid of unused levels
reduced_data <- droplevels(reduced_data)


# Keep the newly cleaned data
cleaned_data <- reduced_data %>% select(race_ethnicity, gender, education,
                                        state, age_group)


