# Measurement Error Adjustment using UK Biobank Phenotype data

Environment:
Uses Stata15

Set directories temporarily at the top of  the Stata do files with:
global DATA "~/meas_error/data"
global RESULTS "~/meas_error/results"

Data needed:
Must have a data file of phenotype data called ukbdata.csv and 
a data dictionary from the UK Biobank Showcase
www.ukbiobank.ac.uk > Data Showcase > Essential Information > 
Requesting data and using the UK Biobank showcase > Data Dictionary
called Data_Dictionary_Showcase.csv

Must run scripts in order:

varlist.sh runs varlist.do 
   creates the list of required fields to extract from the main data

getdata.sh 
   extracts the varlist fields from the main data

arrays.sh runs arrays.do
   calculates the required one value per instance from variables with multiple values in the arrays.
   The method for each variable needs to have been decided manually.

check20.sh runs check20.do
   First, this takes out any default values (or renumbers them e.g. for something counted as year,
   less than 1 year would be 0)
   Then this checks for at least 20 distinct values (not counting missing) from observations that contain 
   non missing values for both instances.

concord.sh run concord.do
  this completed the concordance analysis and produces bland altman plots for the remaining variables.

checks.do
this does some final checks of the output

