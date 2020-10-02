function threshold = intracell_strf_getsharpthreshold(sharpprobe)
% INTRACELL_STRF_GETSHARPTHRESHOLD Graphically choose the threshold(s) for a sharp electrode recording
%
% THRESHOLD = INTRACELL_STRF_GETSHARPTHRESHOLD(SHARP_PROBE)
%
% Loads the data from the probe SHARP_PROBE and prompts the user to draw it graphically.
%

if ~isa(sharpprobe,'ndi.probe.timeseries.mfdaq'),
	error(['Expected an ndi.probe.timeseries.mfdaq object for SHARP_PROBE']);
end

  % how to handle multiple epochs? Multiple thresholds? OK

threshold = [];

et = epochtable(sharpprobe);

E = sharpprobe.session;

q_projvardef = ndi.query(intracell_strf_projectvardef);
q_docname = ndi.query('ndi_document.name','exact_string','Epoch spike threshold','');
q_elementid = ndi.query('','depends_on','element_id',sharpprobe.id());

for n=1:numel(et),

	% remove any previous threshold calls for this epoch
        q_epochid = ndi.query('epochid','exact_string',et(n).epoch_id,'');
        thresh_doc = E.database_search(q_elementid & q_projvardef & q_docname & q_epochid);
	E.database_rm(thresh_doc);

	f=figure;
	
	[data,t] = readtimeseries(sharpprobe,et(n).epoch_id,0,Inf);
	plot(t,data);
	xlabel('Time(s)');
	ylabel('Voltage(V)');
	title(['Click a Y location to choose a threshold']);
	drawnow;
	[x,threshold(n)] = ginput(1);

	pdef = intracell_strf_projectvardef;
	newdoc = E.newdocument('ndi_document_projectvar',pdef{:},'projectvar.data',threshold(n),'epochid',et(n).epoch_id,...
		'ndi_document.name','Epoch spike threshold');
	newdoc = newdoc.set_dependency_value('element_id',sharpprobe.id());
	E.database_add(newdoc);

	close(f);
end;


