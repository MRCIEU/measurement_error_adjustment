
global RESULTS "~/meas_error/results"
global DATA "~/meas_error/data"

cd $RESULTS
   
ssc install concord

use check20.dta, clear

quietly ds
local fidlist=r(varlist)
local numvars=wordcount("`fidlist'")
di "`numvars'"

*put output to file
postfile results fieldid n rho_c se_rho_c asym_ll asym_ul z_tr_ll z_tr_ul c_b diff sd_diff loa_ll loa_ul rdm fdm using concordance_output.dta, replace

*run for each variable in both instances
forvalues pos = 2(2)`numvars' {
   local fieldname0 = word("`fidlist'",`pos')
   local fieldname1 = word("`fidlist'",`pos'+1)
   local fid=subinstr(subinstr("`fieldname0'","v","",2),"_0_0","",1)
   summ `fieldname0' if `fieldname0'<. & `fieldname1'<., meanonly
   local ch0=r(min)
   summ `fieldname1' if `fieldname0'<. & `fieldname1'<., meanonly
   local ch1=r(min)
   if `ch0'<. & `ch1'<. {
      quietly concord `fieldname1' `fieldname0', loa
      local n = r(N)
      local rho_c = r(rho_c)
      local se_rho_c = r(se_rho_c)
      local asym_ll = r(asym_ll)
      local asym_ul = r(asym_ul)
      local z_tr_ll = r(z_tr_ll)
      local z_tr_ul = r(z_tr_ul)
      local c_b = r(C_b)
      local diff = r(diff)
      local sd_diff = r(se_diff)
      local loa_ll = r(LOA_ll)
      local loa_ul = r(LOA_ul)
      local rdm = r(rdm)
      local fdm = r(Fdm)
      graph save BAplot_`fid', replace
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
   }
   post results (`fid') (`n') (`rho_c') (`se_rho_c') (`asym_ll') (`asym_ul') (`z_tr_ll') (`z_tr_ul') (`c_b') (`diff') (`sd_diff') (`loa_ll') (`loa_ul') (`rdm') (`fdm')	
}   
postclose results
             
use concordance_output.dta, clear  

export delimited "$RESULTS/concordance_output.csv", delimiter(",") replace
   
