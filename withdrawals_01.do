/* withdrawals.do - this excludes the ids of participants who have withdrawn consent */
/* Requires - most up to date withdrawal file (latest is w16729_20220222.csv), and mainfile01.txt */
/* Main output - mainfile01.dta */

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

*only keep records that are not in the exclusion file i.e. nonmatches from the master
  merge 1:1 eid using withdrawals01.dta, keep(master) nogen

  save mainfile01.dta, replace



