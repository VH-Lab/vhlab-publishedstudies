function [sigp,sigpb] = neuralresponsesig_grating(resp, f0f1);
% NEURALRESPONSESIG_GRATING - Given a grating response structure, calculate significance
%
%  [SIGP,SIGPB] = NEURALRESPONSESIG_GRATING(RESP, F0F1)
%
%  Given the response structure to a grating, calculate whether there
%  is significant variation across the stims. If F0F1 is 0, then F0 
%  is used; if F0F1 is 1, then F1 is used.
%
%  SIGP is the probability that there is no variation across the stims.
%  SIGPB is the probability that there is no variation across the stims 
%     and blank.
%
%  Example:  
%     A = findassociate(cells{i},'TFPref1 resp','','');
%     [sigp,sigpb] = neuralresponsesig_grating(A.data,0); % check f0
%
%
%  See also: NEURAL_RESPONSE_SIGNIFICANCE
%

if f0f1==0,
	resp.curve = resp.f0curve{1};
	X = resp.f0vals{1};
	resp.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));

	if isfield(resp,'blank'),
		resp.blankind = resp.blank.f0vals{1};
		resp.blankresp = resp.blank.f0curve(2:end);
	end;
else,
	resp.curve = resp.f1curve{1};
	X = resp.f1vals{1};
	resp.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));

	if isfield(resp,'blank'),
		resp.blankind = resp.blank.f1vals{1};
		resp.blankresp = resp.blank.f1curve(2:end);
	end;
end;

[sigp,sigpb] = neural_response_significance(resp);
