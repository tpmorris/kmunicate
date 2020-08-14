
**********************************************************************************
***********************************************************************************

Project name:  
Purpose:       KMPLOT for 2 strata

Program name:  T:\Statistics\Projects\smart mental health\programs\utility\stigmanalysis.sas

Purpose:       This program is to generate KM plot with atrisk, censor and event information by strata.
               Graphical Template Language proc tempate has been used for coding.
               Some manipulation has been done on or after the last event occurrence(per strata)
               to match the direct output that Proc Lifetest provides.

Programmer:    Amritendu

History:       12July2020 KM PLOT with atrisk, censor and event information by strata


Input:         Dummy dataset of 10000 rows with columns: subject(numbers), duration, event and strata(sepstrata)

Output:        Libnames and macro variables

Documentation: 

Notes:         None

***********************************************************************************
**********************************************************************************;
/*To fetch the dummy dataset */
libname dataset 'T:\abhattacharya';

data pplf;
set dataset.pplfdata;
run;




/*getting n counts total and by strata*/

data pplf;
set pplf;
numbers=_n_;
run;
proc sql;
select count(numbers) into: ntotal from pplf ;
run;
%put &ntotal.;
proc sql;
select count(numbers) into: nsepstrata0 from pplf where sepstrata=0;
run;
%put &nsepstrata0.;
proc sql;
select count(numbers) into: nsepstrata1 from pplf where sepstrata=1;
run;
%put &nsepstrata1.;


proc format ;
value $a 1='1-sepstrata'
0='0-Non-sepstrata';
run;

/*reference lifetest code*/
ods trace on;

ods output ProductLimitEstimates = surv;

proc lifetest data=pplf plots=survival(atrisk=0 to 600 by 100) atrisk timelist = 0 to 600 by 100;

   time duration*event(0);

   strata sepstrata / test=logrank adjust=sidak;

run;

ods trace off;

/*manipulation to get censored count by strata, then take data by strata and set it side by side againt time*/


data surv;
set surv;
if numberatrisk=. then numberatrisk=0;
atrisk_=left;
if sepstrata=0 then total=&nsepstrata0.;
else if sepstrata=1 then total=&nsepstrata1.;
events_=failed;
censored_=total-(atrisk_ + events_);
keep sepstrata events_ censored_ atrisk_ Timelist;
run;



data surv0;
set surv;
where sepstrata=0;
sepstrata0=sepstrata;
atrisk_s0=atrisk_;
censored_s0=censored_;
events_s0=events_;
joincode=_n_;
keep sepstrata0 atrisk_s0 censored_s0 events_s0 joincode timelist; 
run;



data surv1;
set surv;
where sepstrata=1;
sepstrata1=sepstrata;
atrisk_s1=atrisk_;
censored_s1=censored_;
events_s1=events_;
joincode=_n_;
keep sepstrata1 atrisk_s1 censored_s1 events_s1 joincode; 
run;


data survivald;
merge surv0 surv1;
by joincode;
run;

/*GRAPHICAL TEMPLATE LANGUAGE*/


/**/
ods graphics on/height=6.0in width=8in border=on;
proc template;
 define statgraph kmplot;
 begingraph;
  entrytitle 'Kaplan Meier '/textattrs=(size=8);
 layout lattice / rows=2 columndatarange=union rowweights=(0.6 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05);

 layout overlay/yaxisopts=(label='Estimated Survival'
 linearopts=(viewmin=0 viewmax=1))
 xaxisopts=(Offsetmin=0.05 Offsetmax=0.05 
/*label='Time (Days) to In-Hospital Death' );*/
 /*change the values in linearopts for specific data. replace above line with below from label=*/
 label='Time (Days) to Death'  linearopts=(tickvaluelist=(0 100 200 300 400 500 600) viewmin=0 viewmax=600));


 stepplot x=time y=survival /name='step' group=stratum lineattrs=(pattern=solid);
/* scatterplot x=time y=survival/name='scat' legendlabel='Censored'*/
/* markerattrs=(symbol=plus) group=stratum ;*/
 bandplot limitlower=hw_lcl limitupper=hw_ucl x=time /group=stratum fillattrs=(transparency=0.6);
 discretelegend 'step' / location=inside
 halign=right valign=top 
 across=1 border=true
 title='Key' titleborder=true;
 endlayout;
