/* dates_23.do - Add the diet date field that is in a separate file and rename and reformat the date fields */
/* Requires - mainfile23a.dta, mainfile23b.dta and mainfile23c.dta */
/* Main output - mainfile23a.dta, mainfile23b.dta and mainfile23c.dta */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*read dates file into Stata 
 import delimited eid x53_0_0 x53_1_0 x53_2_0 x53_3_0 x21842_0_0 x21842_1_0 x21842_2_0 x21842_3_0 x105010_0_0 x105010_1_0 ///
    x105010_2_0 x105010_3_0 x105010_4_0 using "$DATA/new_dates_data.csv", delimiter(",") rowr(2) clear
 sort eid
 drop x53_* x21842_*
 save dates23.dta, replace

 foreach f in a b c {

*get main data and merge on dates
    use mainfile23`f'.dta, clear
    sort eid
    merge 1:1 eid using dates23.dta, keep(match master) nogen

*rename and format all date fields
    forvalues i = 2/3 {
      gen assess_date`i'=date(x53_`i'_0,"YMD")
      gen diet_date`i'=date(x105010_`i'_0,"YMD###") 
      format assess_date`i' %td
      format diet_date`i' %td
      summ assess_date`i'
      summ diet_date`i'
    }

    gen assess_td=assess_date3-assess_date2 
    gen diet_td=diet_date3-diet_date2

    drop x53_* x105010_*

    order eid assess_date2 assess_date3 assess_td diet_date2 diet_date3 diet_td

    ds
    local fidlist=r(varlist)
    local numvars=wordcount("`fidlist'")
    disp "Number of variables = `numvars'"

    save mainfile23`f'.dta, replace
 }
