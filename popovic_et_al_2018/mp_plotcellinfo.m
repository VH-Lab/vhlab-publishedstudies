function output=mp_plotcellinfo(cellinfo)
% MP_PLOTCELLINFO - plot information from cells
%
%  MP_PLOTCELLINFO(CELLINFO)
%
%  Plot CELLINFO that is returned from MP_DONORMSURRANALYSIS
%
% 

output.lengthtuning = mp_plotlengthtuning(cellinfo);
output.oridir = mp_plotoridirtuning(cellinfo);
output.oridir2 = mp_plotoridirtuning2(cellinfo);
output.plaid= mp_plotplaidtuning(cellinfo);
output.sftf = mp_plotsftftuning(cellinfo);
output.contrast = mp_plotcttuning(cellinfo);
output.surr = mp_plotsuroridirtuning(cellinfo);


