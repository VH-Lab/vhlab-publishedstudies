function intracell_strf_pipeline(expdir, varargin)
% INTRACELL_STRF_PIPELINE - perform the vm -> firing rate analysis
%
% INTRACELL_STRF_PIPELINE(EXPDIR, ...)
%
%
% This function's behavior is modified by extra parameters passed as name/value pairs.
% Parameter (default value)             | Description
% -------------------------------------------------------------------------------------
% setsharpthresholds (1)                | Perform the set sharp threshold analysis
% compute_binned_spike_rate_vm (1)      | Perform the calculation of the binned spike rates
% displayresults (1)                    | Should we display the results in plots?
% do_vm_fit (1)                         | Should we perform fits of FR = F(VM) ?
% examine_vm_fits (1)                   | Should we examine the results of the fits?
% extract_spikewaves (1)                | Should we extract spikewaves?
% analyze_spikewaves (1)                | Should we analyze spikewaves?
%
% See also: vlt.data.namevaluepair
%


setsharpthresholds = 1;
compute_binned_spike_rate_vm = 1;
plot_vm_firingrate = 1;
do_vm_fit = 1;
examine_vm_fit = 1;
displayresults = 1;
decode_stimuli = 1;
analyze_stimuli = 1;
extract_spikewaves = 1;
analyze_spikewaves = 1;
examine_residuals = 1;
plot_residuals = 1;
generate_sim_fit = 1;
analyze_fits = 1;

vlt.data.assign(varargin{:});

s=vlt.data.workspace2struct

[parentdir,expname] = fileparts(expdir)

E = ndi.setups.vhlab_expdir(expname, expdir);

 % if we have any stale element reference documents, delete them
d = ndi.database.fun.finddocs_missing_dependencies(E),
if ~isempty(d),
	keyboard;
end;
E.database_rm(d);

app = ndi.app(E, 'intracell_strf');

if setsharpthresholds, 
	intracell_strf_setsharpthresholds(app, E);
end;

if compute_binned_spike_rate_vm,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		intracell_strf_binnedspikeratevm(app, sharpprobes{i}, stimprobe{1},'displayresults',displayresults);
	end
end
  % now elements exist

if extract_spikewaves,
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		intracell_strf_extractspikewaves(app, sharpprobes{i}, 'displayresults',displayresults);
	end
end;

if decode_stimuli,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	else,
		disp('decoding');
		intracell_stimdecode(app, stimprobe{1});
		disp('done w/ stimulus decoding');
	end
end;

if analyze_stimuli,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end;
	myelements_spikes = getelements(E,'element.type','spikes');
	myelements_vm = getelements(E,'element.type','Vm_without_actionpotentials');
	myelements_vmc = getelements(E,'element.type','Vm_only_corrected');
	myelements = cat(2,myelements_spikes,myelements_vm,myelements_vmc)
	for i=1:numel(myelements), % for debugging, just look at the first one
		disp('analyzing stimulus responses');
		intracell_strf_dof0f1(app, stimprobe{1}, myelements{i});
		disp('done w/ stimulus analyzing');
	end;
end;

if plot_vm_firingrate,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		figure;
		intracell_strf_plotbinnedspikeratevm(app, sharpprobes{i}, stimprobe{1},'displayresults',displayresults);
	end
end
	
if do_vm_fit,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		intracell_strf_fitspikeratevm(app, sharpprobes{i}, stimprobe{1},'displayresults',displayresults);
	end
end

if generate_sim_fit,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		myelements_spikes = getelements(E,'element.type','spikes');
		myelements_vm = getelements(E,'element.type','Vm_without_actionpotentials');
		myelements_vm_corrected = getelements(E,'element.type','Vm_only_corrected');
		mts = 0;
		mtv = 0;
		mtvc = 0;
		for k=1:numel(myelements_spikes),
			if myelements_spikes{k}.underlying_element==sharpprobes{i}, mts = k; break; end;
		end;
		for k=1:numel(myelements_vm),
			if myelements_vm{k}.underlying_element==sharpprobes{i}, mtv = k; break; end;
		end;
		for k=1:numel(myelements_vm_corrected),
			if myelements_vm_corrected{k}.underlying_element==sharpprobes{i}, mtvc = k; break; end;
		end;
		if mts>0 & mtv > 0 & mtvc > 0,
			intracell_strf_calculate_model_responses(app, sharpprobes{i}, stimprobe{1},...
				myelements_spikes{mts}, myelements_vm{mtv}, myelements_vm_corrected{mtvc}, ...
				'displayresults',displayresults);
		end;
	end
end

if analyze_fits,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end;
	myelements_vmsmooth = getelements(E,'element.type','RawVmFr_model_selfconsistencycheck_linepowerthresh');
	myelements_vmsim = getelements(E,'element.type','SimVm_model_selfconsistencycheck_linepowerthresh');
	myelements_vmsimfr = getelements(E,'element.type','SimVmFr_model_selfconsistencycheck_linepowerthresh');
	myelements = cat(2,myelements_vmsmooth,myelements_vmsim,myelements_vmsimfr);
	for i=1:numel(myelements), 
		disp('analyzing stimulus responses');
		intracell_strf_dof0f1(app, stimprobe{1}, myelements{i});
		disp('done w/ stimulus analyzing');
	end;
