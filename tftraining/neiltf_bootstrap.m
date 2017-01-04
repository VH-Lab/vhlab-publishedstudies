function [sims,blanksims] = neiltf_bootstrap(raw_responses, blank_raw_responses, numsims)
% NEILTF_BOOTSTRAP - perform bootstrap of TF responses
%
%   [SIMS,BLANKSIMS] = NEILTF_BOOTSTRAP(RAW_RESPONSES, BLANK_RAW_RESPONSES, NUMSIMS)
%
%   Performs NUMSIMS bootstrap simulations on RAW_RESPONSES. It is assumed that
%   each column of RAW_RESPONSES corresponds to a different stimulus, and that
%   the rows of RAW_RESPONSES correspond to trials. The last stimulus is assumed to be
%   the blank.
%
%   The output is SIMS (the mean responses, 1 simulation per row) and BLANKSIMS, the mean
%   responses of the simulated blank stimulus.

sims = [];
blanksims = [];

num_reps = size(raw_responses,1);
num_stims = size(raw_responses,2);

selection_mat_base = repmat(0:num_stims-1,num_reps,1)*num_reps;
  % this plus 1 is the index of the first position of each stimulus response in raw_responses

selection_mat_expanded = repmat(selection_mat_base,1,1,numsims);

random_sel = ceil(rand(num_reps,num_stims,numsims)*num_reps);
random_sel(find(random_sel==0)) = 1; % in case we get exactly zero from rand, very unlikely but possible

sims = squeeze( mean(raw_responses(selection_mat_expanded+random_sel),1) )'; % now each row is 1 sim

blank_random_sel = ceil(rand(num_reps,numsims)*num_reps);
blank_random_sel(find(blank_random_sel==0)) = 1; 

blanksims = mean(blank_raw_responses(blank_random_sel),1)';


