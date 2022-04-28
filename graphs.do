global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

ssc install metan
ssc install labutil

 /*
use concordance_output01.dta, clear
gen type="Baseline"
replace type="Online" if online==1
drop online
append using concordance_output23.dta
replace type="Imaging" if type==""
   */

*read in from spreadsheet instead for better shortnames
import excel fieldid field short_name category highcat instances numdiff ///
             mth_diff_median mth_diff_iqr mean0 mean1 meandiff sddiff rho_c ///
			 ccc_asym_ci corr c_b icc icc_ci lamda_p var_lamda_p ///
			 var_inv_lamda_p icc_cill icc_ciul asym_ll asym_ul ///
   using "$RESULTS/concordance_output.xlsx", ///
   clear cellrange(A2) sheet("Baseline visit")
*get rid of blank rows
drop if fieldid==.
gen type="Baseline"
save concordance_output_baseline.dta, replace

*read in from spreadsheet instead for better shortnames
import excel fieldid field short_name category highcat instances numdiff ///
             mth_diff_median mth_diff_iqr mean0 mean1 meandiff sddiff rho_c ///
			 ccc_asym_ci corr c_b icc icc_ci lamda_p var_lamda_p ///
			 var_inv_lamda_p icc_cill icc_ciul asym_ll asym_ul ///
   using "$RESULTS/concordance_output.xlsx", ///
   clear cellrange(A2) sheet("Online surveys")
*get rid of blank rows
drop if fieldid==.
gen type="Online"
save concordance_output_online.dta, replace

*read in from spreadsheet instead for better shortnames
import excel fieldid field short_name category highcat instances numdiff ///
             mth_diff_median mth_diff_iqr mean0 mean1 meandiff sddiff rho_c ///
			 ccc_asym_ci corr c_b icc icc_ci lamda_p var_lamda_p ///
			 var_inv_lamda_p icc_cill icc_ciul asym_ll asym_ul ///
   using "$RESULTS/concordance_output.xlsx", ///
   clear cellrange(A2) sheet("Imaging visit")
*get rid of blank rows
drop if fieldid==.
gen type="Imaging"
save concordance_output_imaging.dta, replace

clear
append using concordance_output_baseline concordance_output_online concordance_output_imaging

tab type, missing

hist rho_c

*group the concordance into bands
gen conctyp=1
replace conctyp=2 if rho_c >= 0.9 & rho_c < 0.95 
replace conctyp=3 if rho_c >= 0.95 & rho_c <= 0.99 
replace conctyp=4 if rho_c > 0.99 
tab conctyp

label define conctyp 1 "Poor (<0.9)" 2 "Moderate (0.9-0.949)" ///
      3 "Substantial (0.95-0.99)" 4 "Perfect (>0.99)", replace
label values conctyp conctyp
tab conctyp

sum icc, detail
sum rho_c, detail
sum lamda_p, detail

list fieldid field if rho_c<0
list fieldid field if rho_c>0.99

*check confidence intervals within 0-1 for CCC and ICC
replace asym_ll=0 if asym_ll<0
replace asym_ul=0 if asym_ul>1
replace icc_cill=0 if icc_cill<0
replace icc_ciul=0 if icc_ciul>1

tab highcat

*Create text supercategories
gen supercat=99 if highcat=="Other"
replace supercat=1 if highcat=="Anthropometry"
replace supercat=2 if highcat=="Eye measures"
replace supercat=3 if highcat=="Physical measures"
replace supercat=4 if highcat=="Biomarkers"
replace supercat=5 if highcat=="Infectious disease antigens"
replace supercat=6 if highcat=="Diet by 24hr recall"
replace supercat=7 if highcat=="Medical history"
replace supercat=8 if highcat=="Lifestyle"
replace supercat=9 if highcat=="Metabolomics"
replace supercat=10 if highcat=="DXA scan"
replace supercat=11 if highcat=="Heart MRI"
replace supercat=12 if highcat=="Brain MRI"
tab supercat, missing
label define categories 1 "Anthropometry" 2 "Eye measures" 3 "Physical measures" ///
   4 "Biomarkers" 5 "Infectious disease antigens" 6 "Diet by 24hr recall" 7 "Medical history" ///
   8 "Lifestyle" 9 "Metabolomics" 10 "DXA scan" 11 "Heart MRI" 12 "Brain MRI" 99 "Other", replace
