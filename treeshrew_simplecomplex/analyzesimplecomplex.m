function [cells,cellnames]=analyzesimplecomplex(thedir, redoresponses, redoanalysis, plotit, saveit)

ds = dirstruct(thedir);

[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');

if redoresponses,  % extract responses
    for i=1:length(cells),
if 0,
        myassoc=findassociate(cells{i},'Line test','','');
        if ~isempty(myassoc),
            [dummy,dummy,co]=singleunitlineweight(ds, cells{i}, cellnames{i}, myassoc.data, 'linenumber', plotit);
            cells{i}=associate(cells{i},struct('type','Line resp','owner','lineweightsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'dacey test','','');
        if ~isempty(myassoc),
            [dummy,dummy,co]=singleunitlineweight(ds, cells{i}, cellnames{i}, myassoc.data, 'stimnum', plotit);
            cells{i}=associate(cells{i},struct('type','dacey resp','owner','daceyrevcorrsheetlet','data',make_resp_from_output(co),'desc',''));
        end;
        myassoc=findassociate(cells{i},'barori test','','');
        if ~isempty(myassoc),
            [dummy,dummy,co]=singleunitlineweight(ds, cells{i}, cellnames{i}, myassoc.data, 'angle', plotit);
            cells{i}=associate(cells{i},struct('type','barori resp','owner','barorisheetlet','data',make_resp_from_output(co),'desc',''));
        end;
	myassoc=findassociate(cells{i},'CoarseDir test','','');
	if ~isempty(myassoc),
		[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'angle', plotit);
		cells{i}=associate(cells{i},struct('type','CoarseDir resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;
	myassoc=findassociate(cells{i},'FineDir test','','');
	if ~isempty(myassoc),
                [dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'angle', plotit);
                cells{i}=associate(cells{i},struct('type','FineDir resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;
	myassoc=findassociate(cells{i},'SpatFreq test','','');
	if ~isempty(myassoc),
		[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'sFrequency', plotit);
		cells{i}=associate(cells{i},struct('type','SpatFreq resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;
end; % if 0    
if 1,
	disp('HERE HERE');
	myassoc=findassociate(cells{i},'TempFreq test','','');
	if ~isempty(myassoc),
		[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'tFrequency', plotit);
		cells{i}=associate(cells{i},struct('type','TempFreq resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;
end;
if 0,
	myassoc=findassociate(cells{i},'Contrast test','','');
	if ~isempty(myassoc),
		[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'contrast', plotit);
		cells{i}=associate(cells{i},struct('type','Contrast resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;
end;
if 0,
	myassoc=findassociate(cells{i},'SpatPhase test','','');
	if ~isempty(myassoc),
		[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds, cells{i}, cellnames{i}, myassoc.data, 'sPhaseShift', plotit);
		cells{i}=associate(cells{i},struct('type','SpatPhase resp','owner','gratingsheetlet','data',make_resp_from_output(co),'desc',''));
	end;
end; % if 0
    end;

    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;
end;

if redoanalysis,
    for i=1:length(cells),
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FineDir test'},'p.angle','otanalysis_compute','SP F0','',0);
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FineDir test'},'p.angle','otanalysis_compute','SP F1','',1);
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'FineDir test'},'p.angle','otanalysis_compute','SP F2','',2);

        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F0','',0);
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F1','',1);
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F2','',2);

        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F0','',0);
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F1','',1);
        cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F2','',2);
 
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast test'},'p.contrast','ctanalysis_compute','SP F0','',0);
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast test'},'p.contrast','ctanalysis_compute','SP F1','',1);
        %cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast test'},'p.contrast','ctanalysis_compute','SP F2','',2);
 
        %cells{i} = sptuningcurveanalysis(ds,cells{i},cellnames{i},plotit,{'dacey test'},'p.stimnum','daceyrevcorranalysis_compute','SP F0','');
        %cells{i} = sptuningcurveanalysis(ds,cells{i},cellnames{i},plotit,{'Line test'},'sqrt( (mean(p.rect([1 3]))-mean(p1.rect([1 3]))).^2+(mean(p.rect([2 4]))-mean(p1.rect([2 4]))).^2)/20','lineweight_compute','SP F0','');
        cellnames{i}
        
    end;
    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;
end;
