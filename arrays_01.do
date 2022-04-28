/* this deals with specific fields with multiple values in one visit */
/* we need to find the mean or minimum of these values */
/* for instances 0 and 1 only */

/* there is only one that uses coded values but we want the minimum */
/* there are no array fields using the mean value that use coded values */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS 

clear
use mainfile01.dta, clear

*Blood pressure fields (average)
foreach fid in 93 94 95 102 4079 4080 {
   forvalues inst = 0/1 {
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
*Vision fields with array of 10 (average)
foreach fid in 5084 5085 5086 5087 5088 5089 {
   forvalues inst = 0/1 {
      gen num=0
      gen val=0
      forvalues count = 0/9 {
         replace num=num+1 if x`fid'_`inst'_`count' < .
         replace val=val+x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < .
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0=val/num if num>0
      drop num val
   }
}

*Vision fields with array of 6 (average) part 1
forvalues fid = 5096/5119 {
   forvalues inst = 0/1 {
      gen num=0
      gen val=0
      forvalues count = 0/5 {
         replace num=num+1 if x`fid'_`inst'_`count' < .
         replace val=val+x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < .
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0=val/num if num>0
      drop num val
   }
}

*Vision fields with array of 6 (average) part 2
foreach fid in 5132 5133 5134 5135 5156 5157 5158 5159 5160 5161 5162 5163 {
   forvalues inst = 0/1 {
      gen num=0
      gen val=0
      forvalues count = 0/5 {
         replace num=num+1 if x`fid'_`inst'_`count' < .
         replace val=val+x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < .
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0=val/num if num>0
      drop num val
   }
}


*Spirometry fields array of 3 (average)
foreach fid in 3062 3063 3064 {
   forvalues inst = 0/1 {
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
}

*Interpolated age when cancer first diagnosed (minimum)
*This also uses coded values of -1 and -3
*If any have these values then the final value (minimum) should be this as these will be deleted next step
foreach fid in 20007 {
   forvalues inst = 0/1 {
      gen min=.
      forvalues count = 0/5 {
         replace min=x`fid'_`inst'_`count' if x`fid'_`inst'_`count' < min
         drop x`fid'_`inst'_`count'
      }
      gen x`fid'_`inst'_0 = min
      drop min
   }
}

save mainfile01.dta, replace
