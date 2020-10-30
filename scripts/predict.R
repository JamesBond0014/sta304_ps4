library(plyr)
library(dplyr)
library(haven)
library(tidyverse)
library(nnet)
library(Metrics)
library(brms)
library(tidybayes)
library(statebins)


model <- readRDS("model/script_model.rds")

post_strat <- read_dta("inputs/data/usa_00001.dta")
# Add the labels
post_strat <- labelled::to_factor(post_strat)

cleaned_post <- 
  post_strat %>% 
  select(stateicp,
         race,
         age,
         sex,
         educ
  )

cleaned_post$age <- as.character(cleaned_post$age)

cleaned_post$age[grepl("less than", cleaned_post$age)] <- "0"
cleaned_post$age[grepl("( in 1980 and 1990)", cleaned_post$age)] <- "90"
cleaned_post$age[grepl("(100+ in 1960-1970)", cleaned_post$age)] <- "100"
cleaned_post$age[grepl("(115+ in the 1990 internal data)", cleaned_post$age)
] <- "115"
cleaned_post$age[grepl("(112+ in the 1980 internal data)", cleaned_post$age)
] <- "112"
cleaned_post$age <- as.factor(cleaned_post$age)



cleaned_post$age <- as.numeric(cleaned_post$age)

cleaned_post <- cleaned_post[cleaned_post$age >= 18,]


cleaned_post$age_group <- cut(cleaned_post$age, breaks = c(18, 29, 44, 60, 200),
                              labels = c("18-29","30-44","45-60","60+" ),
                              right=FALSE)

cleaned_post$education <- as.character(cleaned_post$educ)

cleaned_post$education[
  grepl("5", cleaned_post$education)&
    grepl("years of college", cleaned_post$education)
] <- 'Graduate Education'

cleaned_post$education[
  grepl("college", cleaned_post$education)
] <- 'Post Secondary Degree'

cleaned_post$education[
  grepl("no schooling", cleaned_post$education)|
    grepl("grade", cleaned_post$education)
] <- 'High School or less'


cleaned_post$education <- as.factor(cleaned_post$education)


cleaned_post$race_ethnicity <- as.character(cleaned_post$race)
cleaned_post$race_ethnicity <- plyr::mapvalues(
  cleaned_post$race,
  c("white", "black/african american/negro", "american indian or alaska native",
    "chinese", "japanese", "other asian or pacific islander", "other race, nec",
    "two major races", "three or more major races" ),
  c("White", "Black, or African American", "American Indian or Alaska Native",
    "Asian (Chinese)", "Asian (Japanese)",  "Asian (Other)", "Some other race",
    "Some other race", "Some other race"))
cleaned_post$race_ethnicity <- as.factor(cleaned_post$race_ethnicity)


cleaned_post$gender <- plyr::mapvalues(cleaned_post$sex,
                                       c("male","female"),
                                       c("Male", "Female"))


cleaned_post$state <- as.character(cleaned_post$stateicp)

cleaned_post$state <- plyr::mapvalues(
  cleaned_post$stateicp, c(tolower(state.name), "district of columbia"),
  c(state.abb, "DC"))

cleaned_post$state <- as.factor(cleaned_post$state)

cleaned_post = cleaned_post[complete.cases(cleaned_post), ]

cleaned_post <- droplevels(cleaned_post)



cleaned_post <- cleaned_post %>% select(race_ethnicity, gender, education,
                                        state, age_group)

set.seed(101)
pred_post <- cleaned_post

pred_post <- pred_post[sample(nrow(pred_post)),]
pred_post <- pred_post[0:50000,]

probability <- predict(model, type = "response", newdata = pred_post)[,1]


table(if_else(probability<=0.5,"Joe Biden",
              "Donald Trump" ))

pred_post$pred<-if_else(probability<=0.5,"Joe Biden", "Donald Trump" )

save(pred_post, file = "model/predictions.Rda")