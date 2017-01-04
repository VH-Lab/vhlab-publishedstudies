function [cells,cellnames]=analyzetftraining(thedir, redoresponses, redoanalysis, plotit, saveit)
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
%cellinfo = read_unitquality(ds); % not needed since we're not importing from plexon
%[cells,cellnames]=filter_by_quality(ds,cells,cellnames,cellinfo); % limit by cell quality

[cells,cellnames] = filter_by_index(cells,cellnames,50,75); % only get VH lab sorted spikes

disp(['Cells we have now:']);
cellnames,

pause(5);

[dirtestnamelist,velocitytestnamelist,tftrainingtestnamelist] = vhdirectiontrainingtypes(1);

training_assoc = read_trainingtype(ds,'ErrorIfNoTrainingType',1,'ErrorIfNoTrainingAngle',1,...
		'ErrorIfNoTF',1);

if redoresponses,  % extract responses
    for i=1:length(cells),
	disp(['Now analyzing cell ... ' cellnames{i} ', (' int2str(i) ' of ' int2str(length(cells)) ')']);
	for j=1:length(training_assoc), cells{i} = associate(cells{i},training_assoc(j)); end;
	cells{i}=extractstimdirectorytimes(ds, cells{i},'ErrorIfEmpty',1,'EarlyMorningCutOffTime',7); % add time information to all directories
	cells{i}=performsingleunitgrating(ds,cells{i},cellnames{i},dirtestnamelist,'angle',plotit);
	cells{i}=performsingleunitgrating(ds,cells{i},cellnames{i},velocitytestnamelist,'tFrequency',plotit);
	cells{i}=performsingleunitgrating(ds,cells{i},cellnames{i},tftrainingtestnamelist,'stimnumber',plotit);

	% need modified function for velocity
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
	cells{i} = performspperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,dirtestnamelist,'p.angle',...
		'otanalysis_compute','',3);
	% need additional functions for tftraining, velocity
        
    end;
    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;
end;

