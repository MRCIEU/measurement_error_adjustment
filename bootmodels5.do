/* needs modelfile_comp.dta from modelexcl.do which contains complete data for those variables */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*bootstrapping for regression calibration CIs
capture program drop mybootbris5
program define mybootbris5, rclass

  use modelfile_comp.dta, clear

  bsample 

  *predictions for regression calibration

  *CRP with confounders
  quietly regress crp1 crp0 deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
  predict crp_hat, xb

  *BMI with other confounders
  quietly regress bmi1 bmi0 deprive age i.sex i.ethnic2 smoking0 i.drink
  predict bmi_hat, xb

  *smoke pack with other confounders
  quietly regress smokpack1 smokpack0 deprive age i.sex i.ethnic2 bmi0 i.drink
  predict smokpack_hat, xb

  gen smoking_hat=smokpack_hat
  replace smoking_hat = . if smokever0==. & smokpack_hat==.
  replace smoking_hat = 0 if smokever0==0 & smokpack_hat==.
  replace smoking_hat = . if smokever0==1 &smokagestop0<=0 & smokpack_hat==.
  replace smoking_hat = 0 if smokever0==1 &smokagestop0>0 &smokagestop0<=16 & smokpack_hat==.
  replace smoking_hat = . if smokever0==1 &smokagestop0>16 &smokagestop0<. & smokpack_hat==.
  replace smoking_hat = . if smokever0==1 &smokagestop0==. & smokpack_hat==.
  sum smoking_hat

  foreach mort in all cvd cancer {

    *set survival parameters
    stset time, failure(mort_`mort')

    *Model 2 - regression calibrated model with correction for exposure
    quietly stcox crp_hat deprive age i.sex i.ethnic2 bmi0 smoking0 i.drink
    matrix define A=r(table)
    return scalar corre_`mort' = el(A,1,1)
 
    *Model 3 - regression calibrated model with correction for crp and smoking and bmi
    quietly stcox crp_hat deprive age i.sex i.ethnic2 bmi_hat smoking_hat i.drink
    matrix define B=r(table)
    return scalar correc_`mort' = el(B,1,1)

  }

end

simulate corre_all=r(corre_all) correc_all=r(correc_all) ///
	corre_cvd=r(corre_cvd) correc_cvd=r(correc_cvd) ///
	corre_cancer=r(corre_cancer) correc_cancer=r(correc_cancer) ///
	, reps(1000) nodots seed(32454) saving(boots_5a.dta, replace) : mybootbris5

simulate corre_all=r(corre_all) correc_all=r(correc_all) ///
        corre_cvd=r(corre_cvd) correc_cvd=r(correc_cvd) ///
        corre_cancer=r(corre_cancer) correc_cancer=r(correc_cancer) ///
        , reps(1000) nodots seed(87436) saving(boots_5b.dta, replace) : mybootbris5

di "done"




