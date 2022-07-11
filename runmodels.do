/* runmodels.do - This fits unadjusted proportional hazard model along with models adjusted for random measurement error */ 
/* Requires - modelfile_all.dta, modelfile_comp.dta and boots_1a.dta, boots_1b.dta to boots_5a.dta, boots_5b.dta */
/* Main output - results in runmodels.log */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

use modelfile_all.dta, clear

*get correction factor using all available data
*ICC two way mixed effects
   reshape long crp, i(eid) j(meas)
   icc crp eid meas, mixed absolute

   local n=r(N_target)
   local icc=r(icc_i)
   local lamda_p=1/`icc'
   local var_lamda_p=(`lamda_p'^2-1)^2/`n'
   local var_inv_lamda_p=`var_lamda_p'/(`lamda_p'^4)

   mixed crp meas || eid:

*use complete data
   use modelfile_comp, clear

*predictions for regression calibration

*CRP with confounders
   regress crp1 crp0 deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
   predict crp_hat, xb

*BMI with other confounders and exposure
   regress bmi1 bmi0 crp0 deprive age i.sex i.ethnic2 smoking0 i.drink
   predict bmi_hat, xb

*smoke pack with other confounders and exposure
   regress smokpack1 smokpack0 crp0 deprive age i.sex i.ethnic2 bmi0 i.drink
   predict smokpack_hat, xb

   gen smoking_hat=smokpack_hat
   replace smoking_hat = . if smokever0==. & smokpack_hat==.
   replace smoking_hat = 0 if smokever0==0 & smokpack_hat==.
   replace smoking_hat = . if smokever0==1 &smokagestop0<=0 & smokpack_hat==.
   replace smoking_hat = 0 if smokever0==1 &smokagestop0>0 &smokagestop0<=16 & smokpack_hat==.
   replace smoking_hat = . if smokever0==1 &smokagestop0>16 &smokagestop0<. & smokpack_hat==.
   replace smoking_hat = . if smokever0==1 &smokagestop0==. & smokpack_hat==.
   sum smoking_hat

*output file
   postfile results str12 name1 value1 using observed_results.dta, replace

*check number of years follow up and set survival parameters
   gen years=time/365.25
   stset years, failure(mort_all)
   sum years
   local N1=r(N)
   local sum_years=r(sum)
   quietly sum mort_all
   local sum_all=r(sum)
   quietly sum mort_cvd
   local sum_cvd=r(sum)
   quietly sum mort_cancer
   local sum_cancer=r(sum)

   di "Number of years per person"
   di `sum_years'/`N1'
   di "All-cause mortality rate"
   cii means `sum_years' `sum_all', poisson
   di "CVD mortality rate"
   cii means `sum_years' `sum_cvd', poisson
   di "Cancer mortality rate"
   cii means `sum_years' `sum_cancer', poisson

*run cox models
   foreach mort in all cvd cancer {

*reset survival parameters
     stset time, failure(mort_`mort')

*Model 1 - uncorrected
     stcox crp0 deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink, nohr
     matrix define H=r(table)

     di "`mort' uncorrected"
*get coefficients and ci (need to transform back to hazard)
     local b_`mort' = el(H,1,1)
     local hr_`mort' = exp(`b_`mort'')
     local var_b_`mort' = el(H,2,1)^2
     local cill_`mort' = el(H,5,1)
     local hr_cill_`mort' = exp(`cill_`mort'')
     local ciul_`mort' = el(H,6,1)
     local hr_ciul_`mort' = exp(`ciul_`mort'')
     local f0_`mort' = `b_`mort''^2 - (1.96^2*`var_b_`mort'')

     di "`mort' icc"
*adjusted by icc correction factor
     local b_p_`mort' = `b_`mort''*`lamda_p'
     local hr_p_`mort' = exp(`b_p_`mort'')
     local f1_p_`mort' = `b_`mort''/`lamda_p'
     local f2_p_`mort' = (1/`lamda_p'^2)-(1.96^2*`var_inv_lamda_p')
     local cill_p_`mort' = (`f1_p_`mort'' - sqrt(`f1_p_`mort''^2-`f0_`mort''*`f2_p_`mort''))/`f2_p_`mort''
     local hr_cill_p_`mort' = exp(`cill_p_`mort'')
     local ciul_p_`mort' = (`f1_p_`mort'' + sqrt(`f1_p_`mort''^2-`f0_`mort''*`f2_p_`mort''))/`f2_p_`mort''
     local hr_ciul_p_`mort' = exp(`ciul_p_`mort'')

     di "`mort' rc exposure"

*Model 2 - regression calibrated model with correction for exposure
     stcox crp_hat deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
     matrix define H=r(table)

*get coefficients (already hazards)
     local e_hr_`mort' = el(H,1,1)
     local e_hr_cill_`mort' = el(H,5,1)
     local e_hr_ciul_`mort' = el(H,6,1)
     post results ("corre_`mort'") (`e_hr_`mort'')

     di "`mort' rc exposure and confounders"

*Model 3 - regression calibrated model with correction for crp and smoking and bmi
     stcox crp_hat deprive age i.sex i.ethnic2 bmi_hat smoking_hat i.drink
     matrix define H=r(table)

*get coefficients (already hazards)
     local ec_hr_`mort' = el(H,1,1)
     local ec_hr_cill_`mort' = el(H,5,1)
     local ec_hr_ciul_`mort' = el(H,6,1)
     post results ("correc_`mort'") (`ec_hr_`mort'')
   }

postclose results

*display results
   di "n = `n'"
   di "ICC = `icc'" 
   di "correction factor lamda using ICC = `lamda_p'" 
   di "variance of lamda_p = `var_lamda_p'"
   di "variance of 1/lamda_p = `var_inv_lamda_p'"

   foreach mort in all cvd cancer {
     di "mortality `mort'"
     di "b=`b_`mort''"
     di "var b=`var_b_`mort''"
     di "f0=`f0_`mort''"
     di "f1 icc=`f1_p_`mort''" 
     di "f2 icc=`f2_p_`mort''"
     di "Uncorrected `mort' HR: `hr_`mort'' (`hr_cill_`mort'',`hr_ciul_`mort'')
     di "Corrected `mort' HR using ICC: `hr_p_`mort'' (`hr_cill_p_`mort'',`hr_ciul_p_`mort'')
     di "Exposure RC `mort' HR: `e_hr_`mort'' (`e_hr_cill_`mort'',`e_hr_ciul_`mort'')
     di "Exp+Conf RC `mort' HR: `ec_hr_`mort'' (`ec_hr_cill_`mort'',`ec_hr_ciul_`mort'')
   }
 
   use observed_results.dta, clear
   mkmat value1, matrix(observed) rownames(name1)
   matlist observed
     
*use boostrap replicates for regression calibration CIs (remember to amend sample size n)
   clear
   append using boots_1a boots_1b boots_2a boots_2b boots_3a boots_3b boots_4a boots_4b boots_5a boots_5b 
   save boots10000.dta, replace

   bstat corre_all correc_all corre_cvd correc_cvd corre_cancer correc_cancer, stat(observed') n(317917)


