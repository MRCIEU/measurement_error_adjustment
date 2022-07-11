/* varlist_23.do - Creates a variable list by running initial exclusions on the data dictionary */ 
/* Requires - Data_Dictionary_Showcase.csv uploaded in DATA folder*/
/* Main output - fields23a.txt, fields23b.txt and fields23c.txt in RESULTS folder */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

  clear
   import delimited "$DATA/Data_Dictionary_Showcase.csv", delimiter(",")

  capture drop path link
   gen excl=0

*exclusion 1 - exclude those with no repeat measures
   tab instances, missing
   replace excl=1 if instances<=1 & excl==0

*exclusion 2 - not data but bulk/records/samples
   tab itemtype, missing
   replace excl=2 if itemtype ~= "Data" & excl==0

*exclusion 3 - not Primary/Derived but Auxiliary/Support variables
   tab strata, missing
   replace excl=3 if strata~="Primary" & strata~="Derived" & excl==0

*exclusion 4 - not integer/continuous but categorical/compund/date/time/text
   tab valuetype, missing
   replace excl=4 if valuetype~="Integer" & valuetype~="Continuous" & excl==0

*exclusion 5 - manually identified exclusions
   replace excl=5 if inlist(fieldid, 84, 87, 92, 396, 397, 398, 399, 400, 403, 404)
   replace excl=5 if inlist(fieldid, 4230, 4233, 4241, 4244, 4260, 5983, 5984, 5986, 5992, 5993)
   replace excl=5 if inlist(fieldid, 20006, 20008, 20009, 20010, 20011, 20033, 20034, 20082, 40007, 40008)
   replace excl=5 if inlist(fieldid, 6313, 6325, 6333, 6770, 6771, 6772, 6773, 22194)
   replace excl=5 if inlist(fieldid, 21611, 21621, 21622, 21625, 21631, 21634, 21642, 21651, 21661, 21662, 21663, 21664, 21665, 21666, 21671)

*exclusion 6 - those with 3 or more instances so we don't repeat from baseline
   replace excl=6 if instances>=3 & excl==0

   tab excl, missing 

   save "full_vars_list_23.dta", replace

   keep if excl>0
   disp "Number of variables excluded"
   count

export delimited using "$RESULTS/excl_vars_list_23.txt", delimiter(tab) replace

   use full_vars_list_23, clear
   keep if excl==0
   disp "Number of variables kept"
   count

   save "used_vars_list23.dta", replace

   export delimited using "$RESULTS/used_vars_list23.txt", delimiter(tab) replace

*check how many have multiple readings in arrays
   disp "Number with multiple in arrays"
   count if array>1
   sort category fieldid
   keep if array>1

export delimited using "$RESULTS/arrays_23.txt", delimiter(tab) replace

*input date fields (only the main date is available not the diet date which is in a separate file)
   clear
   input fieldid array
     53 1
   end
   save datefields23.dta, replace

*create fieldcodes for getting main data, split into 3 files due to limit of number of variables allowed in Stata

   use used_vars_list23, clear
   keep if _n<1000

*add date fields
   append using datefields23

*double the number of rows for the first 2 instances and the arrays
   expand 2
   bysort fieldid: gen instnum=_n+1

   expand array
   bysort fieldid instnum: gen arraynum=_n-1

   tostring fieldid, gen(fieldnum)
   tostring instnum, replace
   tostring arraynum, replace

   gen fieldcode="x" + fieldnum + "_" + instnum + "_" + arraynum

   drop fieldnum instnum arraynum instances

   count

export delimited using "$RESULTS/fields23a.txt", delimiter(tab) replace

   use used_vars_list23, clear
   keep if _n>=1000 &_n<2000

*add date fields
   append using datefields23

*double the number of rows for the first 2 instances and the arrays
   expand 2
   bysort fieldid: gen instnum=_n+1

   expand array
   bysort fieldid instnum: gen arraynum=_n-1

   tostring fieldid, gen(fieldnum)
   tostring instnum, replace
   tostring arraynum, replace

   gen fieldcode="x" + fieldnum + "_" + instnum + "_" + arraynum

   drop fieldnum instnum arraynum instances

   count

   export delimited using "$RESULTS/fields23b.txt", delimiter(tab) replace

   use used_vars_list23, clear
   keep if _n>=2000

*add date fields
   append using datefields23

*double the number of rows for the first 2 instances and the arrays
   expand 2
   bysort fieldid: gen instnum=_n+1

   expand array
   bysort fieldid instnum: gen arraynum=_n-1

   tostring fieldid, gen(fieldnum)
   tostring instnum, replace
   tostring arraynum, replace

   gen fieldcode="x" + fieldnum + "_" + instnum + "_" + arraynum

   drop fieldnum instnum arraynum instances

   count

   export delimited using "$RESULTS/fields23c.txt", delimiter(tab) replace

