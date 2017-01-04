function [I,names] = matchcellnames(cellnames, name, ref, datestr)
% MATCHCELLNAMES - Identify which of a cell list of cellnames match a name/ref/date
%
%   [I,NAMES] = MATCHCELLNAMES(CELLNAMES, NAME, REF, DATESTR)
%
%   Searches the cell list of CELLNAMES for cells that
%   match the specified NAME, REF (reference number, an integer)
%   and DATESTR (should be in form '20YY-MM-DD', or '20YY_MM_DD').
%
%   The indexes of the cell list CELLNAMES that match are returned in
%   I.  The names are also returned in NAMES. NAMES = CELLNAMES(I)
%
%   See also:  NAMEREF2CELLNAME, CELLNAME2NAMEREF
%
%

I = [];

date(find(date=='-')) = '_';

datematches = strfind(cellnames,datestr);

subset = [];

for z=1:length(datematches),
	if ~isempty(datematches{z}), subset(end+1) = z; end;
end;

nameref.name = name; 
nameref.ref = ref;

for z=1:length(subset),
	nameref2 = cellname2nameref(cellnames{subset(z)});
	if nameref2==nameref,
		I(end+1) = subset(z);
	end;
end;

names = cellnames(I);

