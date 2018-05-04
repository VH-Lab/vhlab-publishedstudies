function output=mo_plotcellinfo(cellinfo)
% MO_PLOTCELLINFO - plot information from cells
%
%  MO_PLOTCELLINFO(CELLINFO)
%
%  Plot CELLINFO that is returned from MO_DOANALYSIS
%
% 

output.oridir = mo_plotoridirtuning(cellinfo);
output.sftf = mo_plotsftftuning(cellinfo);
output.contrast = mo_plotcttuning(cellinfo);


