function ephys(S)
% EPHYS - import an electrophysiology experiment from old VH lab dirstruct
%
% EPHS(S)
%
% Given an ndi.session object S that also sits at a electrophysiology experiment
% directory that can be managed by DIRSTRUCT, import all information from the 
% DIRSTRUCT records into S.
%
% 

p = S.getprobes();

ds = dirstruct(S.getpath());

[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');

N = [];

for i=1:numel(cells),
	N(i) = numel(findassociate(cells{i},'','',''));
end;

vhspike2 = S.daqsystem_load('name','vhspike2');

p = S.getprobes('type','stimulator');

decoder = ndi.app.stimulus.decoder(S);
decoder.parse_stimuli(p{1},1);

rapp = ndi.app.stimulus.tuning_response(S);
cs_doc = rapp.label_control_stimuli(p{1},1);


for i=1:numel(cells),
	if N(i)>20, % make sure we have some associates

		[nameref,index,datestr] = cellname2nameref(cellnames{i});

		% if we have a cell in the experiment file, it should be imported into NDI. It doesn't
		% mean the data is "good" but it means the data has a good chance of being good; that is,
		% it was properly collected. There may be other reasons to exclude it, such as poor response

		% Step 1, import the spikes for each epoch

		d = vlt.dirstruct2ndi.import_spikes(S, vhspike2, ds, nameref, index);

	end;
end;


