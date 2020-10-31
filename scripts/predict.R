library(plyr)
library(dplyr)
library(haven)
library(tidyverse)
library(nnet)
library(Metrics)
library(brms)
library(tidybayes)
library(statebins)


model <- readRDS("model/4chains_3000iter_.rds")

post_strat <- read_dta("inputs/data/usa_00001.dta")
# Add the labels
post_strat <- labelled::to_factor(post_strat)


colnames(post_strat)

cleaned_post <- 
  post_strat %>% 
  select(stateicp,
         race,
         age,
         sex,
         educ,
         perwt
  )

table(cleaned_post$educ)


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

#remove people under 18 and over 78
cleaned_post <- cleaned_post[cleaned_post$age <= 78 &
                               cleaned_post$age >= 18,]

cleaned_post$age_group <- cut(cleaned_post$age, breaks = seq(18, 88, 10),
                              labels = c("18 to 28","29 to 38","39 to 48",
                                         "49 to 58","59 to 68","69 to 78",
                                         "79 and above"),
                              right=FALSE)

cleaned_post$education <- as.character(cleaned_post$educ)


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
                                        state, age_group,perwt)
head(cleaned_post)
write.csv(x=cleaned_post, file="inputs/cleaned_acs.csv")



