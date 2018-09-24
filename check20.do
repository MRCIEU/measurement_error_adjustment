/* this do file checks that there are at least 20 distinct values in each field (per instance) and removes those that don't */

global RESULTS "~/meas_error/results"
global DATA "~/meas_error/data"

cd $RESULTS

use $RESULTS/arraysfixed.dta, clear

ds
local fidlist=r(varlist)
local numvars=wordcount("`fidlist'")

local exclcount=0
local exclids=""
local inclids=""

forvalues vnum=2(2)`numvars' {
   local fieldname0=word("`fidlist'",`vnum')
   local fieldname1=word("`fidlist'",`vnum'+1)
   egen tag0=tag(`fieldname0')
   egen tag1=tag(`fieldname1')
   forvalues inst = 0/1 {
      quietly count if tag`inst'==1
      local dcount`inst'=r(N)
   }
   local fnum=subinstr(subinstr("`fieldname0'","v","",2),"_0_0"," ",1)
   if `dcount0'<20 | `dcount1'<20 {
      drop `fieldname0' `fieldname1'
      local exclcount=`exclcount'+1
      local exclids="`exclids'" + "`fnum'" + " "
   }
   else {
      local inclids="`inclids'" + "`fnum'" + " "
   }
   drop tag0 tag1
   macro drop dcount0 dcount1 fnum
}

di "Number of fields dropped due to fewer than 20 distinct values is `exclcount'"
di "The dropped field ids are `exclids'"
di "The remaining field ids are `inclids'" 

save $RESULTS/check20.dta, replace

export delimited $RESULTS/finalfile.txt, delimiter(tab) replace 
export delimited $RESULTS/finalfile.csv, delimiter(",") replace

