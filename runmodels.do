
/* needs modelfile.dta from modelexcl.do which contains all the data for those variables*/

global DATA "~/meas_error/data"
global RESULTS "~/meas_error/results"

cd $RESULTS

use modelfile.dta, clear

/* summarize the variables */
rename f_31_0_0 sex
rename f_21003_0_0 age0
rename f_21003_1_0 age1
rename f_40001_0_0 death_icd
rename f_40007_0_0 death_age
*gen death_date=date(f_40000_0_0,"YMD")
*format death_date %td
*drop f_40000_0_0

/* temporarily use age which is truncated, ahead of getting date of death */
gen timetodeath0=round((death_age-age0)*365.25,1)
gen timetodeath1=round((death_age-age1)*365.25,1)
*gen timetodeath0=death_date-assess_date0
*gen timetodeath1=death_date-assess_date1

tab sex, missing
sum age0
sum age1
sum age_death
sum assess_td
sum sample_td
sum diet_td
sum timetodeath0
sum timetodeath1

gen ageband1=0
replace ageband1=1 if age1>40
replace ageband1=2 if age1>50
replace ageband1=3 if age1>60
replace ageband1=. if age1==.

tab ageband1, missing

gen ageband0=0
replace ageband0=1 if age0>40
replace ageband0=2 if age0>50
replace ageband0=3 if age0>60
replace ageband0=. if age0==.

tab ageband0, missing

/* calculate outcome of death within 5 years (all cause) */
gen died5_0=0
gen died5_1=0
replace died5_0=1 if age_death<age0+5
replace died5_0=. if age0==.
replace died5_1=1 if age_death<age1+5
replace died5_1=. if age1==.

/* set survival parameters */
stset timetodeath0 died5_0


/* redo the concordance and create some graphs */

ssc install concord
postfile results str10 model str30 exposure n mort OR LL UL pval using exampleoutput.dta, replace

/* first, calculate the mean for the Peak Expiratory Flow */
/*  forvalues inst = 0/1 {
      gen num=0
      gen val=0
      forvalues count = 0/2 {
         replace num=num+1 if f_3064_`inst'_`count' < .
         replace val=val+f_3064_`inst'_`count' if f_3064_`inst'_`count' < .
         drop f_3064_`inst'_`count'
      }
      gen f_3064_`inst'_0=val/num if num>0
      drop num val
}*/


/* get BA plots */ 
 
concord f_30800_1_0 f_30800_0_0, loa(title(Bland Altman plot of field Blood Oestradiol) graphregion(color(white)) bgcolor(white))
graph save BAplot_30800, replace


/* run crude cox models */

/* all initial values */

stset timevar died5_0

sum died5_0 if f_`fnum'_0_0<.
local mort=r(mean)
logistic died5_0 f_`fnum'_0_0
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("all init") (`n') (`mort') (`OR') (`LL') (`UL') (`pval') 
*/
/*initial values who have a repeat*/
/*sum died5_0 if f_`fnum'_0_0<. & f_`fnum'_1_0<.
local mort=r(mean)
logistic died5_0 f_`fnum'_0_0 if f_`fnum'_1_0<.
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("init rep") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
/*initial values who have a repeat using mort1*/
/*sum died5_1 if f_`fnum'_0_0<. & f_`fnum'_1_0<.
local mort=r(mean)
logistic died5_1 f_`fnum'_0_0 if f_`fnum'_1_0<.
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("init repm") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
/*repeat values (who have a repeat and initial)*/
/*sum died5_1 if f_`fnum'_0_0<. & f_`fnum'_1_0<.
local mort=r(mean)
logistic died5_1 f_`fnum'_1_0 if f_`fnum'_0_0<.
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("repeats") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
/*now using confounders*/

/*all initial values*/
/*sum died5_0 if f_`fnum'_0_0<.
local mort=r(mean)
logistic died5_0 f_`fnum'_0_0 sex ageband0
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("all init c") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
/*initial values with a repeat*/
/*sum died5_0 if f_`fnum'_0_0<. & f_`fnum'_1_0<.
local mort=r(mean)
logistic died5_0 f_`fnum'_0_0 sex ageband0 if f_`fnum'_1_0<.
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("init rep c") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
/*initial values with a repeat using mort1*/
/*sum died5_1 if f_`fnum'_0_0<. & f_`fnum'_1_0<.
local mort=r(mean)
logistic died5_1 f_`fnum'_0_0 sex ageband0 if f_`fnum'_1_0<.
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("init repmc") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
/*for repeat values (who also have initial)*/
/*sum died5_1 if f_`fnum'_0_0<. & f_`fnum'_1_0<.
local mort=r(mean)
logistic died5_1 f_`fnum'_1_0 sex ageband0 if f_`fnum'_0_0<.
matrix define H = r(table)
matrix list H
local n=e(N)
local OR=el(H,1,1)
local LL=el(H,5,1)
local UL=el(H,6,1)
local pval=el(H,4,1)
post results ("`fnum'") ("repeats c") (`n') (`mort') (`OR') (`LL') (`UL') (`pval')
*/
postclose results

save $RESULTS/modelfile2.dta, replace

export delimited $RESULTS/modelfile2.txt, delimiter(tab) replace 
