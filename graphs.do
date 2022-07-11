/* graphs.do - Creates graphs for paper */
/* Requires - concordance_output.xlsx (preferably updated with new short names) */
/* Main output - various graph files */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

ssc install metan
ssc install labutil

*read in results from spreadsheet (that has been manually updated for better shortnames)
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

 sum icc, detail
 sum rho_c, detail
 sum lamda_p, detail

 list fieldid field if icc<0
 list fieldid field if icc>0.99

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

 rename corr pearson
 save concordance_output_all, replace

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
   graph export "$RESULTS/`hc2'.pdf", replace  
 }

*combine into panel
 foreach i in "Anthropometry" "Diet by 24hr recall" "Heart MRI" { 

     use concordance_output_all, clear
     tab highcat

     keep if highcat=="`i'"
     local hc2=subinstr(subinstr("`i'","-","",.)," ","",.)+"2"
     gen labellen=length(short_name)
     tab labellen supercat if supercat==1 | supercat==6 | supercat==11
     list fieldid highcat labellen short_name if labellen>28 & (supercat==1 | supercat==6 | supercat==11), clean
     gen short_name2=substr(short_name,1,28)
     replace short_name2="12685 Tot periph resist PWA" if fieldid==12685 
     replace short_name2="12675 Diast brachial BP PWA" if fieldid==12675 
     replace short_name2="12683 End systol pressur PWA" if fieldid==12683 
     replace short_name2="112684 End sys press ind PWA" if fieldid==12684 
     replace short_name2="12687 Mean arterial pres PWA" if fieldid==12687 
     replace short_name2="12676 Periph pulse pres PWA" if fieldid==12676 
     replace short_name2="12702 Cardiac index PWA" if fieldid==12702 
     replace short_name2="12678 Central pulse pres PWA" if fieldid==12678 
     replace short_name2="12682 Cardiac output PWA" if fieldid==12682 
     replace short_name2="12674 Systol brachial BP PWA" if fieldid==12674 
     replace short_name2="12677 Central systol BP PWA" if fieldid==12677 
     replace short_name2="12686 Stroke volume PWA" if fieldid==12686 
     replace short_name2="12680 Central aug pres PWA" if fieldid==12680 
     replace short_name2="12681 Aug index for PWA" if fieldid==12681 
     replace short_name2="22421 LV end diastol volume" if fieldid==22421 
     replace short_name2="12679 Beats waveform ave PWA" if fieldid==12679 
     replace short_name2="23108 Impedance of leg (L)" if fieldid==23108
     replace short_name2="23109 Impedance of arm (R)" if fieldid==23109
     replace short_name2="23107 Impedance of leg (R)" if fieldid==23107
     replace short_name2="23110 Impedance of arm (L)" if fieldid==23110
     replace short_name2="23106 Impedance whole body" if fieldid==23106
     replace short_name2="23119 Arm fat percentage (R)" if fieldid==23119
     replace short_name2="23123 Arm fat percentage (L)" if fieldid==23123
     replace short_name2="23113 Leg fat-free mass (R)" if fieldid==23113
     replace short_name2="23111 Leg fat percentage (R)" if fieldid==23111
     replace short_name2="23114 Leg predicted mass (R)" if fieldid==23114
     replace short_name2="23117 Leg fat-free mass (L)" if fieldid==23117
     replace short_name2="23118 Leg predicted mass (L)" if fieldid==23118
     replace short_name2="23125 Arm fat-free mass (L)" if fieldid==23125
     replace short_name2="23115 Leg fat percentage (L)" if fieldid==23115
     replace short_name2="23126 Arm predicted mass (L)" if fieldid==23126
     replace short_name2="23121 Arm fat-free mass (R)" if fieldid==23121
     replace short_name2="23122 Arm predicted mass (R)" if fieldid==23122
     replace short_name2="23101 Wholebody fatfree mass" if fieldid==23101
 
     local num=_N
     gen fnum = _n
     labmask fnum, values(short_name2)
     gen temp_num=fnum-0.4

     twoway (rspike icc_cill icc_ciul fnum, horizontal clw(vvthin) clc(blue)) ///
       (scatter fnum icc, ms(o) msize(vsmall) mcol(red)) ///
       (scatter fnum c_b if meandiff<0, ms(t) msangle(180) msize(tiny) mcol(orange)) ///
       (scatter fnum c_b if meandiff>=0, ms(t) msize(tiny) mcol(orange)), ///
	   title("`i'", size(small)) ///
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
     graph display, ysize(20) xsize(6)
     graph save `hc2', replace
   }

   grc1leg Anthropometry2.gph Dietby24hrrecall2.gph HeartMRI2.gph, cols(3) xcommon imargin(0) ysize(20) xsize(20) ///
	  plotregion(color(white)) graphregion(color(white))

   graph save "Figure 4 Panel", replace
   graph export "Figure 4 Panel.pdf", replace

*Box and whisker plots for ICC and accuracy coefficient
   use concordance_output_all, clear

   graph box icc, over(supercat, label(angle(v) labsize(small))) ///
	  plotregion(color(white)) graphregion(color(white)) ///
	  ylab(-0.2(0.2)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	  ytitle("Intraclass correlation coefficient", size(small)) ///
	  yline(0) box(1, color(black)) marker(1, mcolor(black))

   graph save "Figure 2 Box ICC", replace
   graph export "Figure 2 ICC Box plot.pdf", replace

   graph box c_b if c_b>0.4, over(supercat, label(angle(v) labsize(small))) ///
	  plotregion(color(white)) graphregion(color(white)) ///
	  ylab(0.5(0.1)1, format(%2.1f) labsize(vsmall) angle(horiz)) ///
	  ytitle("Accuracy coefficient", size(small)) ///
	  yline(0) box(1, color(black)) marker(1, mcolor(black))

   graph save "Figure 3 Box C_b", replace
   graph export "Figure 3 Accuracy Box plot.pdf", replace



