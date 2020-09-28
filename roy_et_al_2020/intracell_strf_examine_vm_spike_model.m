function [fr, v, timepoints] = intracell_strf_examine_vm_spike_model(app, sharpprobe, stimprobe, ndi_spike_element, ndi_vm_element, ndi_vm_corrected_element, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_EXAMINE_VM_SPIKE_MODEL(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% displayresults (1)         | Display the results (0/1)
%

% CALL THIS, but need [stim_onset_time stim_offset_time stimid]

displayresults = 1;

vlt.data.assign(varargin{:});

E = app.session;

et = epochtable(sharpprobe);
N = numel(et);

iapp = ndi_app(E,'vhlab_voltage2firingrate');
gapp = ndi_app_markgarbage(E);

% need to do many elements
% pull out firing rate and vm observations
% need to do an empirical plot (sliding average) of the relationship overall
% need to do the same for each epoch to make sure they do not differ radically
% need to fit the relationship overall
% need to check the relationship with full stimuli


q_spikeratevmdoc = ndi_query('','isa','binnedspikeratevm.json','');  % old, legacy
q_elementid = ndi_query('','depends_on','element_id',sharpprobe.id());
q_fitcurvedoc = ndi_query('','isa','fitcurve.json','');
q_lt = ndi_query('fitcurve.fit_name','exact_string','linethreshold','');
q_lpt = ndi_query('fitcurve.fit_name','exact_string', 'vlt.fit.linepowerthreshold','');
q_lpt0 = ndi_query('fitcurve.fit_name','exact_string','linepowerthreshold_0','');
q_tanh = ndi_query('fitcurve.fit_name','exact_string','vlt.fit.tanhfitoffset','');



for n=1:N,
    
	isdirectionepoch = 0;
	    
	[data,t_raw,timeref] = readtimeseries(sharpprobe, et(n).epoch_id, 0, 1);
	    
	vi = gapp.loadvalidinterval(sharpprobe);
	interval = gapp.identifyvalidintervals(sharpprobe,timeref,0,Inf)
	    
	[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,interval(1,1),interval(1,2));
	stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];
	    
	isblank = vlt.data.structfindfield(ds.parameters,'isblank',1);
	notblank = setdiff(1:numel(ds.parameters),isblank);
	if vlt.data.eqlen(vlt.data.structwhatvaries(ds.parameters(notblank)),{'angle'})
		isdirectionepoch = 1;
	end;
	    
	if isdirectionepoch,
		
		tF = ds.parameters{1}.tFrequency;

		q_epochid = ndi_query('epochid','exact_string',et(n).epoch_id,'');
		
		spikeratevmdoc = E.database_search(q_spikeratevmdoc & q_elementid & q_epochid);
		if ~isempty(spikeratevmdoc),
			spikeratevmdoc = vlt.data.celloritem(spikeratevmdoc,1);
			vlt.data.struct2var(spikeratevmdoc.document_properties.binnedspikeratevm);
		end;
		
		% Step 1: plot data and fits
		
		figure;
		
		subplot(2,2,1);
		
		intracell_strf_plotbinnedspikeratevm(app, sharpprobe, stimprobe,'epochid',et(n).epoch_id);
		hold on;
		
		q_probeepoch = q_elementid & q_epochid;

		linepowerthresh_doc = sharpprobe.session.database_search(q_fitcurvedoc & q_probeepoch & q_lpt);
		tanh_doc = sharpprobe.session.database_search(q_fitcurvedoc & q_probeepoch & q_tanh);

		plotintracellstrffitcurves(sharpprobe, et(n).epoch_id, E, 0);

		% Step 2: Plot responses to stimuli and model responses to stimuli:
		
		subplot(2,2,2);
		
		[mean_v, mean_fr, mean_stimid, stimpres, vmobs, frobs] = vlt.neuro.membrane.voltage_firingrate_observations_per_stimulus(voltage_observations, ...
				firingrate_observations, timepoints, stim_onsetoffsetid);
		
		notblank = find(mean_stimid~=max(mean_stimid));
		mean_v = mean_v(notblank);
		mean_fr = mean_fr(notblank);
		mean_stimid = mean_stimid(notblank);
		vmobs = vmobs(notblank);
		frobs = frobs(notblank);
		stimpres = stimpres(notblank);
		
		plot(mean_v,mean_fr,'ko');
		
		ylabel('Mean firing rate (spikes/sec)');
		xlabel('Mean voltage (V)');
		
		hold on;
		
		plotintracellstrffitcurves(sharpprobe,et(n).epoch_id, E, 0);
		
		% Step 3: Plot responses to stimuli and model responses with pulled tuning curves
		
		tapp = ndi_app_tuning_response(E);
		
		resps = {'mean','F1'};
		spike_resp_doc = {};
		spike_stim_doc = {};
		vm_resp_doc = {};
		vm_stim_doc = {};
		
		for i=1:numel(resps),
			[spike_resp_doc{i},spike_stim_doc{i}] = tapp.find_tuningcurve_document(ndi_spike_element,et(n).epoch_id,resps{i});
			[vm_resp_doc{i},vm_stim_doc{i}] = tapp.find_tuningcurve_document(ndi_vm_corrected_element,et(n).epoch_id,resps{i});
		end;
		
		% check alignment of stimuli and pull out ordered pairs
		
		vm_fr = {};

		pres_numbers = [];
		
		for i=1:numel(resps),
			vm_fr{i} = [];
			for j=1:numel(vm_resp_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number),
				if ~vlt.data.eqlen( vm_resp_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number{j},...
					spike_resp_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number{j}),
					error(['mismatch in stimulus presentation numbers in individidual response records.']);
				end;
				if i==1, pres_numbers = cat(1,pres_numbers,vlt.data.colvec(spike_resp_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number{j})); end;
				vm_resps_here = vm_resp_doc{i}{1}.document_properties.tuning_curve.individual_responses_real{j} + ...
					sqrt(-1)*vm_resp_doc{i}{1}.document_properties.tuning_curve.individual_responses_imaginary{j};
				vm_control_resps_here = vm_resp_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_real{j} + ...
					sqrt(-1)*vm_resp_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_imaginary{j};
				s_resps_here = spike_resp_doc{i}{1}.document_properties.tuning_curve.individual_responses_real{j} + ...
					sqrt(-1)*vm_resp_doc{i}{1}.document_properties.tuning_curve.individual_responses_imaginary{j};
				s_control_resps_here = spike_resp_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_real{j} + ...
					sqrt(-1)*vm_resp_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_imaginary{j};
				vm_fr{i} = cat(1,vm_fr{i},[ vlt.data.colvec(vm_resps_here-0*vm_control_resps_here) vlt.data.colvec(s_resps_here-0*s_control_resps_here) ]);
			end;
		end;
		
		hold on;
		
		h=plot(vm_fr{1}(:,1),vm_fr{1}(:,2),'go');
		
		
		[c,ia1,ib1] = intersect(stimpres,pres_numbers);
		% ib1 is the entry of pres_numbers that corresponds to c

		vm_generatedobs = {};

		% model a 2 second stimulus
		
		if ~isempty(linepowerthresh_doc)
		    
			vm_fr{3} = vm_fr{1};  % mean response to simulated full waveform
			vm_fr{4} = vm_fr{1};  % response to ??
			vm_fr{5} = vm_fr{1};  % response of ?? using thanh fit
			vm_fr{6} = vm_fr{1};  % response to actual voltage input passed through model
			vm_fr{7} = vm_fr{1};  % mean actual firing rate observations
		    
			for j=1:size(vm_fr{1},1),
				TT = 0:0.030:5;
				VV = vm_fr{1}(j,1) + real(vm_fr{2}(j,1))*cos(2*pi*tF*TT) - imag(vm_fr{2}(j,1)) * sin(2*pi*tF*TT);
				vm_fr{3}(j,2) = mean(ndi_evaluate_fitcurve(linepowerthresh_doc{1},VV));
				vm_fr{4}(j,2) = ndi_evaluate_fitcurve(linepowerthresh_doc{1},VV(1));
				vm_fr{5}(j,2) = ndi_evaluate_fitcurve(tanh_doc{1},VV(1));
				if ismember(pres_numbers(j),c),
					g = find(stimpres==pres_numbers(j));
					vm_fr{6}(j,2) = mean(ndi_evaluate_fitcurve(linepowerthresh_doc{1},vmobs{g}));
					vm_generatedobs{g} = VV;
					vm_fr{7}(j,1) = mean(frobs{g});
				else,
					vm_fr{6}(j,2) = nan;
					vm_fr{7}(j,1) = nan;
				end;
			end;
		else,
			error('no linepowerthresh fit');
		end;
		
		subplot(2,2,3);

		plot(vm_fr{3}(:,2),vm_fr{1}(:,2),'gx')
		hold on;
		plot(vm_fr{4}(:,2),vm_fr{1}(:,2),'bo');
		box off;
		ylabel('Actual spikes (mean)');
		xlabel('Predicted spikes');
		plot([0 25],[0 25],'k--');

		legend('F(V+V_{F1})','F(V_{mean})');

		subplot(2,2,4);

		plot(vm_fr{6}(:,2),vm_fr{1}(:,2),'kx')
		hold on;
		box off;
		ylabel('Actual spikes (mean)');
		xlabel('Predicted spikes');
		plot([0 25],[0 25],'k--');
		axis([0 25 0 25]);

		legend('F(V_{actual})');

		fig = figure;

		for j=1:size(vm_fr{1},1),
			if ismember(pres_numbers(j),c),
				g = find(stimpres==pres_numbers(j));
				ax = vlt.plot.supersubplot(fig,3,3,j);
				plot(0:0.030:(numel(vmobs{g})-1)*0.030, vmobs{g},'b');
				hold on;
				plot(TT, vm_generatedobs{g},'k');
				f1here = vlt.math.fouriercoeffs_tf2(vmobs{g},tF,1/0.030);
				mnhere = mean(vmobs{g});
				VV2 = mnhere + real(f1here)*cos(2*pi*tF*TT)-imag(f1here)*sin(2*pi*tF*TT);
				plot(TT,VV2,'g');
				box off;
			end;
		end;
		
	end; % if isdirection
end; % loop over epochs

end % function

function plotintracellstrffitcurves(sharpprobe, epochid, E, doglobal)

if nargin<4,
    doglobal = 0;
end;


 % TODO editing here
 
global fit_curves_global
fittypes = {'linethreshold','vlt.fit.linepowerthreshold','vlt.fit.tanhfitoffset','linepowerthreshold_0'};
colors = {'y','m','g','k'};
voltages = -0.100:0.001:0.050;
q_fitcurvedoc = ndi_query('','isa','fitcurve.json','');
q_elementid = ndi_query('','depends_on','element_id',sharpprobe.id());
q_epochid = ndi_query('epochid','exact_string',epochid,'');

for i=1:numel(fittypes),
	q_variable = ndi_query('fitcurve.fit_name','exact_string',fittypes{i},'');
	fitdoc = sharpprobe.session.database_search(q_fitcurvedoc & q_epochid & q_elementid & q_variable);
    
	if ~isempty(fitdoc),
		fitdoc = vlt.data.celloritem(fitdoc,1);
		fr = ndi_evaluate_fitcurve(fitdoc,voltages);
		hold on;
		plot(voltages,fr,colors{i},'linewidth',2);
	end;
end;
box off;
axis([-0.010 0.050 -2 200]);

if doglobal,
	myfit_curves_global = vlt.data.var2struct('voltages','fr','fitdoc');
	myfit_curves_global.fittype = fittypes{i};
	myfit_curves_global.name = [sharpprobe.probestring '@' epochid];
	myfit_curves_global.reference = E.id();
    
	if isempty(fit_curves_global),
		fit_curves_global = myfit_curves_global;
	else,
		fit_curves_global(end+1) = myfit_curves_global;
	end;
end;

end % function
