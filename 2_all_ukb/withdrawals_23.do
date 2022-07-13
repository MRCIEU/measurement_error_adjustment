/* withdrawals.do - this excludes the ids of participants who have withdrawn consent */ 
/* Requires - withdrawal file (latest is w16729_20220222.csv), mainfile23a.txt, mainfile23b.txt and mainfile23c.txt */
/* Main output - mainfile23a.dta, mainfile23b.dta and mainfile23c.dta */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*read withdrawal file into Stata
 import delimited f_eid using "$DATA/w16729_20220222.csv", delimiter(",") clear
 sort f_eid
 rename f_eid eid
 save withdrawals23.dta, replace

*read in main data and merge out withdrawals
 foreach f in a b c {
   import delimited using $RESULTS/mainfile23`f'.txt, delimiter(tab) clear
   sort eid
   merge 1:1 eid using withdrawals23.dta, keep(master) nogen // master only i.e. not in exclusion file
   save mainfile23`f'.dta, replace
 }


