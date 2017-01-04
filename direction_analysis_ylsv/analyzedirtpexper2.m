function [cells,cellnames]=analyzedirtpexper(arg1,arg2,arg3)

%  ANALYZEDIRTPEXPER - Perform analysis for Ye Li / Steve Van Hooser exper
%
%  [CELLS,CELLNAMES]=ANALYZEDIRTPEXPER(DIRNAME,PLOTIT)
%                     or
%  [CELLS,CELLNAMES]=ANALYZEDIRTPEXPER(DBNAME,PARENTDIR,PLOTIT)
%
%     Performs basic analysis for ferret direction experiments.
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
%  In addition, the function calls dirtpexpersummary to print a summary of
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

r = input('Do you want to calculate/recalculate cell fits? (y/n)','s');

if strcmp(r,'y')|strcmp(r,'Y'),
  for i=1:length(cells),
	if isempty(dirname),
		mydsname = cellnames{i}((end-9):end); mydsname(find(mydsname=='_'))='-';
		if ~strcmp(mydsname,lastds),
			ds = dirstruct([fixpath(parentdir) mydsname]);
			lastds = mydsname;
		end;
	end;
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Best orientation test'},'p.angle','otanalysis_compute','TP','plottpresponse(newcell,cellname,''Orientation/Direction'',1,1,''usesig'',1)');	
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Best OT recovery test'},'p.angle','otanalysis_compute','TP ME','plottpresponse(newcell,cellname,''TP ME Ach OT Fit Pref'',1,1,''usesig'',1)');
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Best Flash OT recovery test'},'p.angle','otanalysis_compute','TP FE','plottpresponse(newcell,cellname,''TP FE Ach OT Fit Pref'',1,1,''usesig'',1)');
	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Best phase test'},'p.sPhaseShift','phaseanalysis_compute','TP','plottpresponse(newcell,cellname,''Phase'',1,1,''usesig'',1)');
    cells{i} = tpdirtrainsig(ds,cells{i},cellnames{i},plotit);
	[cellnames{i} ', ' int2str(i) ],
  end;
end;

r = input('Do you want to save the cells back to the database? (y/n)','s');

if strcmp(r,'y')|strcmp(r,'Y'),
	%for i=1:length(cells),
	%	disp(['Saving ' cellnames{i} '.']);
		if nargin==2,
            disp(['Saving cells to database.']);
			saveexpvar(ds,cells,cellnames,0);
		else,
			disp(['Saving to maser database not implemented yet.']);
		end;
	%end;
else,
	disp(['Not saving per user request.']);
end;

dirtpexpsummary(cells,cellnames);
if 0,
r = input('Do you want to plot all stacks? (y/n)','s');
if strcmp(r,'y')|strcmp(r,'Y'),
	makedirexpsummaryplots(cells,ds);
	if ~isempty(ds), makepreviewtpplots(ds); end;
end;

r = input('Do you want to plot single condition maps? (y/n)','s');
if strcmp(r,'y')|strcmp(r,'Y'),
	if ~isempty(ds),
		makedirexpneuropilmaps(ds);
	end;
end;
end;