end;

if examine_vm_fit,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		myelements_spikes = getelements(E,'element.type','spikes');
		myelements_vm = getelements(E,'element.type','Vm_without_actionpotentials');
		myelements_vm_corrected = getelements(E,'element.type','Vm_only_corrected');
		mts = 0;
		mtv = 0;
		mtvc = 0;
		for k=1:numel(myelements_spikes),
			if myelements_spikes{k}.underlying_element==sharpprobes{i}, mts = k; break; end;
		end;
		for k=1:numel(myelements_vm),
			if myelements_vm{k}.underlying_element==sharpprobes{i}, mtv = k; break; end;
		end;
		for k=1:numel(myelements_vm_corrected),
			if myelements_vm_corrected{k}.underlying_element==sharpprobes{i}, mtvc = k; break; end;
		end;
		if mts>0 & mtv > 0 & mtvc > 0,
			intracell_strf_examine_vm_spike_model(app, sharpprobes{i}, stimprobe{1},...
				myelements_spikes{mts}, myelements_vm{mtv}, myelements_vm_corrected{mtvc}, 'displayresults',displayresults);
		end;
	end
end

if examine_residuals,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		myelements_spikes = getelements(E,'element.type','spikes');
		myelements_vm = getelements(E,'element.type','Vm_without_actionpotentials');
		myelements_vm_corrected = getelements(E,'element.type','Vm_only_corrected');
		myelements_vmspikes_corrected = getelements(E,'element.type','Vm_corrected');
		mts = 0;
		mtv = 0;
		mtvc = 0;
		mtvsc = 0;
		for k=1:numel(myelements_spikes),
			if myelements_spikes{k}.underlying_element==sharpprobes{i}, mts = k; break; end;
		end;
		for k=1:numel(myelements_vm),
			if myelements_vm{k}.underlying_element==sharpprobes{i}, mtv = k; break; end;
		end;
		for k=1:numel(myelements_vm_corrected),
			if myelements_vm_corrected{k}.underlying_element==sharpprobes{i}, mtvc = k; break; end;
		end;
		for k=1:numel(myelements_vmspikes_corrected),
			if myelements_vmspikes_corrected{k}.underlying_element==sharpprobes{i}, mtvsc = k; break; end;
		end;
		if mts>0 & mtv > 0 & mtvc > 0 & mtvsc > 0,
			intracell_strf_residualanalysis(app, sharpprobes{i}, stimprobe{1},...
				myelements_spikes{mts}, myelements_vm{mtv}, myelements_vm_corrected{mtvc}, myelements_vmspikes_corrected{mtvsc}, ...
				'displayresults',displayresults);
		end;
	end
end

if plot_residuals,
	stimprobe = getprobes(E, 'name', 'vhvis_spike2', 'type', 'stimulator');
	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		myelements_spikes = getelements(E,'element.type','spikes');
		myelements_vm = getelements(E,'element.type','Vm_without_actionpotentials');
		myelements_vm_corrected = getelements(E,'element.type','Vm_only_corrected');
		myelements_vmspikes_corrected = getelements(E,'element.type','Vm_corrected');
		mts = 0;
		mtv = 0;
		mtvc = 0;
		mtvsc = 0;
		for k=1:numel(myelements_spikes),
			if myelements_spikes{k}.underlying_element==sharpprobes{i}, mts = k; break; end;
		end;
		for k=1:numel(myelements_vm),
			if myelements_vm{k}.underlying_element==sharpprobes{i}, mtv = k; break; end;
		end;
		for k=1:numel(myelements_vm_corrected),
			if myelements_vm_corrected{k}.underlying_element==sharpprobes{i}, mtvc = k; break; end;
		end;
		for k=1:numel(myelements_vmspikes_corrected),
			if myelements_vmspikes_corrected{k}.underlying_element==sharpprobes{i}, mtvsc = k; break; end;
		end;
		if mts>0 & mtv > 0 & mtvc > 0 & mtvsc > 0,
			intracell_strf_plotresidualanalysis(app, sharpprobes{i}, stimprobe{1},...
				myelements_spikes{mts}, myelements_vm{mtv}, myelements_vm_corrected{mtvc}, myelements_vmspikes_corrected{mtvsc}, ...
				'displayresults',displayresults);
		end;
	end
end

if analyze_spikewaves,
	sharpprobes = getprobes(E, 'type', 'sharp-Vm');

	for i=1:numel(sharpprobes),
		intracell_strf_analyzespikewaves(app, sharpprobes{i}, 'displayresults',displayresults);
	end
end;

 % if we have any stale element reference documents, delete them
d = ndi.database.fun.finddocs_missing_dependencies(E),
%E.database_rm(d);

