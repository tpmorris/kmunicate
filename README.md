# KMunicate-style Kaplan–Meier plots

This repository is intended to hold code to produce Kaplan–Meier plots in the style recommended following the [KMunicate study](http://dx.doi.org/10.1136/bmjopen-2019-030215) (TP Morris *et al*. Proposals on Kaplan–Meier plots in medical research and a survey of stakeholder views: KMunicate. *BMJ Open*, 2019, 9:e030215). An example is given at the bottom of this readme.

Since publication of the paper, many people have said 'I want to do those plots. Where is the code? The embarrassing answer is: I did the table as a one-off assuming nobody would like it – *who likes tables!*

I have written a Stata script (in the [Stata](Stata) directory) that I have adapted to a few people's real examples. A few people have tried – and struggled – in R. A few SAS users have shown interest but think it would be hard. I am interested in Stata, R and SAS implementations because the majority of serious clinical trialists use one of these packages.

# The challenge
I have launched a challenge [on twitter](https://twitter.com/tmorris_mrc) for people to produce a script or program that implements these. The winning prizes are wooden spoons I carved (see the twitter thread).

Ok, time for some criteria. Here is what a winner would need to produce:
* A figure similar to the one below that can be reproduced with data.
* The numbers in the table must align with the time points on the figure.
* The tables must be structured for each group (e.g. trial arm) with a row for 'at-risk', 'censored' and 'events' (see example below).
* Confidence intervals must be translucent so that two or more can be seen when they sit on top of each other.
* This must be showcased with a publicly-available dataset.
* The result must be reproduced.
* One winner for each of Stata, R and SAS.
* The Stata prize is harder: I have already produced a script. You have to produce a general program as an ado file. (I would also prefer this for R and SAS but beggars can't be choosers.)

The fastest person gets to choose their spoon and second and third choose from the remainder (you don't have to take one). The competition will close on 1st September 2020 because beyond then I might forget and sell them on Etsy.

![Winner](winner.png?raw=true)
