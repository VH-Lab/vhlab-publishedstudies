function [cells,cellnames]=analyzenormsurrstims(thedir, redoresponses, redoanalysis, plotit, saveit)
% ANALYZEKLDIRSTIMS - Perform direction fitting analysis for a KL training experiment
%
%  [CELLS,CELLNAMES]=ANALYZENORMSURRSTIMS(THEDIR, REDORESPONSES, REDOANALYSIS,...
%    PLOTIT, SAVEIT)
%
%  Analyses data from the experiment in directory THEDIR.
%  Inputs:
%  DORESPONSES - If is 1, then the raw responses are re-extracted
%  REDOANALSYS - If is 1, then fits are performed
%  PLOTIT - If is 1, then a plot is made for each extraction or fit
%  SAVEIT - If 1, the extractions/fit results are saved to the experiment.mat file

ds = dirstruct(thedir);

[prefix,fname] = fileparts(thedir);
[cells,cellnames,experind] = readcellsfromexperimentlist(prefix,{fname},0,5);
cells = add_associate_variables(ds,cells); % add the associates in associate_variables.txt file

allcellnames = cellnames;

disp(['Cells we have now:']);
cellnames',

pause(5);

if redoresponses,  % extract responses
    for i=1:length(cells),
	disp(['Cellname is ' cellnames{i} '.']);
	cells{i}=extractstimdirectorytimes(ds, cells{i},'ErrorIfEmpty',1,'EarlyMorningCutOffTime',7); % add time information to all directories

if 1,

        myassoc=findassociate(cells{i},'CoarseDir test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'angle', plotit);
                cells{i}=associate(cells{i},struct('type','CoarseDir resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'SpatFreq test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'sFrequency', plotit);
                cells{i}=associate(cells{i},struct('type','SpatFreq resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'TempFreq test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'tFrequency', plotit);
                cells{i}=associate(cells{i},struct('type','TempFreq resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'Contrast test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'contrast', plotit);
                cells{i}=associate(cells{i},struct('type','Contrast resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'LengthWidthC test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'length', plotit);
                cells{i}=associate(cells{i},struct('type','LengthWidthC resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'LengthWidthCA test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'length', plotit);
                cells{i}=associate(cells{i},struct('type','LengthWidthCA resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'SurroundTune test','','');
        if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'surroundangle', plotit);
                cells{i}=associate(cells{i},struct('type','SurroundTune resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
	myassoc=findassociate(cells{i},'ContrastPlaid test','','');
	if ~isempty(myassoc),
		[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'stimnum', plotit,'stimnum');
		cells{i}=associate(cells{i},struct('type','ContrastPlaid resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;

end;
	if 0,
        	myassoc=findassociate(cells{i},'FlankTuningIsoOri test','','');
	        if ~isempty(myassoc),
	                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'flanklocori', plotit);
	                cells{i}=associate(cells{i},struct('type','FlankTuningIsoOri resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	        end;
	        myassoc=findassociate(cells{i},'FlankTuningOppOri test','','');
		if ~isempty(myassoc),
			[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'flanklocori', plotit);
			cells{i}=associate(cells{i},struct('type','FlankTuningIsoOri resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
		end;
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
	disp(['Now working on cell ' cellnames{i} ' (' int2str(i) ' of ' int2str(length(cells)) ')...']);

if 1,

	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'CoarseDir test'},'p.angle','otanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'CoarseDir test'},'p.angle','otanalysis_compute','SP F1','',1);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'CoarseDir test'},'p.angle','otanalysis_compute','SP F2','',2);

	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F1','',1);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F2','',2);

	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F1','',1);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F2','',2);

	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast test'},'p.contrast','ctanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast test'},'p.contrast','ctanalysis_compute','SP F1','',1);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast test'},'p.contrast','ctanalysis_compute','SP F2','',2);

	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SurroundTune test'},'p.surroundangle','otanalysis_compute','SP F0 SUR','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SurroundTune test'},'p.surroundangle','otanalysis_compute','SP F1 SUR','',1);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SurroundTune test'},'p.surroundangle','otanalysis_compute','SP F2 SUR','',2);

end;

    if 0,
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FlankTuningIsoOri test'},'p.flanklocori','otanalysis_compute','SP F0 FLANKISO','',0);
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FlankTuningIsoOri test'},'p.flanklocori','otanalysis_compute','SP F1 FLANKISO','',1);
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FlankTuningIsoOri test'},'p.flanklocori','otanalysis_compute','SP F2 FLANKISO','',2);

        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FlankTuningOppOri test'},'p.flanklocori','otanalysis_compute','SP F0 FLANKOPP','',0);
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FlankTuningOppOri test'},'p.flanklocori','otanalysis_compute','SP F1 FLANKOPP','',1);
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FlankTuningOppOri test'},'p.flanklocori','otanalysis_compute','SP F2 FLANKOPP','',2);
    end;
    
    end;
    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;
end;

