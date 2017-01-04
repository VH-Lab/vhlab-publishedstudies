function [cells,cellnames] = vmcells(cells,cellnames)
% VMCELLS - filter out cells by max firing rate and voltage response
%
%  [CELLS,CELLNAMES] = VMCELLS(CELLS, CELLNAMES)
%
%  Returns only cells that have spiking greater than or equal to 1Hz
%  and a membrane potential response greater than 0.9mV.

goodcells = [];

for i=1:length(cells),
	A = findassociate(cells{i},'OTVM Max drifting grating voltage','',''),
	B = findassociate(cells{i},'OT Max drifting grating firing','',''),
	if ~isempty(B) & ~isempty(A),
		max(A.data), max(B.data),
		if max(A.data)>=0.0009 & max(B.data)>=1,
			goodcells(end+1) = i;
		end;
	end;
end;
   
cells = cells(goodcells);
cellnames = cellnames(goodcells);

