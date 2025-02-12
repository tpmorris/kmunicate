*! 1.1 | 2025-02-12 | Tim P. Morris, Patrick Royston, Ian R. White
*  For history, see end of file

program define risktable, sortpreserve sclass
    version 16
    
    st_is 2 analysis // check that data are stset
    
    syntax anything [if] [in] , ///
        [ BY(varlist) XTITle(string) SAVEdata(string asis) NOLIst ]
	marksample touse
    
*   Assert that `anything' is a numlist
    capture numlist `"`anything'"'
    if _rc > 0 {
        display as error "Invalid syntax; please specify a numlist for times."
        exit 198
    }
    else {
        local times = r(numlist)
        display as text "Timepoints specified: " as result "`times'"
    }
    tokenize `"`times'"' , parse(" ")
    local mintime `1'
    foreach t of local times {
        local maxtime `t'
    }
    local midtime = ceil((`mintime'+`maxtime')/2)
	
	if "`by'" != "" display as text "Risk tables by: " as result "`by'"
    sreturn local byvars `"`by'"'

*   Declare temps
    tempvar grp
    tempname tmpfrm

*   Record current frame name to revert to (don't assume default)
    frame pwf
    local orig_frame = r(currentframe)

*   Parse `"savedata"' option at comma into locals named `replace' and `savefile'
    tokenize `"`savedata'"', parse(",")
    local replace = "`2' `3'"
    local savefile  = "`1'"
    if ("`savefile'" != "" & "`replace'" == "") {
        capture confirm file `1'
        if !_rc {
            display as error `"File `savefile' already exists (specify "replace" in the savedata({it:filename}) option to replace it"'
            exit 602
        }
    }

*   Create group variable
    if "`by'" != "" {
        sort `by'
        egen `grp' = group(`by') if `touse', missing label
    }
    else if "`by'" == "" {
        quietly gen byte `grp' = 1
    }
    quietly levelsof `grp'
    local ngrp = r(r)
    
*	Get group values and value labels for group variable to
*   Need length of labels to know what str to specify when writing to frame
	forvalues g = 1/`ngrp'{
		sum `by' if `touse' & `grp' == `g' , meanonly
		local group`g' = r(mean)
	}
	local value_label : value label `grp'
	if !missing("`value_label'") {
		forvalues g = 1/`ngrp'{
			local value_label`g' : label `value_label' `g'
		}
        local max_lab_len : label `value_label' maxlength
	}
	else {
		local max_lab_len 0
		forvalues g = 1/`ngrp'{
			local value_label`g' `g'
			local lgi = length("`group`g''")
			if `lgi' > `max_lab_len' local max_lab_len = `lgi'
		}
	}
    if "`max_lab_len'" == "" local max_lab_len 1

* Get xtitle to go in string
    if "`xtitle'" == "" local timetitle "Analysis time"
    else local timetitle "`xtitle'"

*   Create and store KMunicate-style risktable
*   Output using sreturn local and, optionally, a frame
// di as text "Frame command is: frame create `tmpfrm' int(grp) str`max_lab_len'(grp_lab) float(time) int(noevent) int(censored) int(event)"
	frame create `tmpfrm' int grp str`max_lab_len' grp_lab float time int noevent int censored int event
    foreach t of numlist `times' {
		local kmulab `"`kmulab' `t' `" " `t'" "'
        forvalues g = 1/`ngrp'{
			if `t' == `mintime' & "`by'" != "" local kmulab `"`kmulab' "{bf:`value_label`g''}" "'
            else if `t' == `midtime' & `g'==1 local kmulab `"`kmulab' "`timetitle'" "'
            else local kmulab `"`kmulab' " " "'
            quietly count if `touse' & `grp'==`g' & cond(_d, _t > `t', _t >= `t')
            local noevent = r(N)
            quietly count if `touse' & `grp'==`g' & _t < `t' & !_d
            local cens = r(N)
            quietly count if `touse' & `grp'==`g' & _t <= `t' &  _d
            local ev = r(N)
//            quietly count if `touse' & `grp'==`g' & _t >  `t'
//            local noevent = r(N)
//            quietly count if `touse' & `grp'==`g' & _t <= `t' & !_d
//            local cens = r(N)
//            quietly count if `touse' & `grp'==`g' & _t <= `t' &  _d
//            local ev = r(N)
            if `t' == `mintime' local kmulab `"`kmulab' "No event by t:  `noevent'" "Censored before t:    `cens'" "Event by t:    `ev'" "'
            else local kmulab `"`kmulab' " `noevent'" " `cens'" " `ev'" "'
            if "`by'" == "" frame post `tmpfrm' (.) ("-") (`t') (`noevent') (`cens') (`ev')
			else frame post `tmpfrm' (`g') ("`value_label`g''") (`t') (`noevent') (`cens') (`ev')
        }
        local kmulab `"`kmulab' "' "'
    }
*   Tidy up frame
    frame change `tmpfrm'
    forvalues g = 1/`ngrp'{
        lab def grp_lab `g' "`value_label`g''" , modify
    }
    lab val grp grp_lab
    if `"`xtitle'"' != "" label data `"`xtitle'"'
    else                 label data "Analysis time"
    label variable noevent   "No event by t"
    label variable censored "Censored before t"
    label variable event    "Event by t"
    sort grp time
    if "`nolist'" == "" & "`by'" != "" list grp_lab time noevent censored event
    if "`nolist'" == "" & "`by'" == "" list time noevent censored event
    if "`savefile'" != "" {
        if "`savedata'" != "" & "`replace'" == "" noi display "saving table as " as result "`savefile'"
        capture confirm file "`savefile'"
        if "`savedata'" != "" & "`replace'" != "" noi display "replace: `replace'"
        quietly compress
        noisily save `"`savefile'"' `replace'
    }
    frame change `orig_frame'

    c_local kmulabs `"`kmulab'"'
    sreturn local kmulabs `"`kmulab'"'
end

* History:
* 2025-02-12 1.1  TPM Bugs fixed (with thanks to Myra McGuinness)
*                 - After posting, revert to original frame not default
*                 - Ensure 
* 2025-01-16 1.0  TPM set to version 1.0 for release
* 2023-11-16 0.31 IRW fixed error in calculation of table numbers
* 2023-11-10 0.3  TPM added functionality to return the required xlab as a string
*                 (with thanks to David J. Fisher)
* 2023-10-23 0.2  TPM rewrote (using code from PR version) after discussion on 
*                 program design with PR, Ian R. White and Matt R. Sydes
* 2023-01-16 0.1  PR initialised risktable
