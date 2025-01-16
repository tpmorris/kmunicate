{smcl}
{* *! version 0.3  10nov2023}{...}
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

{phang}{cmd:kmunicate} {ifin} {cmd:,} {opt time:points(numlist)}
{break}[ {opt xtit:le(string)} {opt save:table(filename, replace)} {opt noli:st} {it:sts_graph_options} ]{p_end}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt time:points(numlist)}}Required option. Specifies timepoints for which table will be constructed. Numlist must have smallest value ≥0 and largest value ≤maximum follow-up time.{p_end}
{synopt :{opth by(varlist)}}Compute summary numbers for each group formed by {it:varlist}.{p_end}
{synopt :{opt xtit:le(axis_title)}}Specify xtitle (default is "Analysis time" as in {help sts_graph}).{p_end}
{synopt :{opt save:table(filename, replace)}}Save a Stata dataset containing the (transposed) summary table.{p_end}
{synopt :{opt nol:ist}}Do not list contents of frame containing the (transposed) summary table.{p_end}
{synopt :{opt sts graph options}}Options to pass to sts graph.{p_end}
{synoptline}

{marker timepoints}{...}
{phang}
where the {it:{help numlist}} specified in the non-optional {it:timepoints} must
have smallest value ≥0 and largest value ≤final follow-up time.


{marker description}{...}
{title:Description}
{phang}
{cmd:kmunicate} is a wrapper for {help sts graph} that implements ‘KMunicate’ style extended risktables.
{p_end}


{title:Examples}

{pstd}Basic Kaplan–Meier plot with KMunicate-style extended risktable.{p_end}
{phang}. {stata "sysuse cancer"}{p_end}
{phang}. {stata "kmunicate"}

{pstd}Now presented by {bf:drug} at times 0, 10, 20, 30 and 40. Plot confidence intervals.{p_end}
{phang}. {stata "kmunicate , by(drug) timepoints(0(10)40) ci"}


{title:Reference}

{phang}
TP Morris, CI Jarvis, W Cragg, PPJ Phillips, B Choodari-Oskooei, MR Sydes. Proposals
on Kaplan-Meier plots in medical research and a survey of stakeholder
views. {it:BMJ Open}. 2019; 9(9):e030215.
{browse "https://dx.doi.org/10.1136/bmjopen-2019-030215":doi:10.1136/bmjopen-2019-030215}{p_end}


{title:Authors}
{phang}Tim P. Morris, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}{p_end}

{phang}Patrick Royston, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:j.royston@ucl.ac.uk":j.royston@ucl.ac.uk}{p_end}


{title:Acknowledgements}
{phang}Matt R. Sydes (NHS England){p_end}
{phang}Ian R. White (MRC Clinical Trials Unit at UCL){p_end}
{phang}David J. Fisher (MRC Clinical Trials Unit at UCL){p_end}
{phang}Nicholas J. Cox (Durham University){p_end}


{title:Also see}
{phang}{helpb risktable} (if installed), {helpb sts graph}{p_end}

