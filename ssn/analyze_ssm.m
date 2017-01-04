function [cells,cellnames]=analyze_ssm(thedir, redoresponses, redoanalysis, plotit, saveit)

ds = dirstruct(thedir);

[experiment_path, experiment_dir] = fileparts(thedir);
[cells,cellnames] = readcellsfromexperimentlist(experiment_path, {experiment_dir}, 1, 3);

if redoresponses,  % extract responses
    for i=1:length(cells),
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
end;
if 1,
        for j=0:1, % do both gaussian window and non-windowed
		cells{i} = responses_lengthtuning_contrast2(ds,cells{i},cellnames{i},j);
		cells{i} = responses_lengthtuning_contrastMLEDeNoise(ds,cells{i},cellnames{i},j);
		cells{i} = stimshape_lengthtuning_contrast(ds,cells{i},cellnames{i},j);
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
        disp(['Starting ' cellnames{i}])

if 1,
	disp(['   Orientation/direction...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'CoarseDir test'},'p.angle','otanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'CoarseDir test'},'p.angle','otanalysis_compute','SP F1','',1);

        disp(['   Spatial frequency...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SpatFreq test'},'p.sFrequency','sfanalysis_compute','SP F1','',1);

        disp(['   Temporal frequency...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F0','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'TempFreq test'},'p.tFrequency','tfanalysis_compute','SP F1','',1);
end;

if 0,

        disp(['   MLE gauss...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length MLE gauss resp'},'p.length','szanalysis_compute','SP F0 MLE gauss','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length MLE gauss resp'},'p.length','szanalysis_compute','SP F1 MLE gauss','',1);

        disp(['   MLE sharp...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length MLE sharp resp'},'p.length','szanalysis_compute','SP F0 MLE sharp','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length MLE sharp resp'},'p.length','szanalysis_compute','SP F1 MLE sharp','',1);

end;
 

if 0,
        disp(['   gauss...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length gauss resp'},'p.length','szanalysis_compute','SP F0 gauss','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length gauss resp'},'p.length','szanalysis_compute','SP F1 gauss','',1);

        disp(['   sharp...'])
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length sharp resp'},'p.length','szanalysis_compute','SP F0 sharp','',0);
	cells{i} = spperiodicgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Contrast/length sharp resp'},'p.length','szanalysis_compute','SP F1 sharp','',1);
end;

    end;
    if saveit,
	saveexpvar(ds,cells,cellnames);
    else,
	disp(['Not saving per user request.']);
    end;
end;