/*entry 'sepstrata=0';*/
layout overlay/wallDisplay=none  yaxisopts=(display=none
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=YAS0/ markercharacter=sepstrataname0 markercharacterattrs=(weight=bold);
 
 endlayout;

layout overlay/ wallDisplay=none yaxisopts=(display=(tickvalue)
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=YAS0/ markercharacter=atrisk_s0;
 
 endlayout;

 
 layout overlay/wallDisplay=none  yaxisopts=(display=(tickvalue)
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=YCS0/ markercharacter=censored_s0;
 
 endlayout;

 layout overlay/wallDisplay=none  yaxisopts=(display=(tickvalue)
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=YES0/ markercharacter=events_s0;
 
 endlayout;


 layout overlay/wallDisplay=none  yaxisopts=(display=none
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=YAS0/ markercharacter=sepstrataname1 markercharacterattrs=(weight=bold);
 
 endlayout;
 
/*entry 'sepstrata=1';*/
 layout overlay/wallDisplay=none  yaxisopts=(display=(tickvalue)
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=yas1/ markercharacter=atrisk_s1;
 
 endlayout;

 
 layout overlay/wallDisplay=none yaxisopts=(display=(tickvalue)
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=ycs1/ markercharacter=censored_s1;
 
 endlayout;
 
 layout overlay/wallDisplay=none  yaxisopts=(display=(tickvalue)
 linearopts=(viewmin=1 viewmax=1))
 xaxisopts=(display=none);

scatterplot x=timelist y=yes1/ markercharacter=events_s1;
 
 endlayout;


 endlayout;
 endgraph;
 end;
run;
*Create data for plotting;
ods exclude all;
ods output survivalplot=plotdata;
 proc lifetest data=pplf notable plots=survival(cb=hw test atrisk);
time duration*event(0);
strata sepstrata;
run;
/**/

/*Removing Confidence band from last event onwards to match the direct proc lifetest output*/
proc sql;
select max(time) into:a0 from plotdata where stratum='0' and event>0;
quit;

proc sql;
select max(time) into:a1 from plotdata where stratum='1' and event>0;
quit;


data plotdata;
set plotdata;
if missing(survival) then survival=censored;
if time= 0 and missing(survival) then survival=1;
if survival=1 then do;
hw_lcl=1;hw_ucl=1;
end;
run;



proc sort data=plotdata;
by stratum time;
run;

data plotdatafin;
set plotdata;
by stratum time;
retain _hw_lcl;
if not missing(hw_lcl) then _hw_lcl=hw_lcl;
else hw_lcl=_hw_lcl;
drop _hw_lcl;

retain _hw_ucl;
if not missing(hw_ucl) then _hw_ucl=hw_ucl;
else hw_ucl=_hw_ucl;
drop _hw_ucl;
if missing(survival) then do;
hw_lcl=.;hw_ucl=.;end;
if stratum=0 and time>&a0. then do;
hw_lcl=.;hw_ucl=.;end;
if stratum=1 and time>&a1. then do;
hw_lcl=.;hw_ucl=.;end;

run;


proc sort data=plotdatafin;
by Stratum time;
run;


/*manipulation of lower confidence band at timepoint at last event point*/

data plotdatafin;
set plotdatafin;
joincode=_n_;
ykaval=1;
yas0="At Risk";
yas1="At Risk";
yes0="Events";
yes1="Events";

ycs0="Censored";
ycs1="Censored";
if joincode=1 then sepstrataname0='Non Sepstrata';
if joincode=1 then sepstrataname1='Sepstrata';
hw_lcl_lag=lag(hw_lcl);
if stratum=0 and time=&a0. then hw_lcl=hw_lcl_lag;
if stratum=1 and time=&a1. then hw_lcl=hw_lcl_lag;
if stratum=0 and time>&a0. then survival=.;
if stratum=1 and time>&a1. then survival=.;
run;

data finaloverall;
merge plotdatafin survivald;
by joincode;
run;


title "KM-Plot Overall Data N=&ntotal. ";
footnote '';
ods rtf file='T:\abhattacharya\example_KM_Plot.rtf';
ods select all;
*Use the procedure for printing the template;
proc sgrender data=finaloverall template=kmplot;
format stratum $a.;
run; 


ods rtf close;
