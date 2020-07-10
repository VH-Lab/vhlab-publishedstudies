function spikeshape_struct = intracell_strf_summary_spikeshape(isstudy)
% INTRACELL_STRF_SUMMARY_SPIKESHAPE - retrieve summary of spike shape information
%
% SPIKESHAPE_STRUCT = INTRACELL_STRF_SUMMARY_SPIKESHAPE(ISSTUDY)
%
% Retrieve records for spike shape
%
% ISSTUDY should be the output of INTRACELL_STRF_SUMMARY_SETUP.
% 

spikeshape_struct = emptystruct('spike_summary', 'name','reference','young');

for i=1:numel(isstudy),

	disp(['Working on session ' int2str(i) ' of ' int2str(numel(isstudy)) '.']);

	myelements_vmcorrected = getelements(isstudy(i).E,'element.type','Vm_corrected');

        stimprobe = getprobes(isstudy(i).E, 'name', 'vhvis_spike2', 'type', 'stimulator');

	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end;
	stimprobe = stimprobe{1};

	for p=1:numel(myelements_vmcorrected),

		et = myelements_vmcorrected{p}.epochtable();

		for e=1:numel(et),

			isdirectionepoch = 0;

			[data,t_raw,timeref] = readtimeseries(myelements_vmcorrected{p}, et(e).epoch_id, 0, 1);

			gapp = ndi_app_markgarbage(isstudy(i).E);
			vi = gapp.loadvalidinterval(myelements_vmcorrected{p});
			interval = gapp.identifyvalidintervals(myelements_vmcorrected{p},timeref,0,Inf);

			[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,interval(1,1),interval(1,2));
			stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];

			isblank = structfindfield(ds.parameters,'isblank',1);
			notblank = setdiff(1:numel(ds.parameters),isblank);
			if eqlen(structwhatvaries(ds.parameters(notblank)),{'angle'})
				isdirectionepoch = 1;
			end;

			if isdirectionepoch,

						% ASSUMPTION: a single direction epoch per cell; we know this is true for this study

				q_spikestats = ndi_query('','isa','vmspikesummary.json','');
				q_element = ndi_query('','depends_on','element_id',myelements_vmcorrected{p}.id());
				q_epoch = ndi_query('epochid','exact_string',et(e).epoch_id,'');

				sq = (q_spikestats & q_element & q_epoch);
				docs = isstudy(i).E.database_search(sq);

				if numel(docs)~=1,
					error(['Missing doc or too many docs']);
				end;

				% store
				spikeshape_struct(end+1) = struct('spike_summary', docs{1}.document_properties.vmspikesummary, ...
					'name', [myelements_vmcorrected{p}.underlying_element.elementstring() '@' et(e).epoch_id], ...
					'reference', myelements_vmcorrected{p}.session.reference,...
					'young', isstudy(i).young);

			end;
		end;
	end;
end;


