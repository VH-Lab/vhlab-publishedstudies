function [cells,cellnames]=analyzecptpexper(arg1,arg2,arg3)

%  ANALYZECPTPEXPER - Perform analysis for Zab / Mark / Steve exp
%
%  [CELLS,CELLNAMES]=ANALYZECPTPEXPER(DIRNAME,PLOTIT)
%                     or
%  [CELLS,CELLNAMES]=ANALYZECPTPEXPER(DBNAME,PARENTDIR,PLOTIT)
%
%     Performs basic analysis for tree shrew two-photon experiments.
%
%  DIRNAME is the name of the experiment directory or the name
%     Example:  DIRNAME = 'C:\Users\fitz_lab\2006-06-12'
%
%  It is also possible to pass a database filename as DBNAME and
%     provide a parent directory that contains data for all of the
%     experiments referenced in the database file.
%     Example: DBNAME = 'C:\Users\Me\mydb' and
%              PARENTDIR='C:\Users\fitz_lab\'
%
%  PLOTIT is 0/1 depending upon if fits and other results should be
%     plotted.
%
%  This function will take a long time if the data have not already been
%     analyzed in ANALYZETPSTACK.
%  The function will prompt the user if he/she wants to save the results
%     of the analysis back into the database.
%  
%  In addition, the function calls cptpexpersummary to print a summary of
%     of the cells in this file.
% 
%  Returns a list of MEASUREDDATA objects in CELLS and a cell list of strings
%  containing the cell names in CELLNAMES.
% 

if nargin==2,
	dirname = arg1; plotit = arg2;
elseif nargin==3,
	dirname=''; filename = arg1; parentdir = arg2; plotit = arg3;
end;

if ~isempty(dirname), ds = dirstruct(dirname); filename = getexperimentfile(ds); else, ds = []; end;

if ~isempty(ds),
	[cells,cellnames] = tpdoresponseanalysis(ds);
else,
	[cells,cellnames]=load2celllist(filename,'cell*','-mat');
end;

lastds = '';

%r = input('Do you want to calculate/recalculate cell fits? (y/n)','s');
r = 'y';

if strcmp(r,'y')|strcmp(r,'Y'),
  for i=1:length(cells),
	if isempty(dirname),
		mydsname = cellnames{i}((end-9):end); mydsname(find(mydsname=='_'))='-';
		if ~strcmp(mydsname,lastds),
			ds = dirstruct([fixpath(parentdir) mydsname]);
			lastds = mydsname;
		end;
	end;
	[cellnames{i} ', ' int2str(i) ],
%	cells{i} = tpotanalysis(ds,cells{i},cellnames{i},0*plotit);	
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'orientation test'},'p.angle','otanalysis_compute','TP','plottpresponse(newcell,cellname,''Orientation/Direction'',1,1,''usesig'',1)');
%	cells{i} = tpposanalysis(ds,cells{i},cellnames{i},0*plotit);
%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange test'},'i','colorexchangeanalysis_compute','TP','plottpresponse(newcell,cellname,''Color exchange'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange barrage test'},'i','colorbarrageanalysis_compute','TP','plottpresponse(newcell,cellname,''Color barrage'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange Dacey-like test'},'i','colordaceyanalysis_compute','TP','plottpresponse(newcell,cellname,''Color barrage'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange Dacey expanded test'},'i','colordaceyexpandedanalysis_compute','TP','plottpresponse(newcell,cellname,''Color barrage'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
%	cells{i} = tpcolorexchangeanalysis(ds,cells{i},cellnames{i},plotit);
%	cells{i} = tpotadaptanalysis(ds,cells{i},cellnames{i},0*plotit);
%	cells{i} = tpotrecoveryanalysis(ds,cells{i},cellnames{i},plotit);
%	cells{i} = tpposadaptanalysis(ds,cells{i},cellnames{i},plotit);
%	cells{i} = tpposrecoveryanalysis(ds,cells{i},cellnames{i},plotit);
%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SF test'},'p.sFrequency','sfanalysis_compute','TP','plottpresponse(newcell,cellname,''Spatial frequency'',1,1,''usesig'',1)');
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TF test'},'p.tFrequency','tfanalysis_compute','TP','plottpresponse(newcell,cellname,''Temporal frequency'',1,1,''usesig'',1)');
	%cells{i} = tpadaptanalysis(ds,cells{i},cellnames{i},plotit);
	%cells{i} = tpiontophoresisanalysis(ds,cells{i},cellnames{i},plotit);
  end;
end;

%r = input('Do you want to save the cells back to the database? (y/n)','s');
r='y';

if strcmp(r,'y')|strcmp(r,'Y'),
	for i=1:length(cells),
		disp(['Saving ' cellnames{i} '.']);
		if nargin==2,
			saveexpvar(ds,cells{i},cellnames{i},1);
		else,
			disp(['Saving to maser database not implemented yet.']);
		end;
	end;
else,
	disp(['Not saving per user request.']);
end;

return;
cptpexpsummary(cells,cellnames);
