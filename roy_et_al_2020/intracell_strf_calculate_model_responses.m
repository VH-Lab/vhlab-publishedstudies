function [fr, v, timepoints] = intracell_strf_calculate_model_responses(app, sharpprobe, stimprobe, ndi_spike_element, ndi_vm_element, ndi_vm_corrected_element, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_EXAMINE_VM_SPIKE_MODEL(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% displayresults (1)         | Display the results (0/1)
%

binwidth = 0.030;

displayresults = 1;

vlt.data.assign(varargin{:});

E = app.session;

et = epochtable(sharpprobe);
N = numel(et);

iapp = ndi.app(E,'vhlab_voltage2firingrate');
gapp = ndi.app.markgarbage(E);

  % calculate model responses with actual Vm input
element_rawvm_fr_model_linepowerthresh = ndi.element.timeseries(E, sharpprobe.elementstring(), sharpprobe.reference, ...
	'RawVmFr_model_selfconsistencycheck_linepowerthresh',sharpprobe,0);
E.database_rm(element_rawvm_fr_model_linepowerthresh.load_all_element_docs());
E.database_add(element_rawvm_fr_model_linepowerthresh.newdocument());

  % calculate membrane responses with simulated Vm input: F0 + F1 only
element_simvm_model_linepowerthresh = ndi.element.timeseries(E, sharpprobe.elementstring(), sharpprobe.reference, ...
	'SimVm_model_selfconsistencycheck_linepowerthresh',sharpprobe,0);
E.database_rm(element_simvm_model_linepowerthresh.load_all_element_docs());
element_simvm_model_linepowerthresh.newdocument(); % adds to database

  % calculate firing rate model responses with simulated Vm input: F0 + F1 only
element_simvm_fr_model_linepowerthresh = ndi.element.timeseries(E, sharpprobe.elementstring(), sharpprobe.reference, ...
	'SimVmFr_model_selfconsistencycheck_linepowerthresh',sharpprobe,0);
E.database_rm(element_simvm_fr_model_linepowerthresh.load_all_element_docs());
element_simvm_fr_model_linepowerthresh.newdocument(); % adds to database

tapp = ndi.app.stimulus.tuning_response(E);


for n=1:N,
    
	isdirectionepoch = 0;
	    
	[data,t_raw,timeref] = readtimeseries(sharpprobe, et(n).epoch_id, 0, 1);
	    
	vi = gapp.loadvalidinterval(sharpprobe);
	interval = gapp.identifyvalidintervals(sharpprobe,timeref,0,Inf);
	    
	[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,interval(1,1),interval(1,2));
	stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];
	    
	isblank = vlt.data.structfindfield(ds.parameters,'isblank',1);
	notblank = setdiff(1:numel(ds.parameters),isblank);
	if vlt.data.eqlen(vlt.data.structwhatvaries(ds.parameters(notblank)),{'angle'})
		isdirectionepoch = 1;
	end;
	    
	if isdirectionepoch,

		tF = ds.parameters{1}.tFrequency;
		linepowerthresh_doc = E.database_search(ndi.query('','isa','fitcurve.json','') & ...
			ndi.query('fitcurve.fit_name','exact_string','vlt.fit.linepowerthreshold','') & ...
			ndi.query('','depends_on','element_id',sharpprobe.id()) & ...
			ndi.query('epochid','exact_string',et(n).epoch_id,''));

		[raw_vm, t, timeref_] = ndi_vm_corrected_element.readtimeseries(timeref, interval(1,1), interval(1,2));
		dt = t(2)-t(1);
		bin_samples = round(binwidth/dt); % size of the bins in terms of samples
		if ~mod(bin_samples,2), bin_samples = bin_samples+1; end; % make sure it is odd
		smoothed_vm = conv(raw_vm,ones(1,bin_samples)/bin_samples,'same');
		smoothed_vm = smoothed_vm(1:bin_samples:end);
		smoothed_t = t(1:bin_samples:end);
		rawfr = ndi.data.evaluate_fitcurve(linepowerthresh_doc{1},smoothed_vm);

		resps = {'mean','F1'};
                spike_resp_doc = {};
                spike_stim_doc = {};
                vm_resp_doc = {};
                vm_stim_doc = {};

                for i=1:numel(resps),
                        [spike_resp_doc{i},spike_stim_doc{i}] = tapp.find_tuningcurve_document(ndi_spike_element,et(n).epoch_id,resps{i})
                        [vm_resp_doc{i},vm_stim_doc{i}] = tapp.find_tuningcurve_document(ndi_vm_corrected_element,et(n).epoch_id,resps{i})
                end;

		smoothed_vm_sim = zeros(size(smoothed_vm));

		for i=1:size(stim_onsetoffsetid,1), % mimic each stim by F0 and F1
			t_start_sample = vlt.data.findclosest(smoothed_t,stim_onsetoffsetid(i,1));
			t_stop_sample =  vlt.data.findclosest(smoothed_t,stim_onsetoffsetid(i,2));
			t_values = 0:binwidth:binwidth*(t_stop_sample-t_start_sample+1-1);
			stim_id_here = stim_onsetoffsetid(i,3);
			stim_id_lookup = find(vm_resp_doc{1}{1}.document_properties.tuning_curve.stimid==stim_id_here);
			if ~isempty(stim_id_lookup), % is it in this tuning curve? blank stimuli are not, for example 
				stim_presentation_example_number = sum(stim_onsetoffsetid(1:i,3)==stim_id_here);
				vm_f0 = vm_resp_doc{1}{1}.document_properties.tuning_curve.individual_responses_real{stim_id_lookup}(stim_presentation_example_number);
				vm_f1 = vm_resp_doc{2}{1}.document_properties.tuning_curve.individual_responses_real{stim_id_lookup}(stim_presentation_example_number) + ...
					sqrt(-1)*vm_resp_doc{2}{1}.document_properties.tuning_curve.individual_responses_imaginary{stim_id_lookup}(stim_presentation_example_number);
				smoothed_vm_sim(t_start_sample:t_stop_sample) = vm_f0 + real(vm_f1)*cos(2*pi*tF*t_values)-imag(vm_f1)*sin(2*pi*tF*t_values);
			end;
		end;

		simfr = ndi.data.evaluate_fitcurve(linepowerthresh_doc{1},smoothed_vm_sim);

		figure;
		ax(1)=subplot(2,1,1);
		plot(t,raw_vm,'r');
		hold on
		plot(smoothed_t,smoothed_vm,'b','linewidth',2);
		plot(smoothed_t,smoothed_vm_sim,'g','linewidth',1);
		box off;
		ax(2)=subplot(2,1,2);
		plot(smoothed_t,rawfr,'b');
		xlabel('Time(s)');
		box off;
		linkaxes(ax,'x');

		% add element epochs
		element_rawvm_fr_model_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], smoothed_t(:), rawfr(:));
		element_simvm_model_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], smoothed_t(:), smoothed_vm_sim(:));
		element_simvm_fr_model_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], smoothed_t(:), simfr(:));

	else,
		[raw_vm, t, timeref_] = ndi_vm_corrected_element.readtimeseries(timeref, interval(1,1), interval(1,2));
		element_rawvm_fr_model_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], t(:), raw_vm(:));
		element_simvm_model_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], t(:), raw_vm(:));
		element_simvm_fr_model_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], t(:), raw_vm(:));
	end; % if isdirection
end; % loop over epochs
