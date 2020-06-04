
global RESULTS "~/meas_error/results"
global DATA "~/meas_error/data"

cd $RESULTS
   
ssc install concord

use check20.dta, clear

ds
local fidlist=r(varlist)
local numvars=wordcount("`fidlist'")-9
di "`numvars'"

*put output to file
postfile results fieldid numdiff mean0 mean1 meandiff sd0 sd1 sddiff n rho_c se_rho_c asym_ll asym_ul z_tr_ll ///
   z_tr_ul c_b diff sd_diff loa_ll loa_ul rdm fdm corr mean_assess_td sd_assess_td p25_assess_td p75_assess_td ///
   mean_sample_td sd_sample_td p25_sample_td p75_sample_td mean_diet_td sd_diet_td p25_diet_td p75_diet_td ///
 using concordance_output.dta, replace

*run for each variable in both instances
forvalues pos = 2(2)`numvars' {
   local fieldname0 = word("`fidlist'",`pos')
   local fieldname1 = word("`fidlist'",`pos'+1)
   local fid=subinstr(subinstr("`fieldname0'","f_","",1),"_0_0","",1)
   forvalues i = 0(1)1 {
      quietly summ `fieldname`i'' if `fieldname0'<. & `fieldname1'<.
      local min`i'=r(min)
      local u`i'=r(mean)
      local sd`i'=r(sd)
      quietly summ assess_td if `fieldname0'<. & `fieldname1'<. , detail
      local mean_assess_td=r(mean)
      local sd_assess_td=r(sd)
      local p25_assess_td=r(p25)
      local p75_assess_td=r(p75)
      quietly summ sample_td if `fieldname0'<. & `fieldname1'<. , detail
      local mean_sample_td=r(mean)
      local sd_sample_td=r(sd)
      local p25_sample_td=r(p25)
      local p75_sample_td=r(p75)
      quietly summ diet_td if `fieldname0'<. & `fieldname1'<. , detail
      local mean_diet_td=r(mean)
      local sd_diet_td=r(sd)
      local p25_diet_td=r(p25)
      local p75_diet_td=r(p75)
   }
   gen diff01=`fieldname1'-`fieldname0'
   quietly summ diff01
   local n01=r(N)
   local u01=r(mean)
   local sd01=r(sd)
   drop diff01
   if `min0'<. & `min1'<. { 
      quietly concord `fieldname1' `fieldname0'
      local n = r(N)
      local rho_c = r(rho_c)
      local se_rho_c = r(se_rho_c)
      local asym_ll = r(asym_ll)
      local asym_ul = r(asym_ul)
      local z_tr_ll = r(z_tr_ll)
      local z_tr_ul = r(z_tr_ul)
      local c_b = r(C_b)
      local diff = r(diff)
      local sd_diff = r(sd_diff)
      local loa_ll = r(LOA_ll)
      local loa_ul = r(LOA_ul)
      local rdm = r(rdm)
      local fdm = r(Fdm)
      local corr = `rho_c'/`c_b'
   }
   else {
   local n=0
   local rho_c=.
   local se_rho_c=.
   local asym_ll=.
   local asym_ul=.
   local z_tr_ll=.
   local z_tr_ul=.
   local c_b=.
   local diff=.
   local sd_diff=.
   local loa_ll=.
   local loa_ul=.
   local rdm=.
   local fdm=.
   local corr=.
   }
   post results (`fid') (`n01') (`u0') (`u1') (`u01') (`sd0') (`sd1') (`sd01') (`n') (`rho_c') (`se_rho_c') (`asym_ll') ///
   (`asym_ul') (`z_tr_ll') (`z_tr_ul') (`c_b') (`diff') (`sd_diff') (`loa_ll') (`loa_ul') (`rdm') (`fdm') (`corr')  ///
   (`mean_assess_td') (`sd_assess_td') (`p25_assess_td') (`p75_assess_td') (`mean_sample_td') (`sd_sample_td') ///
   (`p25_sample_td') (`p75_sample_td') (`mean_diet_td') (`sd_diet_td') (`p25_diet_td') (`p75_diet_td')	
}   
postclose results

use used_vars_list.dta, clear

merge 1:1 fieldid using concordance_output.dta, nogen keep(match using)

save concordance_output.dta, replace

export delimited "$RESULTS/concordance_output.csv", delimiter(",") replace
   
