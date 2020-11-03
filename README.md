# Overview

This repo contains code and data for forecasting the US 2020 presidential election. It was created by James Bao, Zakir Chaudry, Alan Chen, Xinyi Zhang. The purpose is to create a report that summarizes the results of a statistical model that we built. Some data is unable to be shared publicly. We detail how to get that below. The sections of this repo are: inputs, outputs, scripts.

Inputs contain data that are unchanged from their original. We use two datasets:

- [Survey data]

Go to https://www.voterstudygroup.org/publication/nationscape-data-set
Scroll to the bottom of the page and enter information in order to request the datasets
Once the dataset is emailed, download it and extract the folder that contains the DTA files
go into phase_2 folder
copy folder titled ns20200625 into the repos input folder


- [ACS data]

Go to https://usa.ipums.org/usa/index.shtml
Create an account and click on Get Data in the middle of your screen
Click on Change Samples, and deselect everything except the 2018 ACS.
Next add desired variables. For this repo, you will need:
  - STATEICP
  - RACE
  - SEX
  - EDUC
  - AGE
Keep the default variables, ensure that PERWT is there
Click view cart and you will be emailed once the dataset is ready
download the dataset into the inputs folder.

Outputs contain data that are modified from the input data, the report and supporting material.

under the outputs/paper folder you will find our pdf, and rmd containing our paper

Scripts contain R scripts that take inputs and outputs and produce outputs. These are:

run build-model.R to clean the dataset from Nationscape (saved in inputs/training_data.Rda)
and build a model (saved in model/model_name.rds)

run clean-post-strat.R inorder to clean the ACS dataset, this will be saved under inputs/cleaed_acs.csv

lastly run mrp.R in order to generate some aggregates and predictions for the MRP
