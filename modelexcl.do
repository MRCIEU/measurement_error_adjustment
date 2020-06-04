/* this excludes the ids who have withdrawn consent and adds on the dates */
/* need modelfile.txt from getmodeldata.sh and stata exclusion and dates files */

global DATA "~/meas_error/data"
global RESULTS "~/meas_error/results"

cd $RESULTS

/* read in model data to stata */
import delimited using "$RESULTS/modelfile.txt", delimiter(tab) clear
sort f_eid

list f_eid if _n<=5

/* remove those who have withdrawn consent */

merge 1:1 f_eid using exclusions.dta

tab _merge, missing

keep if _merge==1  // master only i.e. not in exclusion file
drop _merge


/*add dates from date file*/

merge 1:1 f_eid using dates_data.dta

tab _merge, missing

drop if _merge==2 // drop if only in dates file otherwise keep
drop _merge

save modelfile.dta, replace

ds

