

[figs,ax]=plotallfits(5,5,cells,cellnames,['lineweightcellinclude(''SP F0 Ach'',0)'],['lineweightcellplot(''SP F0 Ach'',0)']);


1) The question we want answered:  Does the cell have separate ON/OFF subunits?

But, we cannot detect presence/absence of subunits in a statistically robust way (don't know how many, how to reject noise, etc)

2) A related quantity we can compute robustly:  How segregated are the ON/OFF responses?  

We can calculate the area of the white response and black response as the area under the response curves (AreaBlack AreaWhite).  Then, we can calculate the area that is overlapped (where white and black both respond), and calculate the normalized overlap:

NORMOVERLAP = OVERLAP / (AreaBlack + AreaWhite)

This will be 0 if black and white responses do not overlap at all, and 1 if they perfectly overlap.  To remove the effect of noise, let's consider any signal that is less than 1 SE to be 0 (that is, we will rectify above 1 SE of the responses).

Okay, how does this turn out in reality?
A) Cells that have highly overlapping responses DO, in fact, have high overlapping indexes (like 0.7 and higher) .
B) Cells that are strongly single sign or have separate "subunits" have lower values (like 0.5 or lower).
C) Cells that are strongly dominated by a single sign, but do NOT exhibit any subunit separation (e.g., page 3, row 1, columns 2, 3), have relatively low overlap index values.


