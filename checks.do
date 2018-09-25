
global RESULTS "~/meas_error/results"
global DATA "~/meas_error/data"

cd $RESULTS
   
ssc install concord

use check20.dta, clear

*just check the ones that didn't have concordance output or had less than 100 records
foreach fnum in 3160 4138 4139 4140 4141 4143 4144 4145 4146 4689 5430 5901 5923 5945 6194 93 94 95 {
local fid0="v" + "`fnum'" + "_0_0v"
local fid1="v" + "`fnum'" + "_1_0v"
sum `fid0', detail
sum `fid1', detail
tab `fid0' if `fid1'<.
tab `fid1' if `fid0'<.
}

