#### Preamble ####
# Purpose: Prepare and clean the survey data downloaded from Nationscape; train, test, and save model
# Author: James Bao, Alan Chen
# Date: 25 October 2020
# Contact: alan.chen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have downloaded the Nationscape data and saved it to inputs/data
# - Don't forget to gitignore it!

library(plyr)
library(dplyr)
library(haven)
library(tidyverse)
library(nnet)
library(Metrics)
library(brms)
library(tidybayes)
library(statebins)

raw_data <- read_dta("inputs/data/ns20200625/ns20200625.dta")
# Add the labels
raw_data <- labelled::to_factor(raw_data)

# Isolate variables of interest
reduced_data <- 
  raw_data %>% 
  select(vote_2020,
         state,
         race_ethnicity,
         age,
         gender,
         education)

# Only keep rows that are not missing any values
reduced_data <- reduced_data[complete.cases(reduced_data),]

# Filtering for only Trump and Biden voters
reduced_data <- reduced_data[reduced_data$vote_2020 == "Donald Trump" |
                               reduced_data$vote_2020 == "Joe Biden",]

# Change vote to binary variable: 1 for voting for Biden, 0 for voting for Trump
reduced_data$vote_biden <- plyr::mapvalues(reduced_data$vote_2020, 
                                           c("Donald Trump", "Joe Biden"),
                                           c(0, 1))

# Remove people under 18 and over 78 
reduced_data <- reduced_data[reduced_data$age <= 78 &
                               reduced_data$age >= 18,]


# Split age responses into groups of 10 years
reduced_data$age_group <- cut(reduced_data$age, 
                              breaks = seq(10, 88, 10),
                              labels = c("18 to 28","29 to 38","39 to 48",
                                         "49 to 58","59 to 68","69 to 78", 
                                         "79 and above"), 
                              right=FALSE)


# Combine education options to match with post stratification data
reduced_data$education <- as.character(reduced_data$education)
reduced_data$education[
  grepl("Completed some graduate, but no degree", reduced_data$education)|
    grepl("Masters degree", reduced_data$education)|
    grepl("Doctorate degree", reduced_data$education)|
    grepl("Associate Degree", reduced_data$education)|
    grepl("college", tolower(reduced_data$education))
] <- ('Post Secondary Degree')
reduced_data$education[
  grepl("Grade", reduced_data$education)|
    grepl("high school", tolower(reduced_data$education))
] <- ('High School or Less')
reduced_data$education <- as.factor(reduced_data$education)


# Combine race factors to match with post stratification data
reduced_data$race_ethnicity <- as.character(reduced_data$race_ethnicity)
reduced_data$race_ethnicity[
  reduced_data$race_ethnicity == 'Asian (Asian Indian)' |
    reduced_data$race_ethnicity == 'Asian (Korean)' |
    reduced_data$race_ethnicity == 'Asian (Filipino)' |
    reduced_data$race_ethnicity == 'Asian (Vietnamese)'|
    grepl("Pacific", reduced_data$race_ethnicity)
] <- ('Asian (Other)')
reduced_data$race_ethnicity <- as.factor(reduced_data$race_ethnicity)



# Drop unused levels
reduced_data <- droplevels(reduced_data)

# Save cleaned to inputs folder
saveRDS(reduced_data, file = "inputs/training_data.Rda")

# Total number of observations in the dataset
total_rows <- nrow(reduced_data)

# Get selected columns of interest
reduced_data <- reduced_data %>% select(vote_biden,age_group, gender, 
                                        race_ethnicity, state)

# Set seed for reproducibility (same seed as in build-model.R)
set.seed(50)
# Set up cross-validation
data <- reduced_data[shuffle_indices,]
# Calculate index to serve as boundary for 95 - 5 data split
boundary <- as.integer(total_rows*0.95)
# Separate training dataset using calculated boundary
training <- data[0:boundary,]

# Check training dataset size
nrow(training)
nrow(data)-nrow(training)

# Train the model
model <- brm(formula = vote_biden ~ state + race_ethnicity + gender + age_group 
             + education,
             data = training,
             family = bernoulli(),
             control = list(adapt_delta = .99, 
                            max_treedepth = 15),
             chains = 4,
             iter = 3000,
             cores = 2
)
# Define testing dataset using calculated boundary
testing <- data[boundary:total_rows,]

# Test the accuracy of the model
# Calculate probability of voting Biden on the testing data
probability <- predict(model, type = "response", newdata = testing)
# Determine vote based on probability (respondent would vote for Biden if probability > 0.5)
probability <- if_else(probability[,1] >0.5,1,0)
testing$probs <- probability
# Compare to ground truth 2020 vote
testing <- testing %>% mutate(acc = probs==vote_biden)
table(testing$acc)


# Save the model for future uses
saveRDS(model, file = "model/4chains_3000iter_.rds")
