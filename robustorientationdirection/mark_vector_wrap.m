function [params] = mark_vector_wrap(data, response_mtx, spontaneous)
% MARK_VECTOR_WRAP - a wrapper function for mark's vector analysis
%
%   [PARAMS] = MARK_VECTOR_WRAP(DATA, RESPONSE_MTX, SPONTANEOUS)
%
%   Calls CALC_DIRECTION_STATS_VECTORMETHOD_V2
%
%   See that help for the a description of the inputs.  The DATA argument should be a 
%   cell list with 2 entries:
%   the first has the angles as their first column; the other values are ignored.
%   the second argumet should be an ntrial x n_angles list of individual trial responses
%
%   PARAMS is a vector of the scalar outputs of CALC_DIRECTION_STATS_VECTORMETHOD_V2
%   [prefdir p_dirselective p_reverse p_oriselective ]
%   

usemarks = 1;

if usemarks,

	[prefdir, p_dirselective, p_reverse, p_oriselective ] = calc_direction_stats_vectormethod(data{1}(:,1)', data{2}, spontaneous);

	params = [prefdir p_dirselective p_reverse p_oriselective ]'; % make a column vector

else,
	angles = data{1}(:,1)';
	rates = data{2};
	[di, pref, dv] = compute_dirvecconstrainedori(angles, data{1}(:,2)');  % just use mean

	params = [ pref di dv]';

end;
