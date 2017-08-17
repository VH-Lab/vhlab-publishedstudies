function c = marjena_cellname2channel(cellname)
% MARJENA_CELLNAME2CHANNEL - Take a cell name and return the channel number
%
%   C = MARJENA_CELLNAME2CHANNEL(CELLNAME)
%
%   Returns the channel number given the cell name.
%
%   If CELLNAME is cell_extraX_001_4##_20##_##_##
%   the function returns X.  If there is no X present, X is 1.
%  

[nameref,index,datestr] = cellname2nameref(cellname);

c = sscanf(nameref.name,'extra%d');

if isempty(c),
	c = 1;
end;

