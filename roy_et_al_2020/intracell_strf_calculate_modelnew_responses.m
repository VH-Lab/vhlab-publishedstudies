function [fr, v, timepoints] = intracell_strf_calculate_modelnew_responses(app, sharpprobe, stimprobe, ndi_spike_element, ndi_vm_element, ndi_vm_corrected_element, varargin)
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

assign(varargin{:});

E = app.session;

et = epochtable(sharpprobe);
N = numel(et);

iapp = ndi_app(E,'vhlab_voltage2firingrate');
gapp = ndi_app_markgarbage(E);

  % calculate model responses with actual Vm input
element_rawvm_fr_model_new_linepowerthresh = ndi_element_timeseries(E, sharpprobe.elementstring(), sharpprobe.reference, ...
	'RawVmFr_model_newF1attempt_linepowerthresh',sharpprobe,0);
E.database_rm(element_rawvm_fr_model_new_linepowerthresh.load_all_element_docs());
E.database_add(element_rawvm_fr_model_new_linepowerthresh.newdocument());

tapp = ndi_app_tuning_response(E);


for n=1:N,
    
	isdirectionepoch = 0;
	    
	[data,t_raw,timeref] = readtimeseries(sharpprobe, et(n).epoch_id, 0, 1);
	    
	vi = gapp.loadvalidinterval(sharpprobe);
	interval = gapp.identifyvalidintervals(sharpprobe,timeref,0,Inf);
	    
	[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,interval(1,1),interval(1,2));
	stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];
	    
	isblank = structfindfield(ds.parameters,'isblank',1);
	notblank = setdiff(1:numel(ds.parameters),isblank);
	if eqlen(structwhatvaries(ds.parameters(notblank)),{'angle'})
		isdirectionepoch = 1;
	end;
	    
	if isdirectionepoch,

		tF = ds.parameters{1}.tFrequency;
		linepowerthresh_doc = E.database_search(ndi_query('','isa','fitcurve.json','') & ...
			ndi_query('fitcurve.fit_name','exact_string','linepowerthreshold','') & ...
			ndi_query('','depends_on','element_id',sharpprobe.id()) & ...
			ndi_query('epochid','exact_string',et(n).epoch_id,''));

		[raw_vm, t, timeref_] = ndi_vm_corrected_element.readtimeseries(timeref, interval(1,1), interval(1,2));
		dt = t(2)-t(1);
		bin_samples = round(binwidth/dt); % size of the bins in terms of samples
		if ~mod(bin_samples,2), bin_samples = bin_samples+1; end; % make sure it is odd
		smoothed_vm = conv(raw_vm,ones(1,bin_samples)/bin_samples,'same');
		smoothed_vm = smoothed_vm(1:bin_samples:end);
		smoothed_t = t(1:bin_samples:end);
		rawfr = ndi_evaluate_fitcurve(linepowerthresh_doc{1},smoothed_vm);

		resps = {'mean','F1'};
                spike_resp_doc = {};
                spike_stim_doc = {};
                vm_resp_doc = {};
                vm_stim_doc = {};

                for i=1:numel(resps),
                        [spike_resp_doc{i},spike_stim_doc{i}] = tapp.find_tuningcurve_document(ndi_spike_element,et(n).epoch_id,resps{i})
                        [vm_resp_doc{i},vm_stim_doc{i}] = tapp.find_tuningcurve_document(ndi_vm_corrected_element,et(n).epoch_id,resps{i})
                end;

		figure;
		ax(1)=subplot(2,1,1);
		plot(t,raw_vm,'r');
		box off;
		ax(2)=subplot(2,1,2);
		plot(smoothed_t,rawfr,'b');
		xlabel('Time(s)');
		box off;
		linkaxes(ax,'x');

		% add element epochs
		element_rawvm_fr_model_new_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], smoothed_t(:), rawfr(:));

	else,
		[raw_vm, t, timeref_] = ndi_vm_corrected_element.readtimeseries(timeref, interval(1,1), interval(1,2));
		element_rawvm_fr_model_new_linepowerthresh.addepoch(timeref.epoch, timeref.clocktype, [interval(1,1) interval(1,2)], t(:), raw_vm(:));
	end; % if isdirection
end; % loop over epochs


