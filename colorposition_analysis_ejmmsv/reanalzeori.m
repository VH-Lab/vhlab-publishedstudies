function reanalzeori(prefix,dirnames)

for j=1:length(dirnames),
	tpf = [ prefix filesep dirnames{j}];
	ds = dirstruct(tpf);
	
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	plotit=0;
	for i=1:length(cells),
		cellnames{i},
		cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'orientation test'},'p.angle','otanalysis_compute','TP','plottpresponse(newcell,cellname,''Orientation/Direction'',1,1,''usesig'',1)');
	%	cells{i} = tpposanalysis(ds,cells{i},cellnames{i},0*plotit);
	%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange test'},'i','colorexchangeanalysis_compute','TP','plottpresponse(newcell,cellname,''Color exchange'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
	%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange barrage test'},'i','colorbarrageanalysis_compute','TP','plottpresponse(newcell,cellname,''Color barrage'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
	%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'Color exchange Dacey-like test'},'i','colordaceyanalysis_compute','TP','plottpresponse(newcell,cellname,''Color barrage'',1,1,''usesig'',1,''dontclose'',0,''plotnonsig'',0)');
	%	cells{i} = tpcolorexchangeanalysis(ds,cells{i},cellnames{i},plotit);
	%	cells{i} = tpotadaptanalysis(ds,cells{i},cellnames{i},0*plotit);
	%	cells{i} = tpotrecoveryanalysis(ds,cells{i},cellnames{i},plotit);
	%	cells{i} = tpposadaptanalysis(ds,cells{i},cellnames{i},plotit);
	%	cells{i} = tpposrecoveryanalysis(ds,cells{i},cellnames{i},plotit);
	%	cells{i} = tpgenericanalysis(ds,cells{i},cellnames{i},plotit,{'SF test'},'p.sFrequency','sfanalysis_compute','TP','plottpresponse(newcell,cellname,''Spatial frequency'',1,1,''usesig'',1)');
		%cells{i} = tpadaptanalysis(ds,cells{i},cellnames{i},plotit);
		%cells{i} = tpiontophoresisanalysis(ds,cells{i},cellnames{i},plotit);
	  end;
	for i=1:length(cells),
		disp(['Saving ' cellnames{i} '.']);
		saveexpvar(ds,cells{i},cellnames{i},1);
	end;

end;

return;
r = input('Do you want to save the cells back to the database? (y/n)','s');

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
