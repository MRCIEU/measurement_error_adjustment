/* this just tests out stata */

/* to run this do file you need to have Data_Dictionary_Showcase.csv uploaded */

global DATA "~/meas_error/data"
global RESULTS "~/meas_error/results"

cd $RESULTS

   clear
import delimited "$DATA/Data_Dictionary_Showcase.csv", delimiter(",")

   drop path link

   gen excl=0

*exclusion 1 - not data but bulk/records/samples
   tab itemtype, missing
   replace excl=1 if itemtype ~= "Data"

*exclusion 2 - not Primary/Derived but Auxiliary/Support variables
   tab strata, missing
   replace excl=2 if strata~="Primary" & strata~="Derived" & excl==0

*exclusion 3 - not integer/continuous but categorical/compund/date/time/text
   tab valuetype, missing
   replace excl=3 if valuetype~="Integer" & valuetype~="Continuous" & excl==0

*exclusion 4 - exclude those with no repeat measures
   tab instances, missing
   replace excl=4 if instances<=1 & excl==0

*exclusion 5 - manually identified exclusions
   replace excl=5 if inlist(fieldid,20033,20034,84,87,92,4260)
   replace excl=5 if inlist(fieldid,5983,5984,5986,5992,5993,396,397,398,399,400,403,404)
   replace excl=5 if inlist(fieldid,20006,20008,20009,20010,20011,40008)
*   list fieldid field array if excl==5

   tab excl

   save "full_vars_list.dta", replace

   keep if excl>0
   disp "Number of variables excluded"
   count

export delimited using "$RESULTS/excl_vars_list.txt", delimiter(tab) replace

   use full_vars_list, clear
   keep if excl==0
   disp "Number of variables kept"
   count

   save "used_vars_list.dta", replace

export delimited using "$RESULTS/used_vars_list.txt", delimiter(tab) replace

*check how many have multiple readings in arrays
   disp "Number with multiple in arrays"
   count if array>1
   sort category fieldid
   keep if array>1

export delimited using "$RESULTS/arrays.txt", delimiter(tab) replace

   use used_vars_list, clear

*add extra rows for the 2 instances and the arrays
   expand 2
   bysort fieldid: gen instnum=_n-1

   expand array
   bysort fieldid instnum: gen arraynum=_n-1

*some hearing fields have arrays that start at 1 and not 0
   replace arraynum=arraynum+1 if inlist(fieldid,4230,4233,4241,4244)
 
   tostring fieldid, gen(fieldnum)
   tostring instnum, replace
   tostring arraynum, replace

   gen fieldcode=fieldnum + "-" + instnum + "." + arraynum

   drop fieldnum instnum arraynum instances

   count

save "fieldcodes.dta", replace

export delimited using "$RESULTS/fieldcodes.txt", delimiter(tab) replace

