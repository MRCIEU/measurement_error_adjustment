# Measurement Error Adjustment using UK Biobank Phenotype data

Environment:
Uses Stata15

Set directories temporarily at the top of  the Stata do files with:
global DATA "~/meas_error/data"
global RESULTS "~/meas_error/results"

Data needed:
Must have a data file of phenotype data called ukbdata.csv, a list of wihtdrawn participants if necessary and in my case and extra ukb file with some date fields new_datas_data.csv plus a data dictionary from the UK Biobank Showcase
www.ukbiobank.ac.uk > Data Showcase > Essential Information > 
Requesting data and using the UK Biobank showcase > Data Dictionary
called Data_Dictionary_Showcase.csv

Must run scripts in order:

varlist.sh runs varlist.do 
   creates the list of required fields to extract from the main data

getdata.sh 
   extracts the varlist fields from the main data

exclusions.sh runs exclusions.do
   merges the output from the last script with the list of withdrawn participants to remove them and also adds on the date fields that were in a separate file
   
arrays.sh runs arrays.do
   calculates the required one value per instance from variables with multiple values in the arrays.
   The method for each variable needs to have been decided manually.

check20.sh runs check20.do
   First, this takes out any default values (or renumbers them e.g. for something counted as year,
   less than 1 year would be 0)
   Then this checks for at least 20 distinct values (not counting missing) from observations that contain 
   non missing values for both instances.

concord.sh runs concord.do
  this completesukbio the concordance analysis for the remaining variables.
