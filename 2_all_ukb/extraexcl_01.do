/* extraexcl_01.do - checks and removes 
   a) variables with <20 distinct values per instance (for observations non missing in both instances)
   b) variables with less than 100 observations non missing in both instances
   c) variables with >=20% of non missing observations having one single value (should be categorical) */
/* Requires - mainfile01.dta */
/* Main output - finalfile01.dta */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

local exclncount=0
local excldcount=0
local exclpcount=0
local exclnids=""
local excldids=""
local exclpids=""
local inclcount=0
local inclids=""
local dexclncount=0
local dexcldcount=0
local dexclpcount=0
local dexclnids=""
local dexcldids=""
local dexclpids=""
local dinclcount=0
local dinclids=""

use mainfile01.dta, clear
order _all, alphabetic
*put non-analytical variables first
order eid assess_date0 assess_date1 assess_td diet_date1 diet_date2 diet_td

ds
local fidlist=r(varlist)
local numvars=wordcount("`fidlist'")
disp "Number of variables = `numvars'"

*cycle through all except eid and date fields
 forvalues vnum=8(2)`numvars' {
   di "`vnum' of `numvars'"
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
   local fnum=substr("`fieldname0'",2,strlen("`fieldname0'")-5)
   local inum=substr("`fieldname0'",-3,1)
*exclude if fewer than 100 non-missing observations
   if `n'<100 {
      drop `fieldname0' `fieldname1'
      if `inum'==1 {
        local dexclncount=`dexclncount'+1 
        local dexclnids="`dexclnids'" + "`fnum'" + " "
      }
      if `inum'==0 {
        local exclncount=`exclncount'+1
        local exclnids="`exclnids'" + "`fnum'" + " "
      }
   }
*exclude if fewer than 20 distinct values per instance
   else if `dcount0'<20 | `dcount1'<20 {
      drop `fieldname0' `fieldname1'
      if `inum'==1 {
        local dexcldcount=`dexcldcount'+1
        local dexcldids="`dexcldids'" + "`fnum'" + " "
      }
      if `inum'==0 {
        local excldcount=`excldcount'+1
        local excldids="`excldids'" + "`fnum'" + " "
      }
   }
*exclude if >=20% of observations have a single value
   else if `pmax0'>=0.2 | `pmax1'>=0.2 {
      drop `fieldname0' `fieldname1'
      if `inum'==1 {
        local dexclpcount=`dexclpcount'+1
        local dexclpids="`dexclpids'" + "`fnum'" + " "
      }
      if `inum'==0 {
        local exclpcount=`exclpcount'+1
        local exclpids="`exclpids'" + "`fnum'" + " "
      }
   }
*otherwise include
   else {
      if `inum'==1 {
        local dinclcount=`dinclcount'+1
        local dinclids="`dinclids'" + "`fnum'" + " "
      }
      if `inum'==0 {
        local inclcount=`inclcount'+1
        local inclids="`inclids'" + "`fnum'" + " "
      }
   }
   drop tag0 tag1 include x0 x1
   macro drop n dcount0 dcount1 pmax0 pmax1 fnum
 }

 save $RESULTS/finalfile01.dta, replace

 di "Number of fields dropped due to less than 100 repeated values is `exclncount'"
 di "These are `exclnids'"
 di "Number of fields dropped due to fewer than 20 distinct values is `excldcount'"
 di "These are `excldids'"
 di "Number of fields dropped due to at least 20% with same value is `exclpcount'"
 di "These are `exclpids'"
 di "The remaining `inclcount' fields are `inclids'" 

 di "Number of diet fields dropped due to less than 100 repeated values is `dexclncount'"
 di "These are `dexclnids'"
 di "Number of diet fields dropped due to fewer than 20 distinct values is `dexcldcount'"
 di "These are `dexcldids'"
 di "Number of diet fields dropped due to at least 20% with same value is `dexclpcount'"
 di "These are `dexclpids'"
 di "The remaining `dinclcount' diet fields are `dinclids'"


