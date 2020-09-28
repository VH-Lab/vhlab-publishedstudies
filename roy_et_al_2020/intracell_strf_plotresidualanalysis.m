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

iapp = ndi_app(E,'vhlab_voltage2firingrate');

 % need to output: neuralresponseresiduals.json

for n=1:N,

	vmresp_resid_doc = E.database_search( ndi_query('','depends_on','element_id',ndi_vm_corrected_element.id()) & ...
	ndi_query('','isa','vmneuralresponseresiduals.json','') & ndi_query('ndi_document.name','exact_string','Preferred response','') & ...
	ndi_query('vmneuralresponseresiduals.element_epochid','exact_string',et(n).epoch_id,''))

	if ~isempty(vmresp_resid_doc),
		out = intracell_strf_residual2waves(E, vmresp_resid_doc);
		vlt.data.struct2var(out);
	else,
		return; % noelement to do
	end;

	if displayresults,
		figure;
		for i=1:numel(TT)
			ax(1) = subplot(3,numel(TT),i);
			plot(TT{i},raw_data{i});
			xlabel('Time(s)');
			ylabel('Membrane potential (V)');
			box off;
			hold on
			plot(TT{i},VV{i},'g-');
			ax(2) = subplot(3,numel(TT),i+1*numel(TT));
			plot(TT{i},rawer_data{i},'r');
			hold on; 
			plot(TT{i},spike_data{i},'g');
			box off;
			ax(3) = subplot(3,numel(TT),i+2*numel(TT));
			plot(TT{i},res{i},'k');
			box off;
			linkaxes(ax,'x');
			title(['GOF: ' num2str(gof(i))]);
		end;
	end;

end; % loop over epochs

end % function

