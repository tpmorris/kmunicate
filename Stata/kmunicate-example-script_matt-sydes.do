* Alternative example code for KMunicate-style KM plots
// KMunicate workaround sytax
// Matt Sydes 12-May-2020
version 16




//---------------------------------------------------

clear *
webuse brcancer // Can sysuse once you download the datasets
rename hormon drug

stset rectime, f(censrec==1) sca(30.44)
stdes
lab def drug_ 0 "Ctrl" 1 "Actv" // make up some value labels
lab val drug drug_


* A basic KM plot
//sts graph, by(drug) risktable name(kmvanilla, replace)

***
* Constructing the var labels that will make the table (the tricky bit)
* Need to know
* 1. The times at which you want to summarise info
* 2. The labels for the groups

* First create row labels for risk table (need to modify according to # groups - clunky)
loc risktablekeypos -10
lab def mylab `risktablekeypos' `" " " " " "{bf:Control}         " "At-risk now    " "Censored now" "Event by now " "{bf:Active}          " "At-risk now    " "Censored now" "Event by now "', modify
local times 0(6)84 // times at which you want to summarise
local groups 0 1 // labels for groups
forval j = `times' {
    foreach i of local groups {
        quietly count if drug==`i' & _t >= `j' // need to change 'drug' to whatever the by() var is
            local risk_`i'_`j' = r(N)
         quietly count if drug==`i' & _t < `j' & !_d
           local cens_`i'_`j' = r(N)
        quietly count if drug==`i' & _t < `j' & _d
            local ev_`i'_`j' = r(N)
		nois di "Time = `j' ---- Group = `i' --- Risk = `risk_`i'_`j'' --- Censored = `cens_`i'_`j'' --- Events = `ev_`i'_`j''"
    }
    if `j'!=40 local xtit // Choose value of !`j' where you want the x title to appear (e.g. central point of x range)
    else local xtit "Time since randomisation (months)" // choose title for x-axis
    * Have to modify following line for fewer or more groups
    lab def mylab `j' `" "`j'" " `xtit'" " " "`risk_0_`j''" "`cens_0_`j''" "`ev_0_`j''" " " "`risk_1_`j''" "`cens_1_`j''" "`ev_1_`j''" ""', modify
	nois di _n
}
lab val _t mylab
***
* Now create the graph
#delimit ;
sts graph,
	tmax(73)
    by(drug) plot1opts(lc(navy)) plot2opts(lc(red))
    ci ci1opts(fc(navy%30)) ci2opts(fc(red%30)) // ciopts(recast(rarea) lwidth(none)) // recast fixes outer-lines bug but loses legend symbol!
    legend(order(6 "Active" 5 "Control") ring(0) cols(1) pos(7) size(*0.4) symxsize(*0.3) rowgap(*0.2) region(lc(none)) title("{bf:Key}", pos(11) c(black) size(*0.3)))
    ytitle("Proportion surviving")
    xtitle("")
    ylab(,angle(h) format(%3.2f) labsize(small))
	xlab(`risktablekeypos' 0(6)72, valuelabels labsize(small))
    xline(0, lc(black) lw(vthin))
	title("KM plot", pos(11) c(black) size(medsmall))
    graphr(c(white))
	plotregion(margin(medsmall))
    name(kmunicate, replace)
    ;
#delimit cr


