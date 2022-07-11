/* arrays_23.do - Deals with specific fields with multiple values in one visit */ 
/* Requires - mainfile23a.dta */ 
/* Main output - mainfile23a.dta */

/* Note - only file mainfile23a has arrays */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS 

 clear

 use mainfile23a.dta, clear

*Pulse wave analysis fields array of 5 (average)
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

 save mainfile23a.dta, replace
