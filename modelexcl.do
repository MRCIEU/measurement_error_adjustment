/* this excludes the ids who have withdrawn consent and adds on the dates */
/* need modelfile.txt from getmodeldata.sh and withdrawal file w16729_20220222.csv */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

* get those who have withdrawn consent
 import delimited f_eid using "$DATA/w16729_20220222.csv", delimiter(",") clear
 sort f_eid
 rename f_eid eid
 save withdrawals.dta, replace

* read in model data to stata and merge out withdrawals
import delimited using "$RESULTS/modelfile.txt", delimiter(tab) clear
sort eid
merge 1:1 eid using withdrawals.dta, keep(master) nogen // master only i.e. not in withdrawal file

gen assess_date=date(x53_0_0,"YMD")
format assess_date %td
summ assess_date

gen death_date=date(x40000_0_0,"YMD")
format death_date %td
summ death_date

drop x53_0_0  x40000_0_0

rename x30710_0_0 crp0
rename x30710_1_0 crp1
rename x31_0_0 sex
rename x21000_0_0 ethnic
rename x21001_0_0 bmi0
rename x21001_1_0 bmi1
rename x21003_0_0 age
rename x2897_0_0 smokagestop0
rename x2897_1_0 smokagestop1
rename x20116_0_0 smokstat0
rename x20116_1_0 smokstat1
rename x20160_0_0 smokever0
rename x20160_1_0 smokever1
rename x20161_0_0 smokpack0
rename x20161_1_0 smokpack1
rename x1558_0_0 drink
rename x20414_0_0 alcfreq
rename x20416_0_0 alcfreq6
rename x26410_0_0 deprive_eng
rename x26426_0_0 deprive_wal
rename x26427_0_0 deprive_sco
rename x40007_0_0 deathage
rename x40001_0_0 icd

save modelfile.dta, replace

use modelfile.dta, clear

*outcomes
gen icdshort=substr(icd,1,3)
tab icdshort
gen icdcat=substr(icd,1,1)
gen icdnum=substr(icd,2,2)
destring icdnum, replace
tab icdcat

*final censorship date 28feb2021 (22339 in stata)
capture drop time
drop if assess_date==.
gen time=22339-assess_date
*reset death date if after end of censorship
replace death_date=. if death_date>22339
replace time=death_date-assess_date if death_date<.

gen mort_all=0
replace mort_all=1 if death_date<.
gen mort_cvd=0
replace mort_cvd=1 if death_date<. & icdcat=="I" & (icdnum<=9 | icdnum==11 | icdnum==13 | ///
        (icdnum>=20 & icdnum<=51) | (icdnum>=60 & icdnum<=69))
gen mort_cancer=0
replace mort_cancer=1 if death_date<. & icdcat=="C"

*confounders
sum age
sum deprive_eng
sum deprive_wal
sum deprive_sco
tab ethnic, missing
sum smokpack0
sum smokpack1
sum drink
sum bmi0
sum bmi1

label define sex 0 "Female" 1 "Male", replace
label values sex sex
tab sex, missing

count if deprive_wal==. & deprive_sco==. & deprive_eng==.
gen deprive=deprive_eng if deprive_eng<.
replace deprive=deprive_wal if deprive_wal<. & deprive_eng==.
replace deprive=deprive_sco if deprive_sco<. & deprive_wal==. & deprive_eng==.
sum deprive
count if deprive==.

gen ethnic2=ethnic
replace ethnic2=. if ethnic<0
replace ethnic2=1 if ethnic>=1000 & ethnic<2000
replace ethnic2=2 if ethnic>=2000 & ethnic<3000
replace ethnic2=3 if ethnic>=3000 & ethnic<4000
replace ethnic2=4 if ethnic>=4000 & ethnic<5000
tab ethnic2, missing
label define ethnic 1 "White" 2 "Mixed" 3 "Asian or Asian British" ///
             4 "Black or Black British" 5 "Chinese" 6 "Other", replace
label values ethnic2 ethnic
tab ethnic2, missing

tab drink, missing
replace drink=. if drink<0
label define drink 1 "Daily or almost daily" 2 "3-4 times a week" 3 "1-2 times a week" ///
             4 "1-3 times a month" 5 "Special occasions" 6 "Never", replace
label values drink drink
tab drink, missing

label define smokstat 0 "Never" 1 "Previous" 2 "Current", replace
label values smokstat0 smokstat
label values smokstat1 smokstat
tab smokstat0 smokstat1, missing

label define smokever 0 "No" 1 "Yes", replace
label values smokever0 smokever
label values smokever1 smokever
tab smokever0 smokever1, missing

sum smokagestop0 
sum smokagestop1

forvalues i=0/1 {
  replace smokstat`i'=. if smokstat`i'<0
  gen smoking`i' = smokpack`i'
  replace smoking`i' = -1 if smokever`i'==. & smokpack`i'==.
  replace smoking`i' = 0 if smokever`i'==0 & smokpack`i'==.
  replace smoking`i' = -2 if smokever`i'==1 &smokagestop`i'<=0 & smokpack`i'==.
  replace smoking`i' = 0 if smokever`i'==1 &smokagestop`i'>0 &smokagestop`i'<=16 & smokpack`i'==.
  replace smoking`i' = -3 if smokever`i'==1 &smokagestop`i'>16 &smokagestop`i'<. & smokpack`i'==.
  replace smoking`i' = -4 if smokever`i'==1 &smokagestop`i'==. & smokpack`i'==.
  tab smoking`i', missing
  replace smoking`i'=. if smoking`i'<0
}

save modelfile_all.dta, replace

*keep complete data
drop if crp0==. | sex==. | ethnic2==. | smoking0==. | drink==. | deprive==. | bmi0==. | age==.

save modelfile_comp.dta, replace

