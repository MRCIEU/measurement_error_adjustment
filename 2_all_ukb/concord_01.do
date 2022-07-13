/* concord_01.do - Run concordance analysis and get ICC for all records */
/* Requires - finalfile01.dta, used_vars_list01.dta */
/* Main output - concordance_output01.dta, concordance_output.xlsx */ 

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS
   
ssc install concord

 use finalfile01.dta, clear
 ds
 local fidlist=r(varlist)

*count variables
 local numvars=wordcount("`fidlist'")
 di "`numvars'"

*put output to file
 postfile results fieldid numdiff med_assess_tm p25_assess_tm p75_assess_tm med_diet_tm p25_diet_tm p75_diet_tm ///
                 mean0 mean1 meandiff sddiff rho_c asym_ll asym_ul corr c_b /// 
                 icc icc_cill icc_ciul lamda_p var_lamda_p var_inv_lamda_p using concordance_output01.dta, replace

*run for each variable in both instances (excluding eid and dates)
 forvalues pos = 8(2)`numvars' {

   local fieldname0 = word("`fidlist'",`pos')
   local fieldname1 = word("`fidlist'",`pos'+1)
   local fid=substr("`fieldname0'",2,strlen("`fieldname0'")-5)
   di "`pos' of `numvars', variable `fid'"

   use finalfile01.dta, clear

*only keep variable of interest and non-missing observations
   keep eid `fieldname0' `fieldname1' assess_td diet_td
   rename `fieldname0' field0
   rename `fieldname1' field1
   keep if field0<. & field1<.

*get descriptive stats on variable
   forvalues i = 0/1 {
      quietly summ field`i'
      local min`i'=r(min)
      local u`i'=r(mean)
   }

*get date differences in months
   gen assess_tm=assess_td*12/365.25
   quietly summ assess_tm, detail
   local p25_assess_tm=r(p25)
   local med_assess_tm=r(p50)
   local p75_assess_tm=r(p75)
   gen diet_tm=diet_td*12/365.25
   quietly summ diet_tm, detail
   local p25_diet_tm=r(p25)
   local med_diet_tm=r(p50)
   local p75_diet_tm=r(p75)
   drop assess_td diet_td assess_tm diet_tm
    
*get descriptive stats on difference
   gen diff01=field1-field0
   quietly summ diff01
   local n01=r(N)
   local u01=r(mean)
   local sd01=r(sd)
   drop diff01

*get CCC and components
   quietly concord field1 field0
   local n=r(N)
   local rho_c = r(rho_c)
   local asym_ll = r(asym_ll)
   local asym_ul = r(asym_ul)
   local c_b = r(C_b)
   local corr = `rho_c'/`c_b'

*get ICC (two way mixed effects) from as much data as is available but need long format
   quietly reshape long field,  i(eid) j(meas)
   quietly icc field eid meas, mixed absolute
   local icc=r(icc_i)
   local icc_cill=r(icc_i_lb)
   local icc_ciul=r(icc_i_ub)
   local lamda_p=1/`icc'
   local var_lamda_p=(`lamda_p'^2-1)^2/`n'
   local var_inv_lamda_p=`var_lamda_p'/(`lamda_p'^4)

   post results (`fid') (`n01') (`med_assess_tm') (`p25_assess_tm') (`p75_assess_tm') ///
        (`med_diet_tm') (`p25_diet_tm') (`p75_diet_tm') (`u0') (`u1') (`u01') (`sd01') ///
	(`rho_c') (`asym_ll') (`asym_ul') (`corr') (`c_b') ///
	(`icc') (`icc_cill') (`icc_ciul') (`lamda_p') (`var_lamda_p') (`var_inv_lamda_p')
 }   

 postclose results

*get extra information about each variable from original variable list   
 use used_vars_list01.dta, clear
 keep fieldid field category instances online
 order fieldid field category online
 sort fieldid
 merge 1:1 fieldid using concordance_output01.dta, nogen keep(match using)

 gen icc_ci = "(" + string(icc_cill, "%8.2f") + ", " + string(icc_ciul, "%8.2f") + ")"
 gen ccc_asym_ci = "(" + string(asym_ll, "%8.2f") + ", " + string(asym_ul, "%8.2f") + ")"
 gen assess_iqr = "(" + string(p25_assess_tm, "%8.0f") + ", " + string(p75_assess_tm, "%8.0f") + ")"
 gen diet_iqr = "(" + string(p25_diet_tm, "%8.0f") + ", " + string(p75_diet_tm, "%8.0f") + ")"

 drop p25_assess_tm p75_assess_tm p25_diet_tm p75_diet_tm

 gen mth_diff_median=med_assess_tm
 gen mth_diff_iqr=assess_iqr

*change diet fields to use diet dates
 replace mth_diff_median=med_diet_tm if category==100090 | category==100097 | category==100098 | category==100114 ///
                          | (category>=100100 & category<=100112)
 replace mth_diff_iqr=diet_iqr if category==100090 | category==100097 | category==100098 | category==100114 ///
                          | (category>=100100 & category<=100112)
 drop assess_iqr diet_iqr med_assess_tm med_diet_tm

 gen short_name=string(fieldid, "%8.0f") + " " + substr(field, 1,30)

*create high category for graphs
 gen highcat=99 // Other
 replace highcat=1 if category==100010 | category==100009 //Anthropometry
 replace highcat=2 if category==100014 | category==100015 | category==100017 // Eye measures
 replace highcat=3 if category==101 | category==104 | category==100007 | category==100011 | ///
                 category==100018 | category==100012 | category==100019 | ///
                 category==100049 | category==100020 // Physical measures
 replace highcat=4 if category==100081 | category==100083 | category==17518 // Biomarkers
 replace highcat=5 if category==1307 // Infectious Disease Antigens
 replace highcat=6 if category==100098 | category==100114 // Diet by 24hr recall
 replace highcat=7 if category==100041 | category==100044 | category==100074 | category==100069 // Medical history
 replace highcat=8 if category==100052 | category==100054 | ///
         category==100056 | category==100058 | category==100064 | category==100066 // Lifestyle
 replace highcat=9 if category==220 // Metabolomics
 replace highcat=10 if category==124 | category==125 // DXA
 replace highcat=11 if category==128 | category==133 // Heart MRI
 replace highcat=12 if (category>=106 & category<=112) | category==134 | category==135 | ///
         (category>=190 & category<=197) | category==1101 | category==1102 // Brain MRI

 label define categories 1 "Anthropometry" 2 "Eye measures" 3 "Physical measures" ///
      4 "Biomarkers" 5 "Infectious disease antigens" 6 "Diet by 24hr recall" ///
      7 "Medical history" 8 "Lifestyle" 9 "Metabolomics" 10 "DXA scan" ///
      11 "Heart MRI" 12 "Brain MRI" 99 "Other", replace
 label values highcat categories
 tab highcat, missing

 order fieldid field short_name category highcat instances numdiff mth_diff_median mth_diff_iqr ///
       mean0 mean1 meandiff sddiff rho_c ccc_asym_ci corr c_b icc icc_ci ///
       lamda_p var_lamda_p var_inv_lamda_p online icc_cill icc_ciul asym_ll asym_ul

 label variable fieldid "UKB field number"
 label variable field "UKB field name"
 label variable short_name "Short name"
 label variable category "UKB category"
 label variable highcat "High category"
 label variable instances "Number of measurements"
 label variable numdiff "Number in sample"
 label variable mth_diff_median "Median months difference"
 label variable mth_diff_iqr "IQR months difference"
 label variable mean0 "Mean of initial measure"
 label variable mean1 "Mean of repeat measure"
 label variable meandiff "Mean difference"
 label variable sddiff "SD of difference"
 label variable rho_c "CCC"
 label variable ccc_asym_ci "Asymptotic 95% CI of CCC"
 label variable corr "Pearson's correlation"
 label variable c_b "Accuracy coefficient"
 label variable icc "ICC"
 label variable icc_ci "ICC 95% CI"
 label variable lamda_p "Correction factor (lamda)"
 label variable var_lamda_p "Var(lamda)"
 label variable var_inv_lamda_p "Var(1/lamda)"

 save concordance_output01.dta, replace

*output online diet fields to one excel sheet
 keep if online==1
 drop online
 export excel "$RESULTS/concordance_output.xlsx", sheet("Online surveys") firstrow(varlabels) sheetreplace

*output baseline measurements to another excel sheet
 use concordance_output01.dta, clear
 drop if online==1
 drop online
 export excel "$RESULTS/concordance_output.xlsx", sheet("Baseline visit") firstrow(varlabels) sheetreplace

   
