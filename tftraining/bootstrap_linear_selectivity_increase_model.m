function [slope_dist, training_types, alphas_dist ] = bootstrap_linear_selectivity_increase_model(data, simulations)
% BOOTSTRAP_LINEAR_SELECTIVITY_INCREASE_MODEL - Bootstrap simulations for the linear increase model
%
%   [SLOPE_DIST, ALPHAS_DIST] = BOOTSTRAP_LINEAR_SELECTIVITY_INCREASE_MODEL(DATA, SIMULATIONS)
%
%   Performs SIMULATIONS bootstrap simulations to obtain statistics on the model parameters
%   for LINEAR_SELECTIVITY_INCREASE_MODEL.
% 
%   See also: LINEAR_SELECTIVITY_INCREASE_MODEL

slope_dist = [];
alphas_dist = [];

TT = unique(data(:,2)); % training types


for s=1:simulations,
	data_bs = [];
	
	for tt=1:length(TT),
		TT_inds = find(data(:,2)==TT(tt));
		timepoints = unique(data(TT_inds,3));
		for tp=1:length(timepoints),
			timepoints_inds = find(data(TT_inds,3)==timepoints(tp));
			animal_numbers = unique(data(TT_inds(timepoints_inds),4));
			for an=1:length(animal_numbers),
				animal_number_inds = find(data(TT_inds(timepoints_inds),4) == animal_numbers(an));

				% now draw from these points with replacement

				new_indexes = randi(numel(animal_number_inds), numel(animal_number_inds), 1);
				%new_indexes = 1:length(animal_number_inds);

				data_bs = [data_bs ; data(TT_inds(timepoints_inds(animal_number_inds(new_indexes))), :)];
			end;
		end;
	end;

	[slope_dist(s,:),training_types, alphas_dist(s,:)] = linear_selectivity_increase_model(data_bs);

	if any(abs(slope_dist(s,:)) > 1e3), 
		disp(['Got weird value, do not know how to handle it.']);
		keyboard;
	end;
end;

