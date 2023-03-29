/* runmodels.do - This fits unadjusted proportional hazard model along with models adjusted for random measurement error */ 
/* Requires - modelfile_all.dta, modelfile_comp.dta and boots_1.dta to boots_10.dta */
/* Main output - results in runmodels.log */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*get correction factor using all available data
foreach var in crp bvitd rdw {

  use modelfile_all.dta, clear

  *ICC two way mixed effects
     reshape long `var', i(eid) j(meas)
     icc `var' eid meas, mixed absolute

     local `var'_n=r(N_target)
     local `var'_icc=r(icc_i)
     local `var'_lamda_p=1/``var'_icc'
     local `var'_var_lamda_p=(``var'_lamda_p'^2-1)^2/``var'_n'
     local `var'_var_inv_lamda_p=``var'_var_lamda_p'/(``var'_lamda_p'^4)

     mixed `var' meas || eid:
}

foreach var in crp bvitd rdw {
   use modelfile_all, clear
   drop if `var'0==. | sex==. | ethnic2==. | smoking0==. | drink==. | deprive==. | age==. | bmi0==.

   *check number of years follow up and set survival parameters in years
     gen years=time/365.25
     stset years, failure(mort_all)

   sum years
   local `var'_N1=r(N)
   local `var'_sum_years=r(sum)
   quietly sum mort_all
   local `var'_sum_mort=r(sum)
   local `var'_yearspp=``var'_sum_years'/``var'_N1'

   di "`var'"
   di "Number of years per person: ``var'_yearspp'"
   di "Number of deaths: ``var'_sum_mort'"
   di "All-cause mortality rate"
   cii means ``var'_sum_years' ``var'_sum_mort', poisson
}


  use modelfile_all, clear
  *keep complete data for confounders only (do not worry about exposure)
    drop if sex==. | ethnic2==. | smoking0==. | drink==. | deprive==. | age==. | bmi0==.

*predictions for regression calibration
foreach var in crp bvitd rdw {

  *outcomes with confounders
     regress `var'1 `var'0 deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
     predict `var'_hat, xb

  *confounders for each outcome
  *BMI with other confounders and exposure
     regress bmi1 bmi0 `var'0 deprive age i.sex i.ethnic2 smoking0 i.drink
     predict `var'_bmi_hat, xb

  *smoke pack with other confounders and exposure
     regress smokpack1 smokpack0 `var'0 deprive age i.sex i.ethnic2 bmi0 i.drink
     predict `var'_smokpack_hat, xb

     gen `var'_smoking_hat=`var'_smokpack_hat
     replace `var'_smoking_hat = . if smokever0==. & `var'_smokpack_hat==.
     replace `var'_smoking_hat = 0 if smokever0==0 & `var'_smokpack_hat==.
     replace `var'_smoking_hat = . if smokever0==1 &smokagestop0<=0 & `var'_smokpack_hat==.
     replace `var'_smoking_hat = 0 if smokever0==1 &smokagestop0>0 &smokagestop0<=16 & `var'_smokpack_hat==.
     replace `var'_smoking_hat = . if smokever0==1 &smokagestop0>16 &smokagestop0<. & `var'_smokpack_hat==.
     replace `var'_smoking_hat = . if smokever0==1 &smokagestop0==. & `var'_smokpack_hat==.
     sum `var'_smoking_hat
}

*output file
   postfile results str12 name1 value1 using observed_results.dta, replace

*reset survival parameters
   stset time, failure(mort_all)

*run cox models
foreach var in crp bvitd rdw {
   
  *Model 1 - uncorrected
     stcox `var'0 deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink, nohr
     matrix define H=r(table)

     di "`var' uncorrected"
  *get coefficients and ci (need to transform back to hazard)
     local b_`var' = el(H,1,1)
     local hr_`var' = exp(`b_`var'')
     local var_b_`var' = el(H,2,1)^2
     local cill_`var' = el(H,5,1)
     local hr_cill_`var' = exp(`cill_`var'')
     local ciul_`var' = el(H,6,1)
     local hr_ciul_`var' = exp(`ciul_`var'')
     local f0_`var' = `b_`var''^2 - (1.96^2*`var_b_`var'')

     di "`var' icc"
   *adjusted by icc correction factor
     local b_p_`var' = `b_`var''*``var'_lamda_p'
     local hr_p_`var' = exp(`b_p_`var'')
     local f1_p_`var' = `b_`var''/``var'_lamda_p'
     local f2_p_`var' = (1/``var'_lamda_p'^2)-(1.96^2*``var'_var_inv_lamda_p')
     local cill_p_`var' = (`f1_p_`var'' - sqrt(`f1_p_`var''^2-`f0_`var''*`f2_p_`var''))/`f2_p_`var''
     local hr_cill_p_`var' = exp(`cill_p_`var'')
     local ciul_p_`var' = (`f1_p_`var'' + sqrt(`f1_p_`var''^2-`f0_`var''*`f2_p_`var''))/`f2_p_`var''
     local hr_ciul_p_`var' = exp(`ciul_p_`var'')

     di "`var' rc exposure"

   *Model 2 - regression calibrated model with correction for exposure
     stcox `var'_hat deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
     matrix define H=r(table)

   *get coefficients (already hazards)
     local e_hr_`var' = el(H,1,1)
     local e_hr_cill_`var' = el(H,5,1)
     local e_hr_ciul_`var' = el(H,6,1)
     post results ("corre_`var'") (`e_hr_`var'')

     di "`var' rc exposure and confounders"

   *Model 3 - regression calibrated model with correction for crp and smoking and bmi
     stcox `var'_hat deprive age i.sex i.ethnic2 `var'_bmi_hat `var'_smoking_hat i.drink
     matrix define H=r(table)

   *get coefficients (already hazards)
     local ec_hr_`var' = el(H,1,1)
     local ec_hr_cill_`var' = el(H,5,1)
     local ec_hr_ciul_`var' = el(H,6,1)
     post results ("correc_`var'") (`ec_hr_`var'')
}

