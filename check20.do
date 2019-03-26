/* this do file amends some of the special coded values then checks and removes 
   a) variables with <20 distinct values per instance (for observations non missing in both instances)
   b) variables with less than 100 observations non missing in both instances
   c) variables with >=20% of non missing observations having one single value (should be categorical) */

/* needs arraysfixed.dta */
/* amended 26032019 - to set -10 to 0.5 */

global RESULTS "~/meas_error/results"
global DATA "~/meas_error/data"

cd $RESULTS

use $RESULTS/arraysfixed.dta, clear

/* amend default values on those that use them */

* -1 only
foreach vnum in 129 130 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=0 if `varname'==-1
   }
}

* -1 and -3 and -10 (less than)
foreach vnum in 699 757 777 796 1050 1060 1289 1299 1309 1319 1438 1458 1488 1498 1528 2277 2355 2684 2704 3456 3809 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=0.5 if `varname'==-10
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
   }
}
* -1 and -3
foreach vnum in 767 874 894 914 1269 1279 1568 1578 1588 1598 1737 1807 1845 2149 2217 2794 2824 2867 ///
                2897 2926 2946 2966 2976 3436 3526 3536 3581 3627 3659 3669 3680 3700 3761 3786 3882  ///
                3894 3992 4012 4022 4056 4609 4620 4689 4700 5375 5386 5430 5901 5923 5945 6194 20007 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
   }
}
* -1 and -2 and -3
foreach vnum in 845 2139 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-2
      replace `varname'=. if `varname'==-3
   }
}
* -1 and -10
foreach vnum in 2887 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=0.5 if `varname'==-10
      replace `varname'=. if `varname'==-1
   }
}
* -1 and -3 and -6
foreach vnum in 3710 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
      replace `varname'=. if `varname'==-6
   }
}
* -3 and -4
foreach vnum in 2754 2764 3872 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=. if `varname'==-3
      replace `varname'=. if `varname'==-4
   }
}
* -1 and -3 and -11
foreach vnum in 2804 3546 {
   forval inst=0/1 {
      local varname="v`vnum'_`inst'_0v"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
      replace `varname'=. if `varname'==-11
   }
}
    

/* check that there are at least 20 distinct values in observations with two instances, */
/* that there are at least 100 observations with repeats, */
/* and that there are no variables with >-20% of observations having one single value */

ds
local fidlist=r(varlist)
local numvars=wordcount("`fidlist'")

local exclncount=0
local excldcount=0
local exclpcount=0
local exclnids=""
local excldids=""
local exclpids=""
local inclcount=0
local inclids=""

forvalues vnum=2(2)`numvars' {
   local fieldname0=word("`fidlist'",`vnum')
   local fieldname1=word("`fidlist'",`vnum'+1)
   gen include=(`fieldname0'<. & `fieldname1'<.)
   egen tag0=tag(`fieldname0') if include
   egen tag1=tag(`fieldname1') if include
   quietly count if include
   local n=r(N)
   egen x0=count(1) if include, by(`fieldname0')
   egen x1=count(1) if include, by(`fieldname1')
   
   forvalues inst = 0/1 {
      quietly summ x`inst' if include
      local pmax`inst'=r(max)/`n'
      quietly count if tag`inst'==1
      local dcount`inst'=r(N)
   }
   local fnum=subinstr(subinstr("`fieldname0'","v","",2),"_0_0"," ",1)
   if `n'<100 {
      drop `fieldname0' `fieldname1'
      local exclncount=`exclncount'+1 
      local exclnids="`exclnids'" + "`fnum'" + " "
   }
   else if `dcount0'<20 | `dcount1'<20 {
      drop `fieldname0' `fieldname1'
      local excldcount=`excldcount'+1
      local excldids="`excldids'" + "`fnum'" + " "
   }
   else if `pmax0'>=0.2 | `pmax1'>=0.2 {
      drop `fieldname0' `fieldname1'
      local exclpcount=`exclpcount'+1
      local exclpids="`exclpids'" + "`fnum'" + " "
   }
   else {
      local inclcount=`inclcount'+1
      local inclids="`inclids'" + "`fnum'" + " "
   }
   drop tag0 tag1 include x0 x1
   macro drop n dcount0 dcount1 pmax0 pmax1 fnum
}

di "Number of fields dropped due to less than 100 repeated values is `exclncount'"
di "These are `exclnids'"
di "Number of fields dropped due to fewer than 20 distinct values is `excldcount'"
di "These are `excldids'"
di "Number of fields dropped due to at least 20% with same value is `exclpcount'"
di "These are `exclpids'"
di "The remaining `inclcount' fields are `inclids'" 

save $RESULTS/check20.dta, replace

export delimited $RESULTS/finalfile2.txt, delimiter(tab) replace 
export delimited $RESULTS/finalfile2.csv, delimiter(",") replace

