function intracell_strf_extractspikewaves(app, sharpprobe, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_BINNEDSPIKERATEVM(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% displayresults (1)         | Display the results (0/1)
%

displayresults = 1;

vlt.data.assign(varargin{:});

et = epochtable(sharpprobe);
N = numel(et);

E = app.session;

gapp = ndi.app.markgarbage(E);
sapp = ndi.app.spikeextractor(E);

element_vmcorrected       = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference,'Vm_corrected',sharpprobe,0);
element_subtractedvalue   = ndi.element.timeseries(E,sharpprobe.elementstring(),sharpprobe.reference,'Vm_correctionvalue',sharpprobe,0);

et = epochtable(element_vmcorrected);
N = numel(et);

q_projvardef = ndi.query(intracell_strf_projectvardef);
q_docname = ndi.query('ndi_document.name','exact_string','Epoch spike threshold','');
q_elementid = ndi.query('','depends_on','element_id',sharpprobe.id());

for n=1:N, 
	q_epochid = ndi.query('epochid','exact_string',et(n).epoch_id,'');
	thresh_doc = E.database_search(q_elementid & q_projvardef & q_docname & q_epochid);

	[subtractedvalue,t_raw2,timeref2] = readtimeseries(element_subtractedvalue, et(n).epoch_id, -Inf, Inf);

	shift = nanmedian(subtractedvalue);
	
	extract_doc = ndi.document('apps/spikeextractor/spike_extraction_parameters');
	spike_extraction_parameters = extract_doc.document_properties.spike_extraction_parameters;

	spike_extraction_parameters.dofilter = 0;
	spike_extraction_parameters.filter_type = 'none';
	spike_extraction_parameters.threshold_method = 'absolute';
	spike_extraction_parameters.threshold_parameter = thresh_doc{1}.document_properties.projectvar.data/10 - shift;
	spike_extraction_parameters.threshold_sign = 1;
	spike_extraction_parameters.spike_start_time = -0.004;
	spike_extraction_parameters.spike_end_time = 0.004;
	spike_extraction_parameters.center_range_time = 0.0015;
	spike_extraction_parameters.read_time = 1000; % long time, its faster

	extract_p_name = ['manually_selected ' sharpprobe.id() '.' et(n).epoch_id];
	sapp.add_appdoc('extraction_parameters', spike_extraction_parameters, 'Replace', extract_p_name);

	sapp.extract(element_vmcorrected,et(n).epoch_id,extract_p_name,1);
end;


