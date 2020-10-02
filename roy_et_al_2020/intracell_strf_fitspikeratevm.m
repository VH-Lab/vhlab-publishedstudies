function [fr, v, timepoints] = intracell_strf_fitspikeratevm(app, sharpprobe, stimprobe, varargin)
% INTRACELL_STRF_FITSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_FITSPIKERATEVM(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
%

vlt.data.assign(varargin{:});

 % document search queries
q_spikeratevmdoc = ndi.query('','isa','binnedspikeratevm.json','');  % old, legacy
q_elementid = ndi.query('','depends_on','element_id',sharpprobe.id());
q_fitcurvedoc = ndi.query('','isa','fitcurve.json','');
q_lt = ndi.query('fitcurve.fit_name','exact_string','linethreshold','');
q_lpt = ndi.query('fitcurve.fit_name','exact_string','vlt.fit.linepowerthreshold','');
q_lpt0 = ndi.query('fitcurve.fit_name','exact_string','linepowerthreshold_0','');
q_tanh = ndi.query('fitcurve.fit_name','exact_string','vlt.fit.tanhfitoffset','');

E = app.session;

iapp = ndi.app(E,'vhlab_voltage2firingrate');

et = epochtable(sharpprobe);
N = numel(et);

for n=1:N,
	varsbeginning = fieldnames(vlt.data.workspace2struct);

	q_epochid = ndi.query('epochid','exact_string',et(n).epoch_id,'');
	spikeratevmdoc = E.database_search(q_spikeratevmdoc&q_epochid&q_elementid);

	if ~isempty(spikeratevmdoc),

		% Step 1: set up inputs/outputs for fitting

		spikeratevmdoc = vlt.data.celloritem(spikeratevmdoc,1);
		vlt.data.struct2var(spikeratevmdoc.document_properties.binnedspikeratevm);

		fit_datap = struct('input_data_field','binnedspikeratevm.voltage_observations', ...
			'output_data_field', 'binnedspikeratevm.firingrate_observations',...
			'output_number_examples',numel(firingrate_observations));

		% Step 2: fit with Y = alpha*vlt.math.rectify(X-T)

		oldfitdoc = E.database_search(q_fitcurvedoc&q_epochid&q_elementid&q_lt);
		E.database_rm(oldfitdoc); % remove it if it exists

		[slope1,threshold1,curve,gof1,fitinfo1] = vlt.fit.linethresholdfit(voltage_observations, firingrate_observations);
		sse1 = gof1.sse;
		fit_constraints = [];
		fitcurveparams = struct('fit_name','linethreshold','fit_equation','y=slope*vlt.math.rectify(x-threshold)', ...
			'fit_parameters', [slope1 threshold1], 'fit_parameter_names', 'slope threshold', ...
			'fit_sse', sse1, 'fit_constraints', fit_constraints, 'fit_data', fit_datap,...
			'fit_independent_variable_names','x','fit_dependent_variable_names','y');

		fitdoc = E.newdocument('data/fitcurve', 'fitcurve', fitcurveparams,'epochid',et(n).epoch_id);
		fitdoc = fitdoc.set_dependency_value('element_id',sharpprobe.id(),'ErrorIfNotFound',0);
		fitdoc = fitdoc.set_dependency_value('fit_example_data_id',spikeratevmdoc.id());
		E.database_add(fitdoc);

		% Step 3: fit with Y = alpha*vlt.math.rectify(X-T)^beta

		oldfitdoc = E.database_search(q_fitcurvedoc&q_epochid&q_elementid&q_lpt);
		E.database_rm(oldfitdoc); % remove it if it exists

		[slope2, offset2, threshold2, exponent2, curve, gof2, fitinfo2] = vlt.fit.linepowerthresholdfit(...
			voltage_observations, firingrate_observations,...
			'exponent_start',1, 'exponent_range',[1 4],'offset_start',0,'offset_range',[0 0]);
		sse2 = gof2.sse;
		fit_constraints = struct('fit_constraint_name','exponent_start','fit_constraint_value',1);
		fit_constraints(2) = struct('fit_constraint_name','exponent_range','fit_constraint_value',[1 4]);
		fit_constraints(3) = struct('fit_constraint_name','offset_start','fit_constraint_value',0);
		fit_constraints(4) = struct('fit_constraint_name','offset_range','fit_constraint_value',[0 0]);
		fitcurveparams = struct('fit_name','vlt.fit.linepowerthreshold','fit_equation',...
			'y=offset+slope*vlt.math.rectify(x-threshold).^exponent', ...
			'fit_parameters', [slope2 threshold2 offset2 exponent2],...
			'fit_parameter_names', 'slope threshold offset exponent', 'fit_sse', sse2, ...
			'fit_constraints', fit_constraints, 'fit_data', fit_datap,...
			'fit_independent_variable_names','x','fit_dependent_variable_names','y');

		fitdoc = E.newdocument('data/fitcurve', 'fitcurve', fitcurveparams,'epochid',et(n).epoch_id);
		fitdoc = fitdoc.set_dependency_value('element_id',sharpprobe.id(),'ErrorIfNotFound',0);
		fitdoc = fitdoc.set_dependency_value('fit_example_data_id',spikeratevmdoc.id());
		E.database_add(fitdoc);

		% Step 4: fit with Y = alpha*vlt.math.rectify(X)^beta

		oldfitdoc = E.database_search(q_fitcurvedoc&q_epochid&q_elementid&q_lpt0);
		E.database_rm(oldfitdoc); % remove it if it exists

		[slope2a, offset2a, threshold2a, exponent2a, curve, gof2a, fitinfo2a] = vlt.fit.linepowerthresholdfit(...
			voltage_observations, firingrate_observations, 'exponent_start',1, 'exponent_range',[1 4],...
			'offset_start',0,'offset_range',[0 0],'threshold_start',0,'threshold_range',[0 0]);
		sse2 = gof2.sse;
		fit_constraints = struct('fit_constraint_name','exponent_start','fit_constraint_value',1);
		fit_constraints(2) = struct('fit_constraint_name','exponent_range','fit_constraint_value',[1 4]);
		fit_constraints(3) = struct('fit_constraint_name','offset_start','fit_constraint_value',0);
		fit_constraints(4) = struct('fit_constraint_name','offset_range','fit_constraint_value',[0 0]);
		fit_constraints(5) = struct('fit_constraint_name','threshold_start','fit_constraint_value',0);
		fit_constraints(6) = struct('fit_constraint_name','threshold_range','fit_constraint_value',[0 0]);
		fitcurveparams = struct('fit_name','linepowerthreshold_0','fit_equation',...
			'y=offset+slope*vlt.math.rectify(x-threshold).^exponent', ...
			'fit_parameters', [slope2a threshold2a offset2a exponent2a],'fit_parameter_names', ...
			'slope threshold offset exponent', 'fit_sse', sse2, ...
			'fit_constraints', fit_constraints, 'fit_data', fit_datap,...
			'fit_independent_variable_names','x','fit_dependent_variable_names','y');
		fitdoc = E.newdocument('data/fitcurve', 'fitcurve', fitcurveparams,'epochid',et(n).epoch_id);
		fitdoc = fitdoc.set_dependency_value('element_id',sharpprobe.id(),'ErrorIfNotFound',0);
		fitdoc = fitdoc.set_dependency_value('fit_example_data_id',spikeratevmdoc.id());
		E.database_add(fitdoc);

		% Step 4: fit with Y = alpha*tanh((X-C)/D)

		oldfitdoc = E.database_search(q_fitcurvedoc&q_epochid&q_elementid&q_tanh);
		E.database_rm(oldfitdoc); % remove it if it exists

		[curve, params3, gof3, fitinfo3] = vlt.fit.tanhfitoffset(voltage_observations, firingrate_observations, 'a_range',[0 0],...
			'startPoint',[0 1 0 1],'c_range',[-0.1 0.1],'d_range',[0.00001 Inf]);
		sse3 = gof3.sse;
		fit_constraints = struct('fit_constraint_name','a_range','fit_constraint_value',[0 0]);
		fit_constraints(2) = struct('fit_constraint_name','startPoint','fit_constraint_value',[0 1 0 1]);
		fit_constraints(3) = struct('fit_constraint_name','c_range','fit_constraint_value',[-0.1 0.1]);
		fit_constraints(4) = struct('fit_constraint_name','d_range','fit_constraint_value',[0.00001 Inf]);
		fitcurveparams = struct('fit_name','vlt.fit.tanhfitoffset','fit_equation','y=a+b+b*tanh((x-c)./d)', ...
			'fit_parameters', [params3.a params3.b params3.c params3.d],...
			'fit_parameter_names', 'a b c d', 'fit_sse', sse3, ...
			'fit_constraints', fit_constraints, 'fit_data', fit_datap,...
			'fit_independent_variable_names','x','fit_dependent_variable_names','y');
		fitdoc = E.newdocument('data/fitcurve', 'fitcurve', fitcurveparams,'epochid',et(n).epoch_id);
		fitdoc = fitdoc.set_dependency_value('fit_example_data_id',spikeratevmdoc.id());
		fitdoc = fitdoc.set_dependency_value('element_id',sharpprobe.id(),'ErrorIfNotFound',0);
		E.database_add(fitdoc);

	else,
	end;

	varsnow = fieldnames(vlt.data.workspace2struct);
	varsnew = setdiff(varsnow,varsbeginning);
	if ~isempty(varsnew),
		clear(varsnew{:},'varsnew');
	end;

end;

