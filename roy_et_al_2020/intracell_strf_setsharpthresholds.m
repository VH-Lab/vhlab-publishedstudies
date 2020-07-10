function intracell_strf_setsharpthresholds(app, E)
% INTRACELL_STRF_SETSHARPTHRESHOLDS - set sharp electrode probe thresholds
%
% INTRACELL_STRF_SETSHARPTHRESHOLDS(E)
%
% For an NDI_EXPERIMENT object E, examines all probes to see if thresholds have
% been previously saved for each probe. If not, the user is prompted to identify the spike
% threshold for each epoch of each probe.
%
%
% 
%  

q_projectvardef = ndi_query(intracell_strf_projectvardef);
q_docname = ndi_query('ndi_document.name','exact_string','Epoch spike threshold','');

probes = getprobes(E);

vhvis = [];
for i=1:numel(probes),
	if strcmp(probes{i}.name, 'vhvis_spike2'),
		vhvis = probes{i};
	end
end

for i=1:numel(probes),
	disp(['Now checking ' probes{i}.elementstring() '.']);

	if strcmp(probes{i}.type,'sharp-Vm'),
		et = epochtable(probes{i});
		q_elementid = ndi_query('','depends_on','element_id',probes{i}.id());
		all_matched = 1;
		for n=1:numel(et),
        		q_epochid = ndi_query('epochid','exact_string',et(n).epoch_id,'');
			docs = E.database_search( q_epochid & q_elementid & q_projectvardef & q_docname );
			if isempty(docs),
				all_matched=0;
				break;
			end;
		end;
			
		if ~all_matched,
			threshold = intracell_strf_getsharpthreshold(probes{i});
		end;
	end;
end;

