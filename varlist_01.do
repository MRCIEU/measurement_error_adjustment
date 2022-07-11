/* varlist_01.do - Creates a variable list by running initial exclusions on the data dictionary */
/* Requires - Data_Dictionary_Showcase.csv uploaded in DATA folder*/
/* Main output - fields01.txt in RESULTS folder */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

   clear
   import delimited "$DATA/Data_Dictionary_Showcase.csv", delimiter(",")

*remove unnecessary variables and create exclusion flag
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

   tab excl
 
*categorize online diet variables separately 
   gen online=0
   replace online=1 if category==100090 | category==100097 | category==100098 ///
                       | (category>=100100 & category<=100112) | category==100114
   tab excl online

   save "full_vars_list01.dta", replace

   keep if excl>0
   disp "Number of variables excluded"
   count

   export delimited using "$RESULTS/excl_vars_list01.txt", delimiter(tab) replace

   use full_vars_list01, clear
   keep if excl==0
   disp "Number of variables kept"
   count

   save "used_vars_list01.dta", replace

   export delimited using "$RESULTS/used_vars_list01.txt", delimiter(tab) replace

*check how many have multiple readings in arrays
   disp "Number with multiple in arrays"
   count if array>1
   sort category fieldid
   keep if array>1

   export delimited using "$RESULTS/arrays01.txt", delimiter(tab) replace

*input date fields (only the main date is available not the diet date which is in a separate file)
   clear
   input fieldid array
     53 1
   end
   save datefields01.dta, replace

*create fieldcode list for getting main data
   use used_vars_list01, clear

*add date fields
   append using datefields01

*double the number of rows for the first 2 instances
   expand 2
   bysort fieldid: gen instnum=_n-1

*for online diet fields change instance to 1 and 2 instead of 0 and 1
   replace instnum=instnum+1 if online==1  

*increase the number of rows for the arrays
   expand array
   bysort fieldid instnum: gen arraynum=_n-1

   tostring fieldid, gen(fieldnum)
   tostring instnum, replace
   tostring arraynum, replace

*create field names to match UK Biobank file
   gen fieldcode="x" + fieldnum + "_" + instnum + "_" + arraynum

   drop fieldnum instnum arraynum instances online
   count

export delimited using "$RESULTS/fields01.txt", delimiter(tab) replace

