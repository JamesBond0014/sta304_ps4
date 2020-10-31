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

colnames(raw_data)

reduced_data <- 
  raw_data %>% 
  select(vote_2020,
         state,
         race_ethnicity,
         age,
         gender,
         education)


reduced_data <- reduced_data[complete.cases(reduced_data),]

#filtering out for only Trump and Biden voters
reduced_data <- reduced_data[reduced_data$vote_2020 == "Donald Trump" |
                               reduced_data$vote_2020 == "Joe Biden",]
table(complete.cases(reduced_data))


reduced_data$vote_biden <- plyr::mapvalues(reduced_data$vote_2020, 
                                           c("Donald Trump", "Joe Biden"),
                                           c(0, 1))

#remove people under 18 and over 78
reduced_data <- reduced_data[reduced_data$age <= 78 &
                               reduced_data$age >= 18,]


# breaking age into groups of 10
reduced_data$age_group <- cut(reduced_data$age, 
                              breaks = seq(10, 88, 10),
                              labels = c("18 to 28","29 to 38","39 to 48",
                                         "49 to 58","59 to 68","69 to 78", 
                                         "79 and above"), 
                              right=FALSE)


#combine education options, helps match with post stratification data
reduced_data$education <- as.character(reduced_data$education)
reduced_data$education[
  grepl("Completed some graduate, but no degree", reduced_data$education)|
    grepl("Masters degree", reduced_data$education)|
    grepl("Doctorate degree", reduced_data$education)
] <- ('Post Secondary Degree')
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

save(reduced_data, file = "data/training_data.Rda")


total_rows <- nrow(reduced_data)

#get updated columns (used for the model)
reduced_data <- reduced_data %>% select(vote_biden,age_group, education, gender, 
                                        race_ethnicity, state)

set.seed(50)
#set 
shuffle_indices <- sample(total_rows)
data <- reduced_data[shuffle_indices,]
boundary <- as.integer(total_rows*0.95)

training <- data[0:boundary,]



#train the model
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

testing <- data[boundary:total_rows,]

#testing the accuracy of the model
probability <- predict(model, type = "response", newdata = testing)
probability <- if_else(probability[,1] >0.5,1,0)
testing$probs <- probability
testing <- testing %>% mutate(acc = probs==vote_biden)
table(testing$acc)


#save the model for future uses
saveRDS(model, file = "model/4chains_3000iter_.rds")
