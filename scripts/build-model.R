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

reduced_data <- 
  raw_data %>% 
  select(vote_2020,
         state,
         race_ethnicity,
         age,
         gender,
         education)


#filtering out for only Trump and Biden voters
reduced_data <- reduced_data[reduced_data$vote_2020 == "Donald Trump" |
                               reduced_data$vote_2020 == "Joe Biden",]

# breaking age into groups of 18-29, 30-44, 45-60 and 60+
reduced_data$age_group <- cut(reduced_data$age, 
                              breaks = c(18, 29, 44, 60, 200),
                              labels = c("18-29","30-44","45-60","60+" ), 
                              right=FALSE)

#combine education options, helps match with post stratification data
reduced_data$education <- as.character(reduced_data$education)
reduced_data$education[
  grepl("Completed some graduate, but no degree", reduced_data$education)|
    grepl("Masters degree", reduced_data$education)|
    grepl("Doctorate degree", reduced_data$education)
] <- ('Graduate Education')
reduced_data$education[
  grepl("Associate Degree", reduced_data$education)|
    grepl("college", tolower(reduced_data$education))
] <- ('Post Secondary Degree')
reduced_data$education[
  grepl("Grade", reduced_data$education)|
    grepl("high school", tolower(reduced_data$education))
] <- ('High School or less')
reduced_data$education <- as.factor(reduced_data$education)


#combine race options, helps match with post stratification data
reduced_data$race_ethnicity <- as.character(reduced_data$race_ethnicity)
reduced_data$race_ethnicity[
  reduced_data$race_ethnicity == 'Asian (Asian Indian)' |
    reduced_data$race_ethnicity == 'Asian (Korean)' |
    reduced_data$race_ethnicity == 'Asian (Filipino)' |
    reduced_data$race_ethnicity == 'Asian (Vietnamese)'|
    grepl("Pacific", reduced_data$race_ethnicity)
] <- ('Asian (Other)')
reduced_data$race_ethnicity <- as.factor(reduced_data$race_ethnicity)



#drop unused levels
reduced_data <- droplevels(reduced_data)


total_rows <- nrow(reduced_data)

#get updated columns (used for the model)
reduced_data <- reduced_data %>% select(vote_2020,age_group, education, gender, 
                                        race_ethnicity, state)

set.seed(50)
#set 
shuffle_indices <- sample(total_rows)
data <- reduced_data[shuffle_indices,]
boundary <- as.integer(total_rows*0.95)

training <- data[0:boundary,]


#train the model
model <- brm(formula = vote_2020 ~ state + race_ethnicity + gender + age_group,
             data = training,
             family = bernoulli(),
             control = list(adapt_delta = .99, 
                            max_treedepth = 15),
             chains = 3,
             iter = 2000,
             cores = 2
)

#save the model for future uses
saveRDS(model, file = "model/script_model.rds")
