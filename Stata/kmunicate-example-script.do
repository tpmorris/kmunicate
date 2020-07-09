* Tim Morris 09jul2020
* Example code for KMunicate-style KM plots
* The trick here is to insert linebreaks in the value labels
* so that instead of 'a number' it's a column of text
* Awkward feature is that, to label the by() groups,
* one has to extend the 'plotregion' to the left, since group
* labels are also value labels
version 16

* Get survival datasets from Stata Press book (only needed once)
/*
    net from http://www.stata-press.com/data/cgm3r/
    net get survival
*/

clear *
sysuse cancer // Once you download the datasets you can sysuse them
stdes
* Make up value labels for the three arms
lab def drug 1 "Ctrl" 2 "Another" 3 "One thing"
    lab val drug drug

* A basic KM plot
//sts graph, by(drug) risktable name(kmvanilla, replace)

***
* Constructing the var labels that will make the table (the tricky bit)
* Need to know
* 1. The times at which you want to summarise info
* 2. The labels for the groups

* First create row labels for risk table (need to modify according to # groups - clunky)
lab def mylab -5 `" " " " " "{bf:Ctrl}        " "     At-risk" "Censored" "       Died" "{bf:One thing}      " "     At-risk" "Censored" "       Died" "{bf:Another}        " "     At-risk" "Censored" "       Died" "' , modify
local times 0(5)40 // times at which you want to summarise
local groups 1 2 3 // labels for groups
forval j = `times' {
    foreach i of local groups {
        quietly count if drug==`i' & _t >= `j' // need to change 'drug' to whatever the by() var is
            local risk_`i'_`j' = r(N)
         quietly count if drug==`i' & _t < `j' & !_d
           local cens_`i'_`j' = r(N)
        quietly count if drug==`i' & _t < `j' & _d
            local ev_`i'_`j' = r(N)
    }
    if `j'!=20 local xtit // Choose value of !`j' where you want the x title to appear (e.g. central point of x range)
    else local xtit "Time since randomisation (months)" // choose title for x-axis
    * Notes:
    *   Here I have groups 1, 2 and 3. For different values or strings, need to change the contents of `groups' and `mylab'
    *   The following line needs to be modified for a different number of groups (currently three)
    lab def mylab `j' `" "`j'" " `xtit'" " " "`risk_1_`j''" "`cens_1_`j''" "`ev_1_`j''" " " "`risk_2_`j''" "`cens_2_`j''" "`ev_2_`j''" " " "`risk_3_`j''" "`cens_3_`j''" "`ev_3_`j''" "', modify
}
lab val _t mylab

***
* Now create the graph
#delimit ;
sts graph,
    by(drug) plot1opts(lc(navy)) plot2opts(lc(maroon)) plot3opts(lc(dkgreen))
    ci ci1opts(fc(navy%30)) ci2opts(fc(maroon%30)) ci3opts(fc(dkgreen%30)) // ciopts(recast(rarea) lwidth(none)) // lwidth fails; recast fixes outer-lines bug but loses legend symbol in the process!
    legend(order(9 "One thing" 8 "Another" 7 "Ctrl") ring(0) cols(1) pos(7))
    ytitle("Proportion surviving")
    xtitle("")
    xlab(-5 0(5)40, valuelabels labsize(small))
    xline(0, lc(gs8) lw(vthin))
    plotregion(margin(medsmall))
    name(kmunicate, replace)
    ;
#delimit cr
