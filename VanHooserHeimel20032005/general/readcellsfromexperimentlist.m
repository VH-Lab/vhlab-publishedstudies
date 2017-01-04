function [cells,cellnames,experind] = readcellsfromexperimentlist(prefix, expernames,vb, t)

% READCELLSFROMEXPERIMENTLIST - Loop through a list of experiments, reading in all cells
%
%   [CELLS,CELLNAMES,EXPERIND] = READCELLSFROMEXPERIMENTLIST(PREFIX,EXPERNAMES)
%    or 
%   [CELLS,CELLNAMES,EXPERIND] = READCELLSFROMEXPERIMENTLIST(PREFIX,EXPERNAMES, VERBOSE)
%    or 
%   [CELLS,CELLNAMES,EXPERIND] = READCELLSFROMEXPERIMENTLIST(PREFIX,EXPERNAMES, VERBOSE, THRESHOLD)
%
%  This function will loop through a list of experiments, extracting all cells.
%  The list of cell data structures and cellname strings will be returned in 
%  CELLS and CELLNAMES. EXPERIND is an array with the index number of the
%  experiment for each cell.
%
%  PREFIX should be the directory where the experiments reside (e.g., 
%  '/Volumes/Data1/mystudydir/'
%
%  and EXPERNAMES should be a cell list of example experiments (e.g., 
%  {'2011-01-01','2011-01-02','2011-01-03'}
%
%  If VERBOSE is present and is 1, then a message will be print upon reading
%  cells from each experiment.
%
%  If THRESHOLD is present and is a number, only cells with number of associates
%  greater than THRESHOLD will be included in what is returned.
%
%  See also: LOAD, LOAD2CELLLIST
%  

v = 0;
th = -Inf;

if nargin>2, v = vb; end;

if nargin>3, th = t; end;

cells = {}; cellnames = {}; experind = [];

for i=1:length(expernames),
	if v == 1, disp(['Now reading cells from ' expernames{i} '.']); end;
	ds = dirstruct([prefix filesep expernames{i}]);
	[newcells,newcellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	if th > -Inf,
		include = [];
		for j=1:length(newcells),
			A=findassociate(newcells{j},'','','');
			if length(A)>th,
				include(end+1) = j;
			end;
		end;
		newcells = newcells(include);
		newcellnames = newcellnames(include);
	end;
	cells = cat(2,cells,newcells);
	cellnames = cat(2,cellnames,newcellnames');
	experind = cat(1,experind,i*ones(length(newcells),1));
end;

