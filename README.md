# Measurement Error Adjustment using UK Biobank Phenotype data

This code relates to the article:
Rutter CE, Millard LAC, Borges MC and Lawlor DA. Exploring regression dilution bias using repeat measurements of 2858 variables in up to 49 000 UK Biobank participants (submitted to IJE)

There are two components:

Part 1	An illustrative example to adjust for random measurement error in the main exposure and confounders of the association between C-reactive protein and mortality. Can be adapted for other variables and associations.

Part 2	Calculating Intraclass correlation coefficients (ICC) and associated correction factor data for all repeatedly measured, continuous variables in UK Biobank.

Both parts require Stata version 16, run in batch.
Set directories at the top of the Stata do files with your own path and folders as follows:
global DATA "/your/data/path/and/folder"
global RESULTS "/your/results/path/and/folder"
global CODE “/your/code/path/and/folder”

Must have the following data files:

Tab delimited text file of UK Biobank phenotype data

Text file list of withdrawn participants ids

Data dictionary in csv format from the UK Biobank Showcase (www.ukbiobank.ac.uk>Data Showcase>Essential Information>Requesting data and using the UK Biobank showcase>Data Dictionary)

Note - the code uses an extra file containing date fields from UK Biobank, which were not in the main file, but this is not necessary if all the required data is in the main file.

# Part 1 – Illustrative example of accounting for measurement error in exposure and confounders.

1.	getmodeldata.sh
This selects the relevant data for the example from the main files using shell script only. It contains the variable list for relevant exposures and confounders that can be adapted for other models.
Requires –ukbdata_new.txt 
Main output – modelfile.txt 

2.	modelexcl.sh
This calls Stata to run modelexcl.do, which excludes withdrawn participants, renames and formats variables. Creates mortality outcomes and confounders.
Requires - modelfile.txt and withdrawal file w16729_20220222.csv
Main output - modelfile_all.dta and modelfile_comp.dta

3.	bootmodels1.sh to bootmodels10.sh
These create bootstrap replicates of the hazard models using regression calibration.
Requires – modelfile_comp.dta
Main output – boots_1.dta to boots_10.dta

4.	runmodels.sh
This calls Stata to run runmodels.do, which fits an unadjusted proportional hazard model, along with models adjusted for random measurement error using ICC correction factors and regression calibration.
Requires – modelfile_all.dta, modelfile_comp.dta and boots_1.dta to boots_10.dta
Main output – results in runmodels.log

# Part 2 - Calculating ICC and correction factors for all UK Biobank continuous variables.

Process for baseline and online diet variables fields

1.	varlist_01.sh 
This calls Stata to run varlist_01.do, which creates a variable list by running initial exclusions on data dictionary.
Requires – Data_Dictionary_Showcase.csv
Main output – fields01.txt 

2.	getdata_01.sh
This extracts required variables from UK Biobank file using shell script only.
Requires – fields01.txt, ukbdata_new.txt 
Main output – mainfile01.txt

3.	rundata_01.sh
This calls Stata to run rundata_01.do which calls the following do files in turn:
withdrawals_01.do – excludes the ids of participants who have withdrawn consent
Requires – withdrawal csv file e.g. w16729_20220222.csv
Main output – mainfile01.dta
dates_01.do - adds on the dates that were missing from the main file, renames and reformats date fields.
Requires – mainfile01.dta, extra dates file (new_dates_data.csv)
Main output – mainfile01.dta
arrays_01.do – deals with specific fields with multiple values in one visit.
Requires – mainfile01.dta
Main output – mainfile01.dta
recodes_01.do - amends some of the special coded non-numeric values
Requires – mainfile01.dta
Main output – mainfile01.dta
extraexcl_01.do – checks and removes
a.	variables with <20 distinct values per instance (for observations non missing in both instances)
b.	variables with fewer than 100 observations non missing in both instances
c.	variables with >=20% of non-missing observations having one single value (should be categorical)
Requires - mainfile01.dta
Main output - finalfile01.dta
concord_01.do – run concordance analysis and get ICC for all records
Requires – finalfile01.dta, used_vars_list01.dta
Main output – concordance_output01.dta, concordance_output.xlsx

4.	graphs.sh
This calls Stata to run graphs.do which creates the graphs included in the paper.
Requires – concordance_output.xlsx

Process for imaging visit fields
Same as above but replace script file names with _23 instead of _01.
The imaging programs are similar but split the file into three due to size.