label values supercat categories
tab supercat, missing

tab highcat conctyp
sort rho_c

rename corr pearson
save concordance_output_all, replace

*Summary graphs

*Baseline and online graphs
use concordance_output_all, clear
keep if type=="Baseline" | type=="Online"
*randomise the order for the graphs
gen randnum= uniform()
gsort + supercat + randnum
gen num=_n

* manhattan plot of icc - baseline
twoway (scatter icc /*rho_c*/ num if supercat==1, ms(o) msize(vsmall) mcol(red) ///
       /*yline(0.9, lpattern(longdash) lwidth(thin) lcolor(gs5))*/ ///
       /*yline(0.95, lpattern(dash) lwidth(thin) lcolor(gs5))*/ ///
	   /*yline(0.99, lpattern(shortdash) lwidth(thin) lcolor(gs5))*/) ///   
       (scatter icc num if supercat==2, ms(o) msize(vsmall) mcol(cyan)) ///
       (scatter icc num if supercat==3, ms(o) msize(vsmall) mcol(orange)) ///
	   (scatter icc num if supercat==4, ms(o) msize(vsmall) mcol(lime)) ///
       (scatter icc num if supercat==5, ms(o) msize(vsmall) mcol(magenta)) ///
       (scatter icc num if supercat==6, ms(o) msize(vsmall) mcol(green)) ///
       (scatter icc num if supercat==7, ms(o) msize(vsmall) mcol(gold)) ///
       (scatter icc num if supercat==8, ms(o) msize(vsmall) mcol(blue)) ///
       (scatter icc num if supercat==9, ms(o) msize(vsmall) mcol(pink)) ///
       (scatter icc num if supercat==99, ms(o) msize(vsmall) mcol(black)), ///
	   ylab(-0.2(0.1)1 /*0.9 "Moderate > 0.9" 0.95 "Substantial > 0.95"*/ ///
	   /*0.99 "Perfect > 0.99      "*/, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(none) ///
	   legend(title("Category", size(small)) span order(1 2 3 4 5 6 7 8 9 10) size(2) cols(5) region(lcolor(white)) ///
	   label(1 "Anthropometry") label(2 "Eye measures") label(3 "Physical measures") label(4 "Biomarkers") ///
       label(5 "Infectious disease antigens") label(6 "Diet by 24hr recall") label(7 "Medical History") ///
	   label(8 "Lifestyle") label(9 "Metabolomics") label(10 "Other")) ///
	   ytitle(/*"Lin's CCC"*/"Intraclass Correlation Coefficient", margin(vsmall)) ///
       xtitle("Variables (randomly within category)", size(small)) plotregion(color(white)) graphregion(color(white)) ///
       name(manhat, replace)	

	/* xlab(20 "Anthropometry" 65 "Eye measures" 107 "Physical measures" ///
	   153 "Biomarkers" 195 "Infectious disease antigens" 227 "Diet by 24hr recall" ///
	   251 "Medical history" 274 "Lifestyle" 400 "Metabolomics" ///
	   535 "Other", angle(45) labsize(vsmall) noticks) /// */

	   
graph save "$RESULTS/Manhattan ICC Summary", replace
graph export "$RESULTS/Manhattan ICC Summary.tif", width(5000) replace
drop num

* scatter plot of pearson by bias correction
list fieldid field if c_b<=0.5

twoway (scatter c_b pearson if highcat=="Anthropometry" & c_b>0.5, ms(o) msize(vsmall) mcol(red)) ///  
       (scatter c_b pearson if highcat=="Eye measures" & c_b>0.5, ms(D) msize(vsmall) mcol(cyan)) ///
       (scatter c_b pearson if highcat=="Physical Measures" & c_b>0.5, ms(T) msize(vsmall) mcol(orange)) ///
	   (scatter c_b pearson if highcat=="Biomarkers" & c_b>0.5, ms(S) msize(vsmall) mcol(lime)) ///
       (scatter c_b pearson if highcat=="Infectious disease antigens" & c_b>0.5, ms(+) msize(vsmall) mcol(magenta)) ///
       (scatter c_b pearson if highcat=="Diet by 24hr recall" & c_b>0.5, ms(X) msize(vsmall) mcol(green)) ///
       (scatter c_b pearson if highcat=="Medical history" & c_b>0.5, ms(A) msize(vsmall) mcol(gold)) ///
       (scatter c_b pearson if highcat=="Lifestyle" & c_b>0.5, ms(|) msize(vsmall) mcol(blue)) ///
       (scatter c_b pearson if highcat=="Metabolomics" & c_b>0.5, ms(V) msize(vsmall) mcol(pink))  ///
       (scatter c_b pearson if highcat=="Other" & c_b>0.5, ms(a) msize(vsmall) mcol(black)), ///
	   legend(order(1 2 3 4 5 6 7 8 9 10) span title("Category", size(small)) size(2) cols(5) region(lcolor(white)) ///
	   label(1 "Anthropometry") label(2 "Eye measures") label(3 "Physical measures") label(4 "Biomarkers") ///
       label(5 "Infectious disease antigens") label(6 "Diet by 24hr recall") label(7 "Medical history") ///
       label(8 "Lifestyle") label(9 "Metabolomics") label(10 "Other")) ///
	   ylab(0.5(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(0(0.1)1, format(%2.1f) labsize(vsmall)) ///
	   ytitle("Accuracy Coefficient") aspectratio(1) ///
       xtitle("Pearson's Correlation Coefficient") plotregion(color(white) margin(0)) graphregion(color(white)) ///
       name(scatsum, replace)
	   	   
graph save "$RESULTS/Scatter rho c_b summary", replace
graph export "$RESULTS/Scatter rho c_b summary.tif", width(5000) replace

  /*
* scatter plot of CCC by ICC by category
twoway (scatter rho_c icc if highcat=="Anthropometry", ms(o) msize(vsmall) mcol(red)) ///  
       (scatter rho_c icc if highcat=="Eye measures", ms(D) msize(vsmall) mcol(cyan)) ///
       (scatter rho_c icc if highcat=="Physical Measures", ms(T) msize(vsmall) mcol(orange)) ///
	   (scatter rho_c icc if highcat=="Biomarkers", ms(S) msize(vsmall) mcol(lime)) ///
       (scatter rho_c icc if highcat=="Infectious disease antigens", ms(+) msize(vsmall) mcol(magenta)) ///
       (scatter rho_c icc if highcat=="Diet by 24hr recall", ms(X) msize(vsmall) mcol(green)) ///
       (scatter rho_c icc if highcat=="Medical history", ms(A) msize(vsmall) mcol(gold)) ///
       (scatter rho_c icc if highcat=="Lifestyle", ms(|) msize(vsmall) mcol(blue)) ///
       (scatter rho_c icc if highcat=="Metabolomics", ms(V) msize(vsmall) mcol(pink))  ///
       (scatter rho_c icc if highcat=="Other", ms(a) msize(vsmall) mcol(black)), ///
	   legend(order(1 2 3 4 5 6 7 8 9 10) span title("Category", size(small)) size(2) cols(5) region(lcolor(white)) ///
	   label(1 "Anthropometry") label(2 "Eye measures") label(3 "Physical measures") label(4 "Biomarkers") ///
       label(5 "Infectious disease antigens") label(6 "Diet by 24hr recall") label(7 "Medical history") ///
       label(8 "Lifestyle") label(9 "Metabolomics") label(10 "Other")) ///
	   ylab(0(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(-0.2(0.1)1, format(%2.1f) labsize(vsmall)) ///
	   ytitle("Concordance Correlation Coefficient") aspectratio(1) ///
       xtitle("Intraclass Correlation Coefficient") plotregion(color(white) margin(0)) graphregion(color(white)) ///
       name(cccicc, replace)
	   	   
graph save "$RESULTS/Scatter ccc icc summary", replace
graph export "$RESULTS/Scatter ccc icc summary.tif", width(5000) replace
  */
* scatter plot of CCC by ICC all together
twoway (scatter rho_c icc, msize(vsmall) mcol(blue)), ///  
	   ylab(0(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) xline(0, lcolor(black)) ///
	   xlab(-0.2(0.1)1, format(%2.1f) labsize(vsmall)) ///
	   ytitle("Concordance Correlation Coefficient") aspectratio(1) ///
       xtitle("Intraclass Correlation Coefficient") plotregion(color(white) margin(0)) graphregion(color(white)) ///
       name(cccicc, replace)
	   
graph save "$RESULTS/Scatter ccc icc summary", replace
graph export "$RESULTS/Scatter ccc icc summary.tif", width(5000) replace

*Imaging graphs
use concordance_output_all, clear
keep if type=="Imaging"
*randomise the order for the graphs
gen randnum= uniform()
gsort + supercat + randnum
gen num=_n

* manhattan plot of icc - imaging
twoway (scatter icc num if supercat==1, ms(o) msize(vsmall) mcol(red) ///
       /*yline(0.9, lpattern(longdash) lwidth(thin) lcolor(gs5))*/ ///
       /*yline(0.95, lpattern(dash) lwidth(thin) lcolor(gs5))*/ ///
	   /*yline(0.99, lpattern(shortdash) lwidth(thin) lcolor(gs5))*/) ///   
       (scatter icc num if supercat==3, ms(o) msize(vsmall) mcol(cyan)) ///
       (scatter icc num if supercat==10, ms(o) msize(vsmall) mcol(orange)) ///
	   (scatter icc num if supercat==11, ms(o) msize(vsmall) mcol(lime)) ///
       (scatter icc num if supercat==12, ms(o) msize(vsmall) mcol(magenta)) ///
       (scatter icc num if supercat==99, ms(o) msize(vsmall) mcol(black)), ///
	   ylab(0(0.1)1 /*0.9 "Moderate > 0.9" 0.95 "Substantial > 0.95"*/ ///
	   /*0.99 "Perfect > 0.99      "*/, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(none) ///
	   legend(order(1 2 3 4 5 6) title("Category", size(small)) span size(2) cols(6) region(lcolor(white)) ///
	   label(1 "Anthropometry") label(2 "Physical measures") label(3 "DXA scan") ///
       label(4 "Heart MRI") label(5 "Brain MRI") label(6 "Other")) ///
	   ytitle(/*"Lin's CCC"*/"Intraclass Correlation Coefficient", margin(vsmall)) ///
       xtitle("Variables (randomly within category)", size(small)) plotregion(color(white)) graphregion(color(white)) ///
       name(manhat_i, replace)	
	   
graph save "$RESULTS/Manhattan ICC Summary i", replace
graph export "$RESULTS/Manhattan ICC Summary i.tif", width(5000) replace
drop num

tab supercat

* scatter plot of pearson by bias correction
list fieldid field c_b if c_b<=0.5
* scatter plot of pearson by bias correction
twoway (scatter c_b pearson if highcat=="Brain MRI", ms(V) msize(vsmall) mcol(magenta))  ///
	   (scatter c_b pearson if highcat=="Anthropometry", ms(o) msize(vsmall) mcol(red)) ///  
       (scatter c_b pearson if highcat=="Physical Measures", ms(T) msize(vsmall) mcol(cyan)) ///
       (scatter c_b pearson if highcat=="DXA scan", ms(X) msize(vsmall) mcol(orange))  ///
       (scatter c_b pearson if highcat=="Heart MRI" & c_b>0.5, ms(A) msize(vsmall) mcol(lime))  ///
       (scatter c_b pearson if highcat=="Other", ms(+) msize(vsmall) mcol(black)), ///
	   legend(order(2 3 4 5 1 6) title("Category", size(vsmall)) span size(2) cols(3) region(lcolor(white)) ///
	   label(1 "Brain MRI") label(2 "Anthropometry") label(3 "Physical measures") ///
	   label(4 "DXA scan") label(5 "Heart MRI")  label(6 "Other")) ///
	   ylab(0.5(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(0(0.1)1, format(%2.1f) labsize(vsmall)) ///
	   ytitle("Accuracy Coefficient") aspectratio(1) ///
       xtitle("Pearson's Correlation") plotregion(color(white) margin(0)) graphregion(color(white)) ///
       name(scatsum_i, replace)
	   	   
graph save "$RESULTS/Scatter rho c_b summary i", replace
graph export "$RESULTS/Scatter rho c_b summary i.tif", width(5000) replace

 /*
* scatter plot of CCC by ICC by category
twoway (scatter rho_c icc if highcat=="Brain MRI", ms(V) msize(vsmall) mcol(magenta)) ///  
	   (scatter rho_c icc if highcat=="Anthropometry", ms(o) msize(vsmall) mcol(red)) /// 
       (scatter rho_c icc if highcat=="Physical Measures", ms(T) msize(vsmall) mcol(cyan)) ///
       (scatter rho_c icc if highcat=="DXA scan", ms(X) msize(vsmall) mcol(orange)) ///
       (scatter rho_c icc if highcat=="Heart MRI", ms(A) msize(vsmall) mcol(lime)) ///
       (scatter rho_c icc if highcat=="Other", ms(+) msize(vsmall) mcol(black)), ///
	   legend(order(2 3 4 5 1 6) span title("Category", size(vsmall)) size(2) cols(3) region(lcolor(white)) ///
	   label(1 "Brain MRI") label(2 "Anthropometry") label(3 "Physical measures") ///
	   label(4 "DXA scan") label(5 "Heart MRI")  label(6 "Other")) ///
	   ylab(0(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(0(0.1)1, format(%2.1f) labsize(vsmall)) ///
	   ytitle("CCC") aspectratio(1) ///
       xtitle("ICC") plotregion(color(white) margin(0)) graphregion(color(white)) ///
       name(cccicc_i, replace)
	   	   
graph save "$RESULTS/Scatter ccc icc summary i", replace
graph export "$RESULTS/Scatter ccc icc summary i.tif", width(5000) replace
  */
* scatter plot of CCC by ICC all together
twoway (scatter rho_c icc, msize(vsmall) mcol(green)), ///  
	   ylab(0(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	   xlab(-0.2(0.1)1, format(%2.1f) labsize(vsmall)) ///
	   ytitle("Concordance Correlation Coefficient") aspectratio(1) ///
       xtitle("Intraclass Correlation Coefficient") plotregion(color(white) margin(0)) graphregion(color(white)) ///
       name(cccicc_i, replace)

graph save "$RESULTS/Scatter ccc icc summary i", replace
graph export "$RESULTS/Scatter ccc icc summary i.tif", width(5000) replace

*Category graphs for all
foreach i in "Anthropometry" "Eye measures" "Physical measures" "Biomarkers" ///
    "Infectious disease antigens" "Diet by 24hr recall" "Medical history" ///
	"Lifestyle" "Metabolomics" "DXA scan" "Heart MRI" "Brain MRI" "Other" { 

use concordance_output_all, clear
tab highcat

keep if highcat=="`i'"
local hc2=subinstr(subinstr("`i'","-","",.)," ","",.)
	
local num=_N
gen fnum = _n
labmask fnum, values(short_name)
gen temp_num=fnum-0.4

local ysize=min(int(6+`num'/3.5),20)
disp "ysize is `ysize'"

twoway (rspike icc_cill icc_ciul fnum, horizontal clw(vvthin) clc(blue)) ///
       (scatter fnum icc, ms(o) msize(vsmall) mcol(red)) ///
       (scatter fnum c_b if meandiff<0, ms(t) msangle(180) msize(tiny) mcol(orange)) ///
       (scatter fnum c_b if meandiff>=0, ms(t) msize(tiny) mcol(orange)), ///
	   legend(order (- 2 1 - "Accuracy coefficient:" 3 4) size(1.5) cols(2) span colfirst textfirst ///
	   label(1 "95% Confidence Interval") ///
	   label(2 "Intraclass Correlation Coefficient") ///
	   label(3 "mean of repeat < baseline") ///
	   label(4 "mean of repeat > baseline")) ///
	   ytitle("  ") ///
	   ylabel(1(1)`num', valuelabel labsize(tiny) angle(horiz)) ///
       xtitle("   ") plotregion(color(white)) graphregion(color(white)) ///
	   xlabel(0(0.1)1, format(%2.1f) labsize(tiny)) ///
       name(`hc2', replace)	      

graph display, ysize(`ysize') xsize(16)
graph save "$RESULTS/`hc2'", replace
graph export "$RESULTS/`hc2'.tif", width(5000) replace  

}
