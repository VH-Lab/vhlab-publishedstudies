function [out] = intracell_strf_residual2waves(E, vmresp_resid_doc)
% INTRACELL_STRF_RESIDUAL2WAVES - read time, raw waves, simulated waves, and residual waves from 'vmresponseresiduals' ndi_document
%
% [OUT] = INTRACELL_STRF_RESIDUAL2WAVES(E, VMRESP_RESID_DOC)
%
% Given an NDI_DOCUMENT of type 'vmresponseresiduals.json' and NDI_EXPERIMENT object E, this function reads the waves TT,
% raw_data, VV, rawer_data, and the residual res from the binary fork. These variables are returned in a structure, OUT.
%
%

if ~isempty(vmresp_resid_doc),
	vmresp_binarydoc = E.database_openbinarydoc(vmresp_resid_doc{1});
	[Y,X] = vhsb_read(vmresp_binarydoc,-Inf,Inf);
	vmresp_binarydoc = E.database_closebinarydoc(vmresp_binarydoc);

	% now unpack
	samples_per_trace = vmresp_resid_doc{1}.document_properties.vmneuralresponseresiduals.parameters.samples_per_trace;
	samples_per_trace_cumsum = [0; cumsum(samples_per_trace(:))];
	gof = vmresp_resid_doc{1}.document_properties.vmneuralresponseresiduals.goodness_of_fit;

	for i=1:numel(samples_per_trace),
		TT{i} = X(1+samples_per_trace_cumsum(i):samples_per_trace_cumsum(i+1),1);
		raw_data{i} = Y(1+samples_per_trace_cumsum(i):samples_per_trace_cumsum(i+1),1);
		VV{i} = Y(1+samples_per_trace_cumsum(i):samples_per_trace_cumsum(i+1),2);
		rawer_data{i} = Y(1+samples_per_trace_cumsum(i):samples_per_trace_cumsum(i+1),3);
		res{i} = Y(1+samples_per_trace_cumsum(i):samples_per_trace_cumsum(i+1),4);
		spike_data{i} = Y(1+samples_per_trace_cumsum(i):samples_per_trace_cumsum(i+1),5);
	end;
end;

out = var2struct('TT','raw_data','VV','rawer_data','res', 'spike_data', 'gof');

