function s = neiltf_dirsign(tfs,responses,anchor_tfs)
% NEILTF_DIRSIGN = Find whether the TFS shown to a cell are "positive" or "negative" based on an anchor
%
%   S = NEILTF_DIRSIGN(TFS, RESPONSES, ANCHOR_TFS)
%
%   Examines the responses at the ANCHOR_TFS to determine the "sign" of 
%   temporal frequency stimulation. It is assumed that the sum of responses to the
%   anchor tfs is "positive", and the TF axis might need to be reversed (multiplied by negative 1)
%   if that is not true.
%
%   S is 1 if the sum of the responses in the anchor temporal frequencies is greater in the positive direction
%   S is -1 if the sum of the responses in the anchor temporal frequencies is greater in the negative direction

[lia,locb]=ismember(anchor_tfs,tfs);

if ~any(lia),
	error(['All anchor tfs are not present in the tfs that were run']);
end;

current_pos = sum(responses(locb));

[lia,locb]=ismember(-anchor_tfs,tfs);

if ~any(lia),
	error(['All anchor tfs are not present in the tfs that were run']);
end;

current_neg = sum(responses(locb));

s = 1;

if current_neg>current_pos, % then negative
	s = -1;
end;

