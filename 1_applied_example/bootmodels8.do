/* bootmodels8 - creates 1st 1,000 bootstrap replicates for the regression calibration */
/* Requires - modelfile_all.dta */
/* Main output - boots_8.dta */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*bootstrapping for regression calibration CIs
capture program drop mybootbris
program define mybootbris, rclass

foreach var in crp bvitd rdw {
  use modelfile_all.dta, clear

  *keep complete data for expoaures and confounders
  drop if `var'0==. | sex==. | ethnic2==. | smoking0==. | drink==. | deprive==. | age==. | bmi0==.

  bsample

  *predictions for regression calibration

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

  *set survival parameters
    stset time, failure(mort_all)

  *Model 2 - regression calibrated model with correction for exposure
    quietly stcox `var'_hat deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
    matrix define A=r(table)
    return scalar corre_`var' = el(A,1,1)
 
  *Model 3 - regression calibrated model with correction for crp and smoking and bmi
    quietly stcox `var'_hat deprive age i.sex i.ethnic2 `var'_bmi_hat `var'_smoking_hat i.drink
    matrix define B=r(table)
    return scalar correc_`var' = el(B,1,1)

}

end

simulate corre_crp=r(corre_crp) correc_crp=r(correc_crp) ///
     corre_bvitd=r(corre_bvitd) correc_bvitd=r(correc_bvitd) ///
     corre_rdw=r(corre_rdw) correc_rdw=r(correc_rdw) ///
     , reps(1000) nodots seed(65433) saving(boots_8.dta, replace) : mybootbris

di "done"




