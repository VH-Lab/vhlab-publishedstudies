function d = import_spikes(S, daqsys, ds, nameref, index)
% IMPORT_SPIKES - import spikes from the vhlab dirstruct environment into NDI
% 
% D = IMPORT_SPIKES(S, DAQSYS, DS, NAMEREF, INDEX)
%
% Crawls over the data and adds the spikes for the given nameref/index combination.
% 

d = [];

spikes_epoch = {};

E = getelements(S,'element.name',nameref.name,...
	'element.reference',nameref.ref);
if iscell(E) & numel(E)==1,
	E = E{1};
else,
	error(['No such element ' nameref.name ' | ' int2str(nameref.ref) '.']);
end;

et = epochtable(daqsys);

element_neuron = ndi.neuron(S,[E.name '_' int2str(index)],...
	E.reference,'spikes',E,0,[],[]);

matlab_ver = ver('MATLAB');
matlab_version = matlab_ver.Version;
app_struct = struct('name', 'vhlab_ndi_importer', 'version', '1', ...
	'url', 'https://github.com/VH-Lab/vhlab-published', ...
	'os', computer, 'os_version', '', 'interpreter', 'MATLAB', ...
	'interpreter_version', matlab_version);


T = gettests(ds, nameref.name, nameref.ref);
for t=1:numel(T),
	et_entry = find(strcmp(T{t},{et.epoch_id}));
	if isempty(et_entry),
		error(['Could not find match for epoch ' T{t} '.']);
	end;
	filename = fullfile(getpathname(ds),T{t},['spiketimes_0_' sprintf('%0.3d',index) '.txt'])
	if isfile(filename),
		disp(['Found spikes in epoch ' T{t} '...']);
		spikes_epoch{t} = load([filename]);
		element_neuron.addepoch(T{t},...
			ndi.time.clocktype('dev_local_time'),...
			et(et_entry).t0_t1{1}, spikes_epoch{t}(:),...
			ones(size(spikes_epoch{t}(:))) );
	end;
end;

