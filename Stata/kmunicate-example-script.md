# The KMunicate example script

The file kmunicate-example-script.do gives one example of how to make KMunicate style figures using Stata (see [README](..\README.md)). The .do file itself gives detailed comments and this file aims to give an overview of the approach used. The confidence intervals are of course simple; all the effort is for producing the table.

## Approach for the table
Rather than creating a structured table (in the way that `forestplot` does for example), I simply use a trick with value labels: These can contain linebreaks. Sometimes this goes fine in a graph command and other times it fails. Fortunately axis labels inherit line breaks and so can have multiple rows for a single value label.

I use this to be able to create the table of numbers at-risk, censored and having an event at the labelled timepoints. So for example, the label for time 0 is
```
`" "0" " " " " "20" "0" "0" " " "14" "0" "0" " " "14" "0" "0" "'
```
Each of these numbers will be one row. The entries that contain a space are to create a blank 'cell' for that row at time 0.

This label is built up bit-by-bit by looping over each group being summarised and each time point to be displayed. Labels are modifiable, so this is simply added-to as we go.

## Bugs
There is an odd bug in `sts graph` when using the `ci` option and translucent confidence intervals: the option to remove the darker lines at the edges of the confidence intervals fails. This can be resolved using `recast(rarea)` but this produces a second bug: the legend text disappears. Stata tech support are aware and (I hope) working on it.
