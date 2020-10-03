function [fr, v, timepoints] = intracell_strf_binnedspikeratevm(app, sharpprobe, stimprobe, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_BINNEDSPIKERATEVM(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% binwidth (0.030)           | Bin width in seconds
% vm_baseline_correct        | Number of seconds to use to correct prestimulus baseline
%                            |   (passed to vlt.neuro.membrane.voltage_firingrate_observations)
% displayresults (1)         | Display the results (0/1)
%

 % CALL THIS, but need [stim_onset_time stim_offset_time stimid]

binwidth = 0.030;   % default value because used in Priebe Ferster 2005
vm_baseline_correct_init = 5;
vm_baseline_correct_func = 'vlt.math.prctile20';
displayresults = 1;

stimuli_to_include = 'all'; % or 'preferred_ori+/-3';

vlt.data.assign(varargin{:});

et = epochtable(sharpprobe);
N = numel(et);

E = app.session;

gapp = ndi.app.markgarbage(E);
iapp = ndi.app(E,'vhlab_voltage2firingrate');

  % clear the elements and setup for adding them
element_vmcorrected       = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference, 'Vm_corrected',sharpprobe,0);
element_vm_only_corrected = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference, 'Vm_only_corrected',sharpprobe,0);
element_subtractedvalue   = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference, 'Vm_correctionvalue',sharpprobe,0);
element_vmonly            = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference, 'Vm_without_actionpotentials',sharpprobe,0);
element_spikes            = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference, 'spikes',sharpprobe,0);

E.database_rm(element_vmonly.load_all_element_docs());
E.database_rm(element_vm_only_corrected.load_all_element_docs());
E.database_rm(element_spikes.load_all_element_docs());
E.database_rm(element_vmcorrected.load_all_element_docs());
E.database_rm(element_subtractedvalue.load_all_element_docs());

element_vmonly.newdocument();
element_spikes.newdocument();
element_subtractedvalue.newdocument();
element_vmcorrected.newdocument();
element_vm_only_corrected.newdocument();

q_projvardef = ndi.query(intracell_strf_projectvardef);
q_docname = ndi.query('ndi_document.name','exact_string','Epoch spike threshold','');
q_elementid = ndi.query('','depends_on','element_id',sharpprobe.id());

