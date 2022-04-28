/* this excludes the ids of people who have withdrawn consent */
/* need to use the most up to date withdrawal file */
/* current file is w16729_20220222.csv */
/* also uses mainfile01.txt */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"

cd $RESULTS

*read withdrawal file into Stata
 import delimited f_eid using "$DATA/w16729_20220222.csv", delimiter(",") clear
 sort f_eid
 rename f_eid eid
 save withdrawals01.dta, replace

*read in main data and merge out withdrawals
 import delimited using "$RESULTS/mainfile01.txt", delimiter(tab) clear

 sort eid

 merge 1:1 eid using withdrawals01.dta, keep(master) nogen // master only i.e. not in exclusion file

 save mainfile01.dta, replace



