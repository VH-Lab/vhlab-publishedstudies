function curvestruct = intracell_strf_summary_vfr(isstudy)
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

curvestruct = vlt.data.emptystruct('voltage_observations','firingrate_observations','Xn','Yn','Yint','Nn',...
	'name','reference','young','fit');

q_bindoc = ndi_query('','isa','binnedspikeratevm.json','');

for i=1:numel(isstudy),

	disp(['Working on session ' int2str(i) ' of ' int2str(numel(isstudy)) '.']);

	sharpprobes = getprobes(isstudy(i).E, 'type', 'sharp-Vm');

        stimprobe = getprobes(isstudy(i).E, 'name', 'vhvis_spike2', 'type', 'stimulator');

	if numel(stimprobe)~=1,
		error(['Did not find exactly 1 stimulator, confused.']);
	end;
	stimprobe = stimprobe{1};

	for p=1:numel(sharpprobes),

		et = sharpprobes{p}.epochtable();

		q_elementid = ndi_query('','depends_on','element_id',sharpprobes{p}.id());

		for e=1:numel(et),

			isdirectionepoch = 0;

			[data,t_raw,timeref] = readtimeseries(sharpprobes{p}, et(e).epoch_id, 0, 1);

			gapp = ndi_app_markgarbage(isstudy(i).E);
			vi = gapp.loadvalidinterval(sharpprobes{p});
			interval = gapp.identifyvalidintervals(sharpprobes{p},timeref,0,Inf);

			[ds, ts, timeref_]=stimprobe.readtimeseries(timeref,interval(1,1),interval(1,2));
			stim_onsetoffsetid = [ts.stimon ts.stimoff ds.stimid];

			isblank = vlt.data.structfindfield(ds.parameters,'isblank',1);
			notblank = setdiff(1:numel(ds.parameters),isblank);
			if vlt.data.eqlen(vlt.data.structwhatvaries(ds.parameters(notblank)),{'angle'})
				isdirectionepoch = 1;
			end;

			if isdirectionepoch,
				q_epoch = ndi_query('epochid','exact_string',et(e).epoch_id,'');

				mydoc = isstudy(i).E.database_search(q_epoch & q_elementid & q_bindoc);

				if ~isempty(mydoc),
					mydoc = mydoc{1};

					Yn = [];
					Xn = [];
					Yint = [];
					Nn = [];

					vlt.data.struct2var(mydoc.document_properties.binnedspikeratevm);

					if ~isempty(firingrate_observations),
						[Yn,Xn,Yint] = vlt.math.slidingwindowfunc(voltage_observations,  firingrate_observations,  ...
								min(voltage_observations), 0.001, max(voltage_observations), 0.002, 'mean',0);
						[Nn] = vlt.math.slidingwindowfunc(voltage_observations, firingrate_observations, ...
								min(voltage_observations), 0.001, max(voltage_observations), 0.002, 'numel',0);
					end;

					curvestruct(end+1) = struct('voltage_observations',voltage_observations,...
						'firingrate_observations', firingrate_observations,...
						'Xn', Xn, 'Yn', Yn, 'Yint', Yint, 'Nn', Nn, ...
						'name', [sharpprobes{p}.elementstring() '@' et(e).epoch_id], ...
						'reference', sharpprobes{p}.session.reference,...
						'young', isstudy(i).young,'fit',[]);

					% fits 
					fits = vlt.data.emptystruct('voltages','fr','fitdoc','fittype');

					fittypes = {'linethreshold','vlt.fit.linepowerthreshold','vlt.fit.tanhfitoffset','linepowerthreshold_0'};
					voltages = -0.100:0.001:0.050;
					for f=1:numel(fittypes),
						fitdoc = sharpprobes{p}.session.database_search(ndi_query('','isa','fitcurve.json','') & ...
							ndi_query('fitcurve.fit_name','exact_string',fittypes{f},'') & ...
							q_epoch & q_elementid);
						if ~isempty(fitdoc),
							fitdoc = vlt.data.celloritem(fitdoc,1);
							fr = ndi_evaluate_fitcurve(fitdoc,voltages);
							fits(end+1) = struct('voltages',voltages,'fr',fr,'fitdoc',fitdoc,'fittype',fittypes{f});
						end;
					end;

					curvestruct(end).fit = fits;
				end;
			end;
		end;
	end;
end;


