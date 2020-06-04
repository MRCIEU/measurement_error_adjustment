/* this excludes the ids who have withdrawn consent and then adds the dates from the other file */
/* need to use the most up to date file */
/* current file is w16729_20200004.csv */

/* date created 07052020 */

global DATA "~/meas_error/data"
global RESULTS "~/meas_error/results"

cd $RESULTS

import delimited f_eid using "$DATA/w16729_20200204.csv", delimiter(",") clear
sort f_eid
save exclusions.dta, replace

list if _n<=5
 
import delimited f_eid f_53_0_0 f_53_1_0 f_53_2_0 f_53_3_0 f_21842_0_0 f_21842_1_0 f_21842_2_0 f_21842_3_0 f_105010_0_0 f_105010_1_0 ///
    f_101010_2_0 f_105010_3_0 f_105010_4_0 using "$DATA/new_dates_data.csv", delimiter(",") rowr(2) clear 

list if _n<=5
forvalues i = 0/1 {
        gen assess_date`i'=date(f_53_`i'_0,"YMD")
        gen sample_date`i'=date(f_21842_`i'_0,"YMD###")
        gen diet_date`i'=date(f_105010_`i'_0,"YMD###")

        format assess_date`i' %td
        format sample_date`i' %td
        format diet_date`i' %td

        summ assess_date`i'
        summ sample_date`i'
        summ diet_date`i'
}

gen assess_td=assess_date1-assess_date0
gen sample_td=sample_date1-sample_date0
gen diet_td=diet_date1-diet_date0

sort f_eid

keep f_eid assess_date0 assess_date1 sample_date0 sample_date1 diet_date0 diet_date1 assess_td sample_td diet_td
save dates_data.dta, replace

list if _n<=5

import delimited using "$RESULTS/finalfile.txt", delimiter(tab) clear
sort f_eid

list f_eid if _n<=5


merge 1:1 f_eid using exclusions.dta

tab _merge, missing

keep if _merge==1  // master only i.e. not in exclusion file
drop _merge


/*add dates from date file*/

merge 1:1 f_eid using dates_data.dta

tab _merge, missing

drop if _merge==2 // drop if only in dates file otherwise keep
drop _merge

save finalfile.dta, replace

ds

