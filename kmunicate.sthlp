{smcl}
{* *! version 1.0  16jan2025}{...}
{vieweralsosee "risktable" "help risktable"}{...}
{vieweralsosee "[ST] sts graph" "help sts graph"}{...}
{viewerjumpto "Syntax" "smcl##syntax"}{...}
{viewerjumpto "Description" "smcl##description"}{...}
{viewerjumpto "Remarks" "smcl##remarks"}{...}
{p2colset 1 14 15 2}{...}
{p2col:{bf:kmunicate} {hline 2}}‘KMunicate’ style Kaplan–Meier graphs{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}{cmd:kmunicate} {ifin} {cmd:,} {opth time:points(numlist)} [ {opth by(varlist)} {opt xtit:le(string)} {opt save:table(filename, replace)} {opt noli:st} {it:sts_graph_options} ]{p_end}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth time:points(numlist)}}Required option. Specifies timepoints for which table will be constructed. Numlist must have smallest value ≥0 and largest value ≤maximum follow-up time.{p_end}
{synopt :{opth by(varlist)}}Compute summary numbers for each group formed by {it:varlist}.{p_end}
{synopt :{opt xtit:le(string)}}Specify xtitle (default is "Analysis time" as in {help sts_graph}).{p_end}
{synopt :{opt save:table(filename, replace)}}Save a Stata dataset containing the (transposed) summary table.{p_end}
{synopt :{opt nol:ist}}Suppress listing contents of the frame containing the (transposed) summary table in the results window.{p_end}
{synopt :{it:sts graph options}}Options of sts graph.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}{cmd:kmunicate} is a wrapper for {help sts graph} that implements ‘KMunicate’ style extended risktables.

{pstd}Note that you must {cmd:stset} your data before using {cmd:kmunicate}; see
{manhelp stset ST}.


{title:Examples}

{pstd}Basic Kaplan–Meier plot with KMunicate-style extended risktable.{p_end}
{phang}.
{stata "sysuse cancer"}{p_end}
{phang}.
{stata kmunicate, timepoints(0(10)40)}

{pstd}Now presented by {bf:drug} at times 0, 10, 20, 30 and 40, with confidence intervals (note: needs work).{p_end}
{phang}.
{stata kmunicate, by(drug) timepoints(0(10)40) ci}

{pstd}Using options of {cmd:sts graph} to improve the plot. Note: uses Stata 18 colors (stc1, stc2, stc3).{p_end}
{phang}.
{stata kmunicate, by(drug) time(0(10)40) ci ci1(fc(stc1%40)) plot1(lc(stc1)) ci2(fc(stc2%40)) plot2(lc(stc2)) ci3(fc(stc3%40)) plot3(lc(stc3)) legend(order(7 "Placebo" 8 "Other" 9 "NA") cols(1) pos(7) ring(0)) scale(0.8) ysize(6)}


{title:Stored results}

{pstd}Rather than standard stored results, {cmd:kmunicate} returns the {cmd:sts graph} code it used in global F9. This is a trick that allows users to hit the F9 key to paste the code straight into the command window and edit directly. Alternatively it can be displayed in the results window using{p_end}
{phang}. {stata display `"$F9"'}


{title:Reference}

{phang}
TP Morris, CI Jarvis, W Cragg, PPJ Phillips, B Choodari-Oskooei, MR Sydes. Proposals
on Kaplan-Meier plots in medical research and a survey of stakeholder
views. {it:BMJ Open}. 2019; 9(9):e030215.
{browse "https://dx.doi.org/10.1136/bmjopen-2019-030215":doi:10.1136/bmjopen-2019-030215}{p_end}


{title:Authors}
{phang}Tim P Morris, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}{p_end}

{phang}Patrick Royston, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:j.royston@ucl.ac.uk":j.royston@ucl.ac.uk}{p_end}

{phang}Ian R White, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}


{title:Acknowledgements}
{phang}Matt R. Sydes (NHS England){p_end}
{phang}Ian R. White (MRC Clinical Trials Unit at UCL){p_end}
{phang}David J. Fisher (MRC Clinical Trials Unit at UCL){p_end}
{phang}Nicholas J. Cox (Durham University){p_end}


{title:Also see}
{phang}{helpb risktable} (installed with {cmd:kmunicate}), {helpb sts graph}{p_end}

