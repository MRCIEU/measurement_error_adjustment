/* this do file checks and removes 
   a) variables with <20 distinct values per instance (for observations non missing in both instances)
   b) variables with less than 100 observations non missing in both instances
   c) variables with >=20% of non missing observations having one single value (should be categorical) */
/* instances 2+3 */

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

foreach f in a b c {

  use mainfile23`f'.dta, clear
  order _all, alphabetic
  order eid assess_date2 assess_date3 assess_td diet_date2 diet_date3 diet_td

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

  save $RESULTS/finalfile23`f'.dta, replace
}

  di "Number of fields dropped due to less than 100 repeated values is `exclncount'"
  di "These are `exclnids'"
  di "Number of fields dropped due to fewer than 20 distinct values is `excldcount'"
  di "These are `excldids'"
  di "Number of fields dropped due to at least 20% with same value is `exclpcount'"
  di "These are `exclpids'"
  di "The remaining `inclcount' fields are `inclids'" 
