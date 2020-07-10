function oriprops_struct = intracell_strf_summary_model(isstudy)
% INTRACELL_STRF_SUMMARY_VF - plot summary of voltage to firing rate information for intracell_struf
%
% INTRACELL_STRF_SUMMARY_VF(ISSTUDY)
%
% Plot summary of V vs. Firing rate for the whole study.
%
% ISSTUDY should be the output of INTRACELL_STRF_SUMMARY_SETUP.
% 
%
%

oriprops_struct = emptystruct('actual','model', 'response_type', 'name','reference','young','out_pref','out_null','out_control');

response_types = {'mean','F1'};

for i=1:numel(isstudy),

	disp(['Working on session ' int2str(i) ' of ' int2str(numel(isstudy)) '.']);

	myelements_spikes = getelements(isstudy(i).E,'element.type','spikes');
	myelements_vmsmooth = getelements(isstudy(i).E,'element.type','RawVmFr_model_selfconsistencycheck_linepowerthresh');
	myelements_vmcorrected = getelements(isstudy(i).E, 'element.type', 'Vm_only_corrected');

        stimprobe = getprobes(isstudy(i).E, 'name', 'vhvis_spike2', 'type', 'stimulator');

	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end;
	stimprobe = stimprobe{1};

	for p=1:numel(myelements_spikes),

        myelements_spikes{p},
        
		clear element_vmsmooth_match;
		for t=1:numel(myelements_vmsmooth),
			if strcmp(myelements_vmsmooth{t}.underlying_element.elementstring(), myelements_spikes{p}.underlying_element.elementstring()),
				element_vmsmooth_match = myelements_vmsmooth{t};
			end;
		end;
		if isempty(element_vmsmooth_match),
			error(['No corresponding vmsmooth match for ' myelements_spikes{p}.elementstring]);
		end;
		clear element_vmcorrected_match;
		for t=1:numel(myelements_vmcorrected),
			if strcmp(myelements_vmcorrected{t}.underlying_element.elementstring(), myelements_spikes{p}.underlying_element.elementstring()),
				element_vmcorrected_match = myelements_vmcorrected{t};
			end;
		end;
		if isempty(element_vmcorrected_match),
			error(['No corresponding vmcorrected match for ' myelements_spikes{p}.elementstring]);
		end;
	
		et = myelements_spikes{p}.epochtable();

		for e=1:numel(et),

			isdirectionepoch = 0;

			[data,t_raw,timeref] = readtimeseries(myelements_spikes{p}, et(e).epoch_id, 0, 1);

			gapp = ndi_app_markgarbage(isstudy(i).E);
			vi = gapp.loadvalidinterval(myelements_spikes{p});
			interval = gapp.identifyvalidintervals(myelements_spikes{p},timeref,0,Inf);

			[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,interval(1,1),interval(1,2));
			stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];

			isblank = structfindfield(ds.parameters,'isblank',1);
			notblank = setdiff(1:numel(ds.parameters),isblank);
			if eqlen(structwhatvaries(ds.parameters(notblank)),{'angle'})
				isdirectionepoch = 1;
			end;

			if isdirectionepoch,

						% ASSUMPTION: epoch_ids are the same, not true in general
				vmresp_resid_doc = isstudy(i).E.database_search( ndi_query('','depends_on','element_id',element_vmcorrected_match.id()) & ...
					ndi_query('','isa','vmneuralresponseresiduals.json','') & ndi_query('ndi_document.name','exact_string','Preferred response','') & ...
					ndi_query('vmneuralresponseresiduals.element_epochid','exact_string',et(e).epoch_id,''));

				if ~isempty(vmresp_resid_doc),
					out_pref = intracell_strf_residual2waves(isstudy(i).E, vmresp_resid_doc);
				else,
					error(['could not find vmresp_resid_doc']);
				end;
						% ASSUMPTION: epoch_ids are the same, not true in general
				vmresp_resid_doc = isstudy(i).E.database_search( ndi_query('','depends_on','element_id',element_vmcorrected_match.id()) & ...
					ndi_query('','isa','vmneuralresponseresiduals.json','') & ndi_query('ndi_document.name','exact_string','Nonpreferred response','') & ...
					ndi_query('vmneuralresponseresiduals.element_epochid','exact_string',et(e).epoch_id,''));

				if ~isempty(vmresp_resid_doc),
					out_null = intracell_strf_residual2waves(isstudy(i).E, vmresp_resid_doc);
				else,
					error(['could not find vmresp_resid_doc']);
				end;

						% ASSUMPTION: epoch_ids are the same, not true in general
				vmresp_resid_doc = isstudy(i).E.database_search( ndi_query('','depends_on','element_id',element_vmcorrected_match.id()) & ...
					ndi_query('','isa','vmneuralresponseresiduals.json','') & ndi_query('ndi_document.name','exact_string','Control response','') & ...
					ndi_query('vmneuralresponseresiduals.element_epochid','exact_string',et(e).epoch_id,''));

				if ~isempty(vmresp_resid_doc),
					out_control = intracell_strf_residual2waves(isstudy(i).E, vmresp_resid_doc);
				else,
					error(['could not find vmresp_resid_doc']);
				end;

				q_e = ndi_query(isstudy(i).E.searchquery());
				q_rdoc = ndi_query('','isa','stimulus_response_scalar.json','');
				q_epoch = ndi_query('stimulus_response.element_epochid','exact_string', et(e).epoch_id, '');
					% here we make the assumption of common epochid names
				
				q_relement_actual = ndi_query('','depends_on','element_id',myelements_spikes{p}.id());
				q_relement_model = ndi_query('','depends_on','element_id',element_vmsmooth_match.id());
				q_tc = ndi_query('','isa','stimulus_tuningcurve.json',''); 
				q_oridocs = ndi_query('orientation_direction_tuning','hasfield','','');
				
				tdoc_resp_actual = {};
				oridoc_resp_actual = {};

				for r=1:numel(response_types),
					q_resptype = ndi_query('stimulus_response_scalar.response_type','exact_string',response_types{r},'');

					rdoc_actual = isstudy(i).E.database_search(q_e&q_relement_actual&q_rdoc&q_resptype&q_epoch);
					q_tunedocactual = ndi_query('','depends_on','stimulus_response_scalar_id',rdoc_actual{1}.id());
					tdoc_actual = isstudy(i).E.database_search(q_relement_actual&q_tunedocactual&q_tc);
					q_rdocspecific = ndi_query('','depends_on','stimulus_tuningcurve_id',tdoc_actual{1}.id());
					oridocs_actual = isstudy(i).E.database_search(q_relement_actual&q_oridocs&q_rdocspecific);

						% ASSUMPTION: epoch_ids are the same, not true in general
					rdoc_model = isstudy(i).E.database_search(q_e&q_relement_model&q_rdoc&q_resptype&q_epoch);
                    try, 
					q_tunedocmodel = ndi_query('','depends_on','stimulus_response_scalar_id',rdoc_model{1}.id());
                    catch,
                        keyboard;
                    end;
					tdoc_model = isstudy(i).E.database_search(q_relement_model&q_tunedocmodel&q_tc);
					q_rdocspecific = ndi_query('','depends_on','stimulus_tuningcurve_id',tdoc_model{1}.id());
					oridocs_model = isstudy(i).E.database_search(q_relement_model&q_oridocs&q_rdocspecific);

					% store
					oriprops_struct(end+1) = struct('actual', oridocs_actual{1}.document_properties.orientation_direction_tuning,...
					'model', oridocs_model{1}.document_properties.orientation_direction_tuning,...
					'response_type',response_types{r},...
					'name', [myelements_spikes{p}.underlying_element.elementstring '@' et(e).epoch_id], ...
					'reference', myelements_spikes{p}.session.reference,...
					'young', isstudy(i).young,'out_pref',out_pref,'out_null',out_null,'out_control',out_control);

				end;



			end;
		end;
	end;
end;


