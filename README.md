# Measurement Error Adjustment using UK Biobank Phenotype data

Environment:
Uses Stata16

Set directories temporarily at the top of the Stata do files with:
global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

Data needed:
Must have a tab delimited text file of phenotype data called ukbdata_new.txt, a list of wihtdrawn participants, a data dictionary from the UK Biobank Showcase
and in my case an extra file with some date fields new_datas_data.csv
www.ukbiobank.ac.uk > Data Showcase > Essential Information > 
Requesting data and using the UK Biobank showcase > Data Dictionary
called Data_Dictionary_Showcase.csv

To get ICC and concordance information for all variables:
Must run 3 scripts in order for each pair of instances nn (01 or 23).

varlist_nn.sh runs varlist_nn.do 
   calls Stata to create the list of required fields to extract from the main data using a csv file from showcase

getdata_nn.sh 
   extracts the varlist fields from the main data using shell script only

rundata_nn.sh
   call stata programs: 
      withdrawals_nn.do - merges the output from getdata.sh with the list of withdrawn participants to remove them
      dates_nn.do - adds on the dates that were missing from the main file, renames them and  calculates the time difference
      arrays_nn.do - calculates the required one value per instance from variables with multiple values in the arrays. Manually decided.
      recodes_nn.do -  recodes/removes any default values e.g. for number of years, "less than 1 year"=0.5
      extraexcl_nn.do - runs final data exclusions:
 	 1) If there are fewer than 20 distinct values (not counting missing) within an instance for a variable.
	 2) If more than 20% have the same exact value in either instance.
	 3) If there are fewer than 100 people with valid repea values.
      concord_nn.do - calculates statistics including CCC and ICC for all variables.
  
To run illustrative example:
Must run 4 scripts in order.

getmodeldata.sh
   selects the relevant data for the example from the main files using shell script only
   contains variable list for exposures and confounders

modelexcl.sh
   calls Stata program modelexcl.do to clean and organise the data for the example

bootmodels.sh
   calls Stata programs bootmodels1.do, bootmodels2.do, bootmodels3.do, bootmodels4.do and bootmodels5.do to simulate bootstraps
   takes about a day to run

runmodels.sh
   calls Stata program runmodels.do to run main example model, and uses bootstrap files to provide results of example correction
