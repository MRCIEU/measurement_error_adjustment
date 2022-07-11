/* recodes_01.do - Amends some of the special coded non-numeric values */
/* Requires - mainfile01.dta */
/* Main output - mainfile01.dta */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

 use $RESULTS/mainfile01.dta, clear
 ds

*0 should be missing (coding 909, 1990, 6361)
 foreach vnum in 6348 6350 22670 22671 22672 33673 22674 22675 22676 22677 22678 22679 22680 22681 23323 {
   forval inst=2/3 {
      local varname="x`vnum'_`inst'_0"
      capture replace `varname'=. if `varname'==0
   }
 }

*-1 only (codings 170, 100696)
 foreach vnum in 129 130 4282 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=0 if `varname'==-1
   }
 }

*-1 and -3 and -10 (less than) (codings 100290 100298 100300 100329 100355 100373 100537 100567 100569) 
 foreach vnum in 699 757 777 796 1050 1060 1070 1080 1090 1289 1299 1309 1319 1438 1458 1488 1498 1528 ///
                2277 2355 2684 2704 3456 3809 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=0.5 if `varname'==-10
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
   }
 }

*-1 and -3 (codings 13 100291) 
 foreach vnum in 709 767 874 884 894 904 914 1160 1269 1279 1568 1578 1588 1598 1608 1737 1807 1845 1873 1883 ///
                2149 2217 2405 2714 2794 2824 2867 2897 2926 2946 2966 2976 3436 3526 3536 3581 3627 3659 ///
                3669 3680 3700 3761 3786 3829 3839 3849 3882 3894 3972 3982 3992 4012 4022 4056 4407 4418 ///
                4429 4440 4451 4462 4609 4620 4689 4700 5057 5364 5375 5386 5430 5901 5923 5945 6194 20007 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
   }
 }

*-1 and -2 and -3 (codings 100306 100307 100504 100585)
 foreach vnum in 845 864 2139 2744 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-2
      replace `varname'=. if `varname'==-3
   }
 }

*-1 and -10 (coding 100353)
 foreach vnum in 2887 6183 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=0.5 if `varname'==-10
      replace `varname'=. if `varname'==-1
   }
 }

*-1 and -3 and -6 (coding 100582)
 foreach vnum in 3710 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
      replace `varname'=. if `varname'==-6
   }
 }

*-3 and -4 (coding 100586)
 foreach vnum in 2754 2764 3872 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=. if `varname'==-3
      replace `varname'=. if `varname'==-4
   }
 }

*-1 and -3 and -11 (coding 100595 100598)
 foreach vnum in 2804 3546 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=. if `varname'==-1
      replace `varname'=. if `varname'==-3
      replace `varname'=. if `varname'==-11
   }
 }

*-3 (coding 100584)
 foreach vnum in 2734 {
   forval inst=0/1 {
      local varname="x`vnum'_`inst'_0"
      replace `varname'=. if `varname'==-3
   }
 }
    
 save $RESULTS/mainfile01.dta, replace

