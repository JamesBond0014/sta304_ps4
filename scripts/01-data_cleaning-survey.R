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

raw_data = raw_data[complete.cases(raw_data), ]

write.csv(x=cleaned_post, file="inputs/cleaned_acs.csv")
