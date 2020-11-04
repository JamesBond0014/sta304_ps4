# Overview

This repo contains code and data for forecasting the US 2020 presidential election. It was created by James Bao, Zakir Chaudry, Alan Chen, Xinyi Zhang. The purpose is to create a report that summarizes the results of a statistical model that we built. Some data is unable to be shared publicly. We detail how to access it below. We set up our repo using folders named inputs, model, outputs, processed_data, and scripts.

Inputs contain data that are unchanged after downloading. We use two datasets:

- [Survey data]

Go to https://www.voterstudygroup.org/publication/nationscape-data-set
Scroll to the bottom of the page and enter information in order to request the datasets.
Once the dataset is emailed, download it and extract the folder that contains the DTA files.
Navigate to phase_2 folder and copy folder titled ns20200625 into the repos input folder.


- [ACS data]

Go to https://usa.ipums.org/usa/index.shtml
Create an account and click on Get Data in the middle of your screen.
Click on Change Samples, and deselect everything except the 2018 ACS.
Next add desired variables. For this repo, you will need:
  - STATEICP
  - RACE
  - SEX
  - EDUC
  - AGE
Keep the default variables, ensure that PERWT is there
Click view cart and you will be emailed once the dataset is ready.
Download the dataset into the inputs folder.


Scripts contain R scripts that take inputs and produce outputs. These are:

run build-model.R to clean the dataset from Nationscape (saved in inputs/training_data.Rda)
and build a model (saved in model/model_name.rds)

run 01-data_cleaning-post-strat.R in order to clean the ACS dataset, this will be saved under inputs/cleaned_acs.csv

run mrp.R in order to generate some aggregates and predictions for the MRP (saved in processed_data)
run predict.R in order to generate a prediction of the popular vote (saved in processed_data)

under Outputs/paper you will find our RMarkdown file and the PDF of our paper
