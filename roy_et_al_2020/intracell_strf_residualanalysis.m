function intracell_strf_residualanalysis(app, sharpprobe, stimprobe, ndi_spike_element, ndi_vm_element, ndi_vm_corrected_element, ndi_vmspikes_corrected_element, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_EXAMINE_VM_SPIKE_MODEL(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% displayresults (1)         | Display the results (0/1)
%

displayresults = 1;

vlt.data.assign(varargin{:});

E = app.session;

et = epochtable(sharpprobe);
N = numel(et);

iapp = ndi.app(E,'vhlab_voltage2firingrate');
gapp = ndi.app.markgarbage(E);

 % need to output: neuralresponseresiduals.json

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
		
		% Pull out mean, F1 responses to stimuli, and the corresponding fits
		
		tapp = ndi.app.stimulus.tuning_response(E);

		response_types = {'mean','F1'};
		spike_tune_doc = {};
		spike_stimresp_doc = {};
		vm_tune_doc = {};
		vm_stimresp_doc = {};
		
		for i=1:numel(response_types),
			[spike_tune_doc{i},spike_stimresp_doc{i}] = tapp.find_tuningcurve_document(ndi_spike_element,et(n).epoch_id,response_types{i});
			[vm_tune_doc{i},vm_stimresp_doc{i}] = tapp.find_tuningcurve_document(ndi_vm_corrected_element,et(n).epoch_id,response_types{i});
		end;
		
		% check alignment of stimuli and pull out ordered pairs
		
		vm_fr = {};
		vm_fr_bystim = {};
		pres_numbers = [];
		
		for i=1:numel(response_types),
			vm_fr{i} = [];
			vm_fr_bystim{i} = [];
			for j=1:numel(vm_tune_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number),
				if ~vlt.data.eqlen( vm_tune_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number{j},...
					spike_tune_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number{j}),
					error(['mismatch in stimulus presentation numbers in individidual response records.']);
				end;
				if i==1,
					pres_numbers = cat(1,pres_numbers,vlt.data.colvec(spike_tune_doc{i}{1}.document_properties.tuning_curve.stimulus_presentation_number{j}));
				end;
				vm_resps_here = vm_tune_doc{i}{1}.document_properties.tuning_curve.individual_responses_real{j} + ...
					sqrt(-1)*vm_tune_doc{i}{1}.document_properties.tuning_curve.individual_responses_imaginary{j};
				vm_control_resps_here = vm_tune_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_real{j} + ...
					sqrt(-1)*vm_tune_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_imaginary{j};
				s_resps_here = spike_tune_doc{i}{1}.document_properties.tuning_curve.individual_responses_real{j} + ...
					sqrt(-1)*vm_tune_doc{i}{1}.document_properties.tuning_curve.individual_responses_imaginary{j};
				s_control_resps_here = spike_tune_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_real{j} + ...
					sqrt(-1)*vm_tune_doc{i}{1}.document_properties.tuning_curve.control_individual_responses_imaginary{j};
				vm_fr{i} = cat(1,vm_fr{i},[ vlt.data.colvec(vm_resps_here-0*vm_control_resps_here) vlt.data.colvec(s_resps_here-0*s_control_resps_here) ]);
				vm_fr_bystim{i}{j} = [ vlt.data.colvec(vm_resps_here-0*vm_control_resps_here) vlt.data.colvec(s_resps_here-0*s_control_resps_here) ];
			end;
		end;
		
		hold on;

		% which stimulus response is the largest in voltage, in terms of F0 + F1?

		vm_tune_doc{2}{1}.document_properties.tuning_curve.response_mean+vm_tune_doc{1}{1}.document_properties.tuning_curve.response_mean,
		[maxvalue, max_index] = max([vm_tune_doc{1}{1}.document_properties.tuning_curve.response_mean]+...
			[vm_tune_doc{2}{1}.document_properties.tuning_curve.response_mean]);
		max_stimid = vm_tune_doc{1}{1}.document_properties.tuning_curve.stimid(max_index),
		presentations_of_maxstimid = vm_tune_doc{1}{1}.document_properties.tuning_curve.stimulus_presentation_number{max_index};

		raw_data = {};
		rawer_data = {};
		spike_data = {};
		TT = {};
		VV = {};
		res = {};
		gof = [];
		total_power = [];
		residual_power = [];
		samples_per_trace = [];
        
		for i=1:numel(presentations_of_maxstimid),
			if max_stimid~=stim_onsetoffsetid(presentations_of_maxstimid(i),3),
				error(['Something is wrong. the stimids do not match for some reason. Investigation needed.']);
			end;
			[raw_data{i},t,tr_] = ndi_vm_corrected_element.readtimeseries(timeref, stim_onsetoffsetid(presentations_of_maxstimid(i),1), stim_onsetoffsetid(presentations_of_maxstimid(i),2));
			raw_data{i} = raw_data{i}(:);
			TT{i} = t-t(1);
			TT{i} = TT{i}(:);
			samples_per_trace(i) = numel(TT{i});
			VV{i} = vm_fr_bystim{1}{max_stimid}(i,1) + ...
				real(vm_fr_bystim{2}{max_stimid}(i,1))*cos(2*pi*tF*TT{i}) - imag(vm_fr_bystim{2}{max_stimid}(i,1)) * sin(2*pi*tF*TT{i});
			[rawer_data{i},t_,tr__] = ndi_vmspikes_corrected_element.readtimeseries(timeref, ...
				stim_onsetoffsetid(presentations_of_maxstimid(i),1), stim_onsetoffsetid(presentations_of_maxstimid(i),2));
			if numel(rawer_data{i}) > numel(raw_data{i}),
				rawer_data{i} = rawer_data{i}(1:numel(TT{i})); % in case samples are a little different
			elseif numel(rawer_data{i}) < numel(raw_data{i}),
				samplediff = numel(raw_data{i}) - numel(rawer_data{i});
				rawer_data{i}(end+1:end+samplediff) = raw_data{i}(end-samplediff+1:end);
			end;
			rawer_data{i} = rawer_data{i}(:);
			res{i} = raw_data{i}(:)-VV{i}(:);
			spike_data{i} = zeros(size(TT{i}));
			if numel(TT{i})>=2,
				[spike_data_here,t_spikes,t_refspikes] = ndi_spike_element.readtimeseries(timeref, ...
					stim_onsetoffsetid(presentations_of_maxstimid(i),1), stim_onsetoffsetid(presentations_of_maxstimid(i),2));
				spike_indexes = vlt.signal.point2samplelabel(t_spikes,TT{i}(2)-TT{i}(1), t(1));
				spike_data{i}(spike_indexes) = 1;
			end;
			[gof(i),total_power(i),residual_power(i)] = vlt.stats.gof_totalpower(raw_data{i}(:),VV{i}(:));
		end;

		vmneuralresponseresiduals.element_epochid = et(n).epoch_id;
		parameters = struct('number_traces',numel(presentations_of_maxstimid), 'samples_per_trace', samples_per_trace,'units','V');
		vmneuralresponseresiduals.parameters = parameters;
		vmneuralresponseresiduals.goodness_of_fit = gof;
		vmneuralresponseresiduals.total_power = total_power;
		vmneuralresponseresiduals.residual_power = residual_power;
		
		% search for old one
		vmresp_resid_doc_old = E.database_search( ndi.query('','depends_on','element_id',ndi_vm_corrected_element.id()) & ...
			ndi.query('','isa','vmneuralresponseresiduals.json','') & ...
			ndi.query('vmneuralresponseresiduals.element_epochid','exact_string',et(n).epoch_id,''))
		% remove old ones, preferred and non-preferred
		E.database_rm(vmresp_resid_doc_old);

		vmresp_resid_doc = ndi.document('apps/vhlab_voltage2firingrate/vmneuralresponseresiduals.json', ...
			'vmneuralresponseresiduals', vmneuralresponseresiduals) + E.newdocument('ndi_document','ndi_document.name', 'Preferred response');
		vmresp_resid_doc = vmresp_resid_doc.set_dependency_value('element_id',ndi_vm_corrected_element.id());
		
		E.database_add(vmresp_resid_doc);

		vmresp_binarydoc = E.database_openbinarydoc(vmresp_resid_doc);
		vlt.file.custom_file_formats.vhsb_write(vmresp_binarydoc, cat(1,TT{:}), [cat(1,raw_data{:}) cat(1, VV{:}) cat(1, rawer_data{:}) cat(1,res{:}) cat(1,spike_data{:})],'use_filelock',0);
		vmresp_binarydoc = E.database_closebinarydoc(vmresp_binarydoc);

		% now opposite direction

		min_index = 1+ mod(-1 + max_index + 0.5*numel(vm_tune_doc{1}{1}.document_properties.tuning_curve.response_mean), numel(vm_tune_doc{1}{1}.document_properties.tuning_curve.response_mean));
		min_stimid = vm_tune_doc{1}{1}.document_properties.tuning_curve.stimid(min_index),
		presentations_of_minstimid = vm_tune_doc{1}{1}.document_properties.tuning_curve.stimulus_presentation_number{min_index};

		raw_data = {};
		rawer_data = {};
		spike_data = {};
		TT = {};
		VV = {};
		res = {};
		gof = [];
		total_power = [];
		residual_power = [];
		samples_per_trace = [];
        
		for i=1:numel(presentations_of_minstimid),
			if min_stimid~=stim_onsetoffsetid(presentations_of_minstimid(i),3),
				error(['Something is wrong. the stimids do not match for some reason. Investigation needed.']);
			end;
			[raw_data{i},t,tr_] = ndi_vm_corrected_element.readtimeseries(timeref, stim_onsetoffsetid(presentations_of_minstimid(i),1), stim_onsetoffsetid(presentations_of_minstimid(i),2));
			raw_data{i} = raw_data{i}(:);
			TT{i} = t-t(1);
			TT{i} = TT{i}(:);
			samples_per_trace(i) = numel(TT{i});
			VV{i} = vm_fr_bystim{1}{min_stimid}(i,1) + ...
				real(vm_fr_bystim{2}{min_stimid}(i,1))*cos(2*pi*tF*TT{i}) - imag(vm_fr_bystim{2}{min_stimid}(i,1)) * sin(2*pi*tF*TT{i});
			[rawer_data{i},t_,tr__] = ndi_vmspikes_corrected_element.readtimeseries(timeref, ...
				stim_onsetoffsetid(presentations_of_minstimid(i),1), stim_onsetoffsetid(presentations_of_minstimid(i),2));
			if numel(rawer_data{i}) > numel(raw_data{i}),
				rawer_data{i} = rawer_data{i}(1:numel(TT{i})); % in case samples are a little different
			elseif numel(rawer_data{i}) < numel(raw_data{i}),
				samplediff = numel(raw_data{i}) - numel(rawer_data{i});
				rawer_data{i}(end+1:end+samplediff) = raw_data{i}(end-samplediff+1:end);
			end;
			rawer_data{i} = rawer_data{i}(:);
			res{i} = raw_data{i}(:)-VV{i}(:);
			spike_data{i} = zeros(size(TT{i}));
			if numel(TT{i})>=2,
				[spike_data_here,t_spikes,t_refspikes] = ndi_spike_element.readtimeseries(timeref, ...
					stim_onsetoffsetid(presentations_of_minstimid(i),1), stim_onsetoffsetid(presentations_of_minstimid(i),2));
				spike_indexes = vlt.signal.point2samplelabel(t_spikes,TT{i}(2)-TT{i}(1), t(1));
				spike_data{i}(spike_indexes) = 1;
			end;
			[gof(i),total_power(i),residual_power(i)] = vlt.stats.gof_totalpower(raw_data{i}(:),VV{i}(:));
		end;

		vmneuralresponseresiduals.element_epochid = et(n).epoch_id;
		parameters = struct('number_traces',numel(presentations_of_minstimid), 'samples_per_trace', samples_per_trace,'units','V');
		vmneuralresponseresiduals.parameters = parameters;
		vmneuralresponseresiduals.goodness_of_fit = gof;
		vmneuralresponseresiduals.total_power = total_power;
		vmneuralresponseresiduals.residual_power = residual_power;
		
		% search for old one
		vmresp_resid_doc_old = E.database_search( ndi.query('','depends_on','element_id',ndi_vm_corrected_element.id()) & ...
			ndi.query('','isa','vmneuralresponseresiduals.json','') & ndi.query('ndi_document.name','exact_string','Nonpreferred response','') & ...
			ndi.query('vmneuralresponseresiduals.element_epochid','exact_string',et(n).epoch_id,''))
		% remove old one
		E.database_rm(vmresp_resid_doc_old);

		vmresp_resid_doc = ndi.document('apps/vhlab_voltage2firingrate/vmneuralresponseresiduals.json', ...
			'vmneuralresponseresiduals', vmneuralresponseresiduals) + E.newdocument('ndi_document','ndi_document.name','Nonpreferred response');
		vmresp_resid_doc = vmresp_resid_doc.set_dependency_value('element_id',ndi_vm_corrected_element.id());
		
		E.database_add(vmresp_resid_doc);

		vmresp_binarydoc = E.database_openbinarydoc(vmresp_resid_doc);
		vlt.file.custom_file_formats.vhsb_write(vmresp_binarydoc, cat(1,TT{:}), [cat(1,raw_data{:}) cat(1, VV{:}) cat(1, rawer_data{:}) cat(1,res{:}) cat(1,spike_data{:})],'use_filelock',0);
		vmresp_binarydoc = E.database_closebinarydoc(vmresp_binarydoc);

		% now blank stimulus

		raw_data = {};
		rawer_data = {};
		spike_data = {};
		TT = {};
		VV = {};
		res = {};
		gof = [];
		total_power = [];
		residual_power = [];
		samples_per_trace = [];
 
		blank_multiplier = 1;       
		blank_stimid = isblank
		if isempty(blank_stimid),
			blank_stimid = max_index;
			blank_multiplier = 0;
		end;
		blank_stimpres = find(stim_onsetoffsetid(:,3)==blank_stimid);
		for i=1:numel(blank_stimpres),
			if blank_stimid~=stim_onsetoffsetid(blank_stimpres(i),3),
				error(['Something is wrong. the stimids do not match for some reason. Investigation needed.']);
			end;
			[raw_data{i},t,tr_] = ndi_vm_corrected_element.readtimeseries(timeref, ...
				stim_onsetoffsetid(blank_stimpres(i),1), stim_onsetoffsetid(blank_stimpres(i),2));
			raw_data{i} = blank_multiplier * raw_data{i}(:);
			TT{i} = t-t(1);
			TT{i} = TT{i}(:);
			samples_per_trace(i) = numel(TT{i});
			VV{i} = 0*TT{i}; 
			[rawer_data{i},t_,tr__] = ndi_vmspikes_corrected_element.readtimeseries(timeref, ...
				stim_onsetoffsetid(blank_stimpres(i),1), stim_onsetoffsetid(blank_stimpres(i),2));
			if numel(rawer_data{i}) > numel(raw_data{i}),
				rawer_data{i} = rawer_data{i}(1:numel(TT{i})); % in case samples are a little different
			elseif numel(rawer_data{i}) < numel(raw_data{i}),
				samplediff = numel(raw_data{i}) - numel(rawer_data{i});
				rawer_data{i}(end+1:end+samplediff) = raw_data{i}(end-samplediff+1:end);
			end;
			rawer_data{i} = blank_multiplier*rawer_data{i}(:);
			res{i} = raw_data{i}(:)-VV{i}(:);
			spike_data{i} = zeros(size(TT{i}));
			if numel(TT{i})>=2,
				[spike_data_here,t_spikes,t_refspikes] = ndi_spike_element.readtimeseries(timeref, ...
					stim_onsetoffsetid(blank_stimpres(i),1), stim_onsetoffsetid(blank_stimpres(i),2));
				spike_indexes = vlt.signal.point2samplelabel(t_spikes,TT{i}(2)-TT{i}(1), t(1));
				spike_data{i}(spike_indexes) = 1;
			end;
			[gof(i),total_power(i),residual_power(i)] = vlt.stats.gof_totalpower(raw_data{i}(:),VV{i}(:));
		end;

		vmneuralresponseresiduals.element_epochid = et(n).epoch_id;
		parameters = struct('number_traces',numel(presentations_of_minstimid), 'samples_per_trace', samples_per_trace,'units','V');
		vmneuralresponseresiduals.parameters = parameters;
		vmneuralresponseresiduals.goodness_of_fit = gof;
		vmneuralresponseresiduals.total_power = total_power;
		vmneuralresponseresiduals.residual_power = residual_power;
		
		% search for old one
		vmresp_resid_doc_old = E.database_search( ndi.query('','depends_on','element_id',ndi_vm_corrected_element.id()) & ...
			ndi.query('','isa','vmneuralresponseresiduals.json','') & ndi.query('ndi_document.name','exact_string','Control response','') & ...
			ndi.query('vmneuralresponseresiduals.element_epochid','exact_string',et(n).epoch_id,''))
		% remove old one
		E.database_rm(vmresp_resid_doc_old);

		vmresp_resid_doc = ndi.document('apps/vhlab_voltage2firingrate/vmneuralresponseresiduals.json', ...
			'vmneuralresponseresiduals', vmneuralresponseresiduals) + E.newdocument('ndi_document','ndi_document.name','Control response');
		vmresp_resid_doc = vmresp_resid_doc.set_dependency_value('element_id',ndi_vm_corrected_element.id());
		
		E.database_add(vmresp_resid_doc);

		vmresp_binarydoc = E.database_openbinarydoc(vmresp_resid_doc);
		vlt.file.custom_file_formats.vhsb_write(vmresp_binarydoc, cat(1,TT{:}), [cat(1,raw_data{:}) cat(1, VV{:}) cat(1, rawer_data{:}) cat(1,res{:}) cat(1,spike_data{:})],'use_filelock',0);
		vmresp_binarydoc = E.database_closebinarydoc(vmresp_binarydoc);

	end; % if isdirection
end; % loop over epochs

end % function

