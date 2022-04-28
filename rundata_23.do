/* runs the remaining do files */
/* need to have run the getdata_23.sh */
/* need to have mainfile01.txt */

global DATA "/user/work/kd18661/meas_error/data"
global RESULTS "/user/work/kd18661/meas_error/results"
global CODE "/user/home/kd18661/meas_error/code/measurement_error_adjustment"

do "$CODE/withdrawals_23.do"

do "$CODE/dates_23.do"

do "$CODE/arrays_23.do"

do "$CODE/recodes_23.do"

do "$CODE/extraexcl_23.do"

do "$CODE/concord_23.do"





