function [fr, v, timepoints] = intracell_strf_dof0f1(app, stimprobe, ndi_element_obj, varargin)
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
rapp = ndi.app.stimulus.tuning_response(E);
oapp = ndi.app.oridirtuning(E);

q_oridocs = ndi.query('orientation_direction_tuning','hasfield','','');

q_rdoc = ndi.query('','isa','vlt.neuro.stimulus.stimulus_response_scalar.json','');
q_e = ndi.query(E.searchquery());
q_relement = ndi.query('','depends_on','element_id',ndi_element_obj.id());
rdoc = E.database_search(q_rdoc&q_e&q_relement);
q_tc = ndi.query('','isa','stimulus_tuningcurve.json',''); % too broad, will kill any tuning curve

tdoc = E.database_search(q_relement&q_tc);
oridocs = E.database_search(q_relement&q_oridocs);

disp(['Beginning work on element...'])

ndi_element_obj,

disp(['Resetting by deleting ' int2str(numel(rdoc)) ' rdoc, ' int2str(numel(tdoc)) ' tdoc, and ' ...
		int2str(numel(oridocs)) ' oridocs.']);

E.database_rm(rdoc);
E.database_rm(tdoc);
E.database_rm(oridocs);

disp(['After computing f0f1, we have the following:']);

rapp.stimulus_responses(stimprobe, ndi_element_obj, 1);

rdoc = E.database_search(q_rdoc&q_e&q_relement)

tdoc = oapp.calculate_tuning_curve(ndi_element_obj)

oriprops = oapp.calculate_all_oridir_indexes(ndi_element_obj);

