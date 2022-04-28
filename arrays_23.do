/* this deals with specific fields with multiple values in one visit */
/* we need to find the mean or minimum of these values */
/* for instances 2-3 only */

/* there is only one that uses coded values but we want the minimum */
/* there are no array fields using the mean value that use coded values */

/* to run this do file you need to have finalfile.dta */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS 

clear

*only file a has arrays
use mainfile23a.dta, clear

  /*
*Blood pressure fields (average of 2) - not in file 23 anymore
foreach fid in 93 94 95 102 4079 4080 {
   forvalues inst = 2/3 {
      gen num=0
      gen val=0
      forvalues count = 0/1 {
         replace num=num+1 if x`fid'_`inst'_`count' < .
         replace val=val+x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < .
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0=val/num if num>0
      drop num val
   }
}

*Spirometry fields array of 3 (average)  - not in file 23 anymore

foreach fid in 3062 3063 3064 {
   forvalues inst = 2/3 {
      gen num=0
      gen val=0
      forvalues count = 0/2 {
         replace num=num+1 if x`fid'_`inst'_`count' < .
         replace val=val+x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < .
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0=val/num if num>0
      drop num val
   }
} */

*Pulse wave analysis fields array of 5 (average)
*instances 2-3
foreach fid in 12673 12674 12675 12676 12677 12678 12679 12680 12681 12682 12683 12684 12685 12686 12687 12702 {
   forvalues inst = 2/3 {
      gen num=0
      gen val=0
      forvalues count = 0/4 {
         replace num=num+1 if x`fid'_`inst'_`count' < .
         replace val=val+x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < .
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0=val/num if num>0
      drop num val
   }
}

/*
*Interpolated age when cancer first diagnosed (minimum) - not in file 23 anymore
*This also uses coded values of -1 and -3
*If any have these values then the final value (minimum) should be this as these will be deleted next step
foreach fid in 20007 {
   forvalues inst = 2/3 {
      gen min=.
      forvalues count = 0/5 {
         replace min=x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < min
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0 = min
      drop min
   }
}  */

save mainfile23a.dta, replace