postclose results

*display results
foreach var in crp bvitd rdw {
   di "`var'"
   di "n = ``var'_n'"
   di "ICC = ``var'_icc'" 
   di "correction factor lamda using ICC = ``var'_lamda_p'" 
   di "variance of lamda_p = ``var'_var_lamda_p'"
   di "variance of 1/lamda_p = ``var'_var_inv_lamda_p'"

   di "b=`b_`var''"
   di "var b=`var_b_`var''"
   di "f0=`f0_`var''"
   di "f1 icc=`f1_p_`var''" 
   di "f2 icc=`f2_p_`var''"
   di "Uncorrected `var' HR: `hr_`var'' (`hr_cill_`var'',`hr_ciul_`var'')
   di "Corrected `var' HR using ICC: `hr_p_`var'' (`hr_cill_p_`var'',`hr_ciul_p_`var'')
   di "Exposure RC `var' HR: `e_hr_`var'' (`e_hr_cill_`var'',`e_hr_ciul_`var'')
   di "Exp+Conf RC `var' HR: `ec_hr_`var'' (`ec_hr_cill_`var'',`ec_hr_ciul_`var'')
   }
 
   use observed_results.dta, clear
   mkmat value1, matrix(observed) rownames(name1)
   matlist observed
     
*use boostrap replicates for regression calibration CIs
   clear
   append using boots_1 boots_2 boots_3 boots_4 boots_5 boots_6 boots_7 boots_8 boots_9 boots_10 
   save boots10000.dta, replace

   bstat corre_crp correc_crp corre_bvitd correc_bvitd corre_rdw correc_rdw, stat(observed') n(`crp_N1')
   bstat corre_crp correc_crp corre_bvitd correc_bvitd corre_rdw correc_rdw, stat(observed') n(`bvitd_N1')
   bstat corre_crp correc_crp corre_bvitd correc_bvitd corre_rdw correc_rdw, stat(observed') n(`rdw_N1')



  
