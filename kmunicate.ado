*! 1.0  2025-01-16  Contributors: Tim P. Morris, Ian R. White
*  For history, see end of file

program define kmunicate, sortpreserve rclass
	version 16

	st_is 2 analysis // check that data are stset
	quietly which risktable
	if _rc==111 {
		display as error "Cannot find risktable.ado, which is needed to construct the kmunicate risk tables"
		exit 111
	}

*   syntax diverts a few options then passes everything else through to sts graph
	syntax [if] [in] ///
		, TIMEpoints(numlist) [ BY(varlist) XTITle(string) SAVETable(string asis) NOLIst * ]
	marksample touse
	
	risktable `timepoints' `if' `in' , by("`by'") xtitle("`xtitle'") savedata(`savetable') `nolist'
	
//	di "`options'"
	if regexm("`options'","ytit")==0 {
    	local ytitle `""CENSORED BY", orientation(horizontal) color(none)"'
	}
//	di `"`ytitle'"'
	
	global F9 sts graph `if' `in' , by("`by'") ///
		xlab(`s(kmulabs)', labjustification(right)) xtitle("") ytitle(`ytitle') ///
		`options'
	$F9
end

* 2025-01-16 1.0  TPM made tweaks and set to version 1.0
* 2023-11-16 0.11 IRW Minor edits
* 2023-10-09 0.1  TPM initialised kmunicate