for n=1:N,

	vm_baseline_correct = vm_baseline_correct_init;

        q_epochid = ndi.query('epochid','exact_string',et(n).epoch_id,'');
        thresh_doc = E.database_search(q_elementid & q_projvardef & q_docname & q_epochid);
	if isempty(thresh_doc), keyboard; end

	[data,t_raw,timeref] = readtimeseries(sharpprobe, et(n).epoch_id, 0, 1);

	vi = gapp.loadvalidinterval(sharpprobe);
	interval = gapp.identifyvalidintervals(sharpprobe,timeref,0,Inf)

	[data,t_raw,timeref] = readtimeseries(sharpprobe, et(n).epoch_id, interval(1,1), interval(1,2));
	data = data / 10;  % 10 x gain
	thresh = thresh_doc{1}.document_properties.projectvar.data / 10; % 10 x gain

	si = t_raw(2)-t_raw(1);
	newsi = t_raw(2)-t_raw(1);
	medfiltwidth = round(0.008/newsi);
	refract = 0.0025;
	rm60Hz = 1;

	vmfilterparams = struct('new_sampling_rate',newsi, 'threshold', thresh', 'filter_algoritm', 'medfilt1', ...
		'filter_algorithm_parameters', struct('filter_algorithm_parameter_name', 'MedFilterWidth', ...
			'filter_algorithm_parameter_value', medfiltwidth), 'refract',refract,'rm60hz',rm60Hz);

	% remove old docs before we write new ones
	if 1,
		vmspikefilterparameters_q = ndi.query('','isa','vmspikefilteringparameters.json','') & ...
			q_elementid & q_epochid;
		vmspikefilterparameters_doc = E.database_search(vmspikefilterparameters_q);
		E.database_rm(vmspikefilterparameters_doc);
	end;

	vmspikefilterparameters_doc = E.newdocument('apps/vhlab_voltage2firingrate/vmspikefilteringparameters', ...
			'vmspikefilteringparameters',vmfilterparams,'epochid',et(n).epoch_id); 
	vmspikefilterparameters_doc = vmspikefilterparameters_doc.set_dependency_value('element_id',sharpprobe.id());
	E.database_add(vmspikefilterparameters_doc);

	[vm, t, spiketimes] = vlt.neuro.membrane.vmnospikes(data, si, 'Tstart', t_raw(1), 'newsi', newsi, ...
		'thresh', thresh, 'filter_algorithm', 'medfilt1','MedFilterWidth',medfiltwidth,'refract',refract,'rm60hz',rm60Hz);

	element_vmonly.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1), interval(1,2)], t(:), vm(:));
	element_spikes.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1), interval(1,2)], spiketimes(:), ones(size(spiketimes(:))));

	if displayresults,
		figure;
		plot(t_raw,data,'b');
		hold on;
		plot(t,vm,'g');
		xlabel('Time (s)');
		ylabel('Voltage (V)');
		%plot([spiketimes(:) spiketimes(:)],repmat([0 1],numel(spiketimes),1),'k-');
		title([sharpprobe.elementstring() '@' et(n).epoch_id  '; Blue is unfiltered, green is with spikes removed']);
	end

	[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,t(1),t(end));

	stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];

	isi = median(ts.stimon(2:end) - ts.stimoff(1:end-1)),

	if isi<vm_baseline_correct,
		vm_baseline_correct = isi;
		warning(['Baseline correct interval is too long, fixing']);
	end;

	if ~strcmpi(stimuli_to_include,'all'),
		disp('not including all stimuli, only a subset.');
		spikerates = vlt.neuro.spiketrains.spiketimes2bins(spiketimes,t) ./ (t(2)-t(1));
		[mean_v0,mean_fr0,mean_stimid0] = vlt.neuro.membrane.voltage_firingrate_observations_per_stimulus(vm, spikerates(:), t, stim_onsetoffsetid,'pretime',5);
		if isfield(ds.parameters{1},'tFrequency'),
			[mean_v1,mean_fr1,mean_stimid1] = vlt.neuro.membrane.voltage_firingrate_observations_per_stimulus(vm, spikerates(:), t, ds.stimid, ...
				stim_onsetoffsetid, 'pretime', 5, 'f1', ds.parameters{1}.tFrequency);
		else,
			mean_v1 = 0 * mean_v0;
			mean_fr1 = 0 * mean_fr0;
			f1 = [];
		end;
		stimshere = unique(mean_stimid0);
		for k=1:numel(stimshere)-1,
			indshere=find(mean_stimid0==stimshere(k));
			mean_tot(k) = mean(mean_v0(indshere)+mean_v1(indshere));
		end;
		[bestvalue,bestloc] = max(mean_tot);
		numrealstims = numel(stimshere)-1;
		included = mod([bestloc bestloc+1 bestloc-1 [bestloc bestloc+1 bestloc-1]+numrealstims/2], numrealstims);
		included(find(included==0)) = numrealstims;
		stim_onsetoffsetid = stim_onsetoffsetid(ismember(stim_onsetoffsetid(:,3),included), :);
		included,
		unique(stim_onsetoffsetid(:,3)),
	end;

	[v, fr, stimid, timepoints, vm_baselinecorrected, exactbintime] = vlt.neuro.membrane.voltage_firingrate_observations(t, vm, spiketimes, ...
		'stim_onsetoffsetid', stim_onsetoffsetid,'vm_baseline_correct',vm_baseline_correct,...
		'vm_baseline_correct_func',vm_baseline_correct_func,'binsize',binwidth);

	params = struct('binsize', binwidth, ...
		'vm_baseline_correction', 1, 'vm_baseline_correct_time', vm_baseline_correct,...
		'vm_baseline_correct_func', vm_baseline_correct_func, 'number_of_points', numel(v), 'stimuli_to_include', stimuli_to_include);

	mydoc = E.newdocument('apps/vhlab_voltage2firingrate/binnedspikeratevm', ...
		'binnedspikeratevm.parameters', params, 'binnedspikeratevm.voltage_observations', v, ...
		'binnedspikeratevm.firingrate_observations', fr, 'binnedspikeratevm.stimids', stimid, ...
		'binnedspikeratevm.timepoints', timepoints, 'binnedspikeratevm.exactbintimes', exactbintime, 'epochid', et(n).epoch_id);
	mydoc = mydoc.set_dependency_value('element_id',sharpprobe.id());
	mydoc = mydoc.set_dependency_value('vmspikefilteringparameters_id',vmspikefilterparameters_doc.id());

	olddoc =E.database_search(ndi.query('','isa','binnedspikeratevm.json','') & ...
		ndi.query('epochid','exact_string',et(n).epoch_id,'') & ...
		ndi.query('','depends_on','element_id',sharpprobe.id()));
	E.database_rm(olddoc);
	E.database_add(mydoc);

	if displayresults,
		figure('name','myname');
		intracell_strf_plotbinnedspikeratevm(app, sharpprobe, stimprobe, 'epochid', et(n).epoch_id);

		[h,htext] = vlt.neuro.membrane.plot_voltage_firingrate_observations(v, fr, stimid, timepoints, vm_baselinecorrected, t, vm, ...
			'stim_onsetoffsetid', stim_onsetoffsetid);
		thetitle = get(get(gca,'title'),'string');
		thetitle = { [sharpprobe.elementstring() '@' et(n).epoch_id], thetitle};
		title(thetitle);
	end

	% while we are here, add the corrected voltage element
	subtracted_value = vm(:)-vm_baselinecorrected(:);
	element_subtractedvalue.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1), interval(1,2)], t_raw(:), subtracted_value(:));
	
	element_vmcorrected.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1), interval(1,2)], t_raw(:), data(:)-subtracted_value(:));
	element_vm_only_corrected.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1), interval(1,2)], t(:), vm(:)-subtracted_value(:));

end

