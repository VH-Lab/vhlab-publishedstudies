function [cells,cellnames]=analyzechr2vh(thedir, redoresponses, redoanalysis, plotit, saveit)
% ANALYZESCRAMBLED - Perform fitting analysis for a tftraining training experiment
%
%  [CELLS,CELLNAMES]=ANALYZETFTRAINING(THEDIR, REDORESPONSES, REDOANALYSIS,...
%    PLOTIT, SAVEIT)
%
%  Analyses data from the experiment in directory THEDIR.
%  Inputs:
%  DORESPONSES - If is 1, then the raw responses are re-extracted
%  REDOANALSYS - If is 1, then fits are performed
%  PLOTIT - If is 1, then a plot is made for each extraction or fit
%  SAVEIT - If 1, the extractions/fit results are saved to the experiment.mat file

ds = dirstruct(thedir);

[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');

allcellnames = cellnames;

[dummy,cells] = add_testdir_info(ds,cells); % add the directory information
cellinfo = read_unitquality(ds);
   %cellinfo.ref = 3; cellinfo.index = 201;  % cheap hack for 2012-09-27
   %cellinfo(1).ref = 1; cellinfo(1).index = 151;  % cheap hack for 2014-07-27
   %cellinfo(2).ref = 1; cellinfo(2).index = 152;  % cheap hack for 2014-07-27
[cells,cellnames]=filter_by_quality(ds,cells,cellnames,cellinfo); % limit by cell quality

[cells,cellnames] = filter_by_index(cells,cellnames,050,475); % only get Plexon lab sorted spikes

try,
	[cells] = add_associate_variables(ds,cells);
catch,
	warning(['No associate variables from associate_variables.txt added.']);
end;

disp(['Cells we have now:']);
cellnames,

pause(5);

gst = vhgratingstimtypes(1);

training_assoc = read_trainingtype(ds,'ErrorIfNoTrainingType',0,'ErrorIfNoTrainingAngle',0,...
		'ErrorIfNoTF',0);

if redoresponses,  % extract responses
    for i=1:length(cells),
	disp(['Now analyzing cell ... ' cellnames{i} ', (' int2str(i) ' of ' int2str(length(cells)) ')']);
	for j=1:length(training_assoc), cells{i} = associate(cells{i},training_assoc(j)); end;
	cells{i}=extractstimdirectorytimes(ds, cells{i},'ErrorIfEmpty',1,'EarlyMorningCutOffTime',7); % add time information to all directories
	for j=1:length(gst),
		cells{i}=performsingleunitgrating(ds,cells{i},cellnames{i},{gst(j).type},gst(j).parameter,plotit);
	end;

    end;

    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;

end;

if redoanalysis,
    for i=1:length(cells),
	disp(['Now fitting cell ... ' cellnames{i} ', (' int2str(i) ' of ' int2str(length(cells)) ')']);
	for j=1:length(gst),
		if ~isempty(gst(j).periodicgenericanalysisfunc),
			cells{i} = performspperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{gst(j).type},gst(j).parameter,...
				gst(j).periodicgenericanalysisfunc,'',3);
		end;
        end;
    end;
    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;
end;

