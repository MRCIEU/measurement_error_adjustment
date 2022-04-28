/* this adds the diet date field that is in a separate file */
/* it also renames and reformats the date fields */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*read dates file into Stata 

  import delimited eid x53_0_0 x53_1_0 x53_2_0 x53_3_0 x21842_0_0 x21842_1_0 x21842_2_0 x21842_3_0 x105010_0_0 x105010_1_0 ///
    x105010_2_0 x105010_3_0 x105010_4_0 using "$DATA/new_dates_data.csv", delimiter(",") rowr(2) clear
  sort eid
  drop x53_* x21842_*
  save dates01.dta, replace

*get main data and merge on dates
  use mainfile01.dta, clear
  sort eid

  merge 1:1 eid using dates01.dta, keep(match master) nogen

*rename and format all date fields
  forvalues i = 0/1 {
        local j=`i'+1
        gen assess_date`i'=date(x53_`i'_0,"YMD")
        format assess_date`i' %td
        summ assess_date`i'
        *diet fields are one instance ahead
        local j=`i'+1
        gen diet_date`j'=date(x105010_`j'_0,"YMD###")
        format diet_date`j' %td
        summ diet_date`j'
  }

  gen assess_td=assess_date1-assess_date0 
  gen diet_td=diet_date2-diet_date1

  drop x53_* x105010_*

  order eid assess_date0 assess_date1 assess_td diet_date1 diet_date2 diet_td

  ds
  local fidlist=r(varlist)
  local numvars=wordcount("`fidlist'")
  disp "Number of variables = `numvars'"

  save mainfile01.dta, replace

