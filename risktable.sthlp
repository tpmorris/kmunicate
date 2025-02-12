{smcl}
{* *! version 1.0  16jan2025}{...}
{vieweralsosee "kmunicate" "help kmunicate"}{...}
{vieweralsosee "[ST] sts graph" "help sts graph"}{...}
{viewerjumpto "Syntax" "smcl##syntax"}{...}
{viewerjumpto "Description" "smcl##description"}{...}
{viewerjumpto "Remarks" "smcl##remarks"}{...}
{p2colset 1 14 15 2}{...}
{p2col:{bf:risktable} {hline 2}}‘KMunicate’ style risk tables to accompany Kaplan–Meier graphs{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}{cmd:risktable} {it:times} {ifin}
[{cmd:,} {opth by(varlist)} {opt xtit:le(axis_title)} {opt save:data(filename, replace)} {opt noli:st}]

{marker times}{...}
{phang}
where {it:times} is a {it:{help numlist}} with smallest element ≥0 and largest element ≤ the final follow-up time.

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth by(varlist)}}compute summary numbers for each group formed by {it:varlist}{p_end}
{synopt :{opt xtit:le(axis_title)}}specify xtitle (default is "Analysis time" as in {help sts_graph}){p_end}
{synopt :{opt save:data(filename, replace)}}save a dataset containing the (transposed) summary table{p_end}
{synopt :{opt nol:ist}}do not list contents of frame containing the (transposed) summary table{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{pstd} {cmd:risktable} is a helper for {help kmunicate} but can be used alone. It
calculates the numbers for extended ‘kmunicate’ style risktables beneath Kaplan–Meier
graphs and returns them in {bf:s(kmulabs)} and, optionally, as a (transposed) dataset.

{pstd} Note that you must {cmd:stset} your data before using {cmd:risktable}; see
{manhelp stset ST}. Note also that {cmd:risktable} does not currently work with multi-row data (for example after {cmd:stsplit}) in which a single individual has several rows.


{title:Examples}

{pstd}Display KMunicate-style extended risktable.{p_end}
{phang}. {stata "sysuse cancer"}{p_end}
{phang}. {stata "risktable 0(10)40"}{p_end}


{pstd}Now for each value of {bf:drug} for integer times from 0 to 40, saving the risktable as "risktabledata.dta" and not listing in the results window.{p_end}
{phang}. {stata "risktable 0/40, by(drug) savedata(risktabledata)"}{p_end}


{title:Stored results}

{pstd}{cmd:risktable} stores only {bf:s(kmulabs)}, the labels that are used by {help kmunicate}. To look at them, type:{p_end}
{pstd}. {stata display `"`s(kmulabs)'"'}


{title:References}

{phang}
T. P. Morris, C. I. Jarvis, W. Cragg, P. P. J. Phillips,
B. Choodari-Oskooei, M. R. Sydes.
{browse "https://dx.doi.org/10.1136/bmjopen-2019-030215":Proposals on Kaplan-Meier plots in medical research and a survey of stakeholder views: risktable.} {it:BMJ Open}. 2019; 9(9):e030215. doi:10.1136/bmjopen-2019-030215


{title:Authors}
{phang}Tim P. Morris, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}{p_end}

{phang}Patrick Royston, MRC Clinical Trials Unit at UCL{p_end}
{phang}Email: {browse "mailto:j.royston@ucl.ac.uk":j.royston@ucl.ac.uk}{p_end}


{title:Acknowledgements}
{phang}Matt R. Sydes (NHS England){p_end}
{phang}Ian R. White (MRC Clinical Trials Unit at UCL){p_end}
{phang}David J. Fisher (MRC Clinical Trials Unit at UCL){p_end}
{phang}Myra McGuinness (University of Melbourne){p_end}


{title:Also see}
{phang}{helpb kmunicate} (if installed), {helpb sts list}{p_end}

