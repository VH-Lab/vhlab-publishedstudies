function [slopes, training_types, alphas, slopes_indiv] = linear_selectivity_increase_model(data)
% LINEAR_DIR_INCREASE_MODEL - Fit a linearly-increasing model of increases of selectivity
%
%   [SLOPES, ALPHAS, SLOPES_INDIV] = LINEAR_SELECTIVITY_INCREASE_MODEL(DATA)
% 
%    Fits the following model to the data:
%
%       DSI(training_type, time_point, animal_number) = alpha_animal_number + slope_training_type * time
%  
%   DATA should be a matrix with each data point, where each row is:
%       DATA(i,:) = [ DSI TRAINING_TYPE TIME_POINT ANIMAL_NUMBER ]
%
%    where TRAINING_TYPE is number code for the training type, TIME_POINT is
%    the time of the sample relative to the beginning of the measurements, and
%    ANIMAL_NUMBER is a unique identifier of each animal (it needs to be unique for each
%    TRAINING_TYPE).
%   

alphas = [];
slopes = [];
slopes_indiv = {};
training_types = [];

TT = unique(data(:,2)); % training types

for t=1:length(TT),
	slopes_indiv{t} = [];
	training_types(end+1) = TT(t);

	tt_inds = find(data(:,2)==TT(t));

	AA = unique(data(tt_inds,4));

	for a=1:length(AA),

		aa_inds = find(data(tt_inds,4)==AA(a));

		[slopes_indiv{t}(end+1),alphas(end+1)] = quickregression(data(tt_inds(aa_inds),3), data(tt_inds(aa_inds),1), 0.05);

	end;

	slopes(end+1) = mean(slopes_indiv{t});
end;

