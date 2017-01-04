function [prefdir p_selective p_reverse vectors vectormags vectormags_scaled] = calc_direction_stats_vectormethod(angles,response_mtx,spontaneous)
% [prefdir p_selective p_reverse vectors vectormags] = calc_direction_stats_vectormethod(angles,response_mtx,spontaneous)
% Uses the vector method to test direction selectivity of neural responses.
%
% ----Inputs----
% ANGLES: List of experimental angles (Cartesian)
% RESPONSE_MTX: An ntrials-by-nangles matrix of responses in individual experimental trials
%
% ----Outputs----
% PREFDIR: The preferred direction inferred from the vector average of individual trials
% P_SELECTIVE: Uses Hotelling's T^2 test on direction vectors to get a p value for selectivity
% P_REVERSE: Evaluates the distribution of direction vectors to measure the probability that the true direction prefernce is the reverse
% of the reported direction preference.
% VECTORS: ntrials-by-2 matrix of direction vectors
% VECTORMAGS: ntrials-length list of vector magnitudes
% VECTORMAGS_SCALED: ntrials-length list of vector magnitudes rescaled by logit transformation
%  --This is important only to observe the Gaussian distribution of vector magnitudes that is produced by this analysis

% MM 11/14/12

if(~exist('spontaneous','var'))
  q = mean(response_mtx);
  sponteneous = min(q);
end

ntrials = size(response_mtx,1);

% Subtract off the spontaneous response (is this absolutely necessary??)

response_mtx = response_mtx - spontaneous;
%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate p value for direction selectivity by calculating a response vector on each trial and using Hotelling's T^2 test to measure
% significance
angles_polar = (angles/360)*2*pi;

r_trial = nan*ones(ntrials,1);
for i_trial = 1:ntrials
  rates = response_mtx(i_trial,:);
  r = (rates * exp(i*angles_polar)') / sum(abs(rates));
  r_trial(i_trial) = r;
end

x = real(r_trial);
y = -imag(r_trial);
q = x.^2 + y.^2;
[q,magnitude] = cart2pol(x,y);
theta = rad2deg(q);
theta(theta<0) = 360 + theta(theta<0);

% Do stats on this distribution to ask whether the cell is directionally-selective
X = [x y];
[H,p_selective]=hotellingt2test(X,[0 0]);

% Calculate the mean vector to determine direction preference
mean_x = mean(x);
mean_y = mean(y);
q = rad2deg(atan2(mean_y,mean_x));
q(q<0) = 360 + q;
prefdir = q;

vectors = [x y];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the probability that true direction preference is reverse of the calculated direction preference

%%%%%%
% Step 1: Calculate the preferred axis in [0 180] space: Convert data to [0 180] --> calculate vector
x360 = x;
y360 = y;

angles_180 = angles;
ind = angles_180>=180;
angles_180(ind) = angles_180(ind)-180;
angles_polar_180 = (angles_180/180)*2*pi;

r_trial = nan*ones(ntrials,1);
for i_trial = 1:ntrials
  rates = response_mtx(i_trial,:);
  r = (rates * exp(i*angles_polar_180)') / sum(abs(rates));
  r_trial(i_trial) = r;
end

x = real(r_trial);
y = -imag(r_trial);
% NOTE: These points map 180-degree visual space onto a 360-degree plane. Thus, whatever we calculate for the angle of the mean vector, we
% need to divide by 2.
q = rad2deg(cart2pol(mean(x),mean(y)));
if(q<0)
  q = 360+q;
end
theta180 = q/2;

b = tan(deg2rad(theta180));

%%%%%%
% Step 2: Determine the magnitude of the projection of each vector onto the orientation axis

% Convert to polar, subtract of theta180, then convert back to Cartesian
x = x360;
y = y360;
[q r] = cart2pol(x,y);
th = rad2deg(q);
th = th-theta180;
x_adj = pol2cart(deg2rad(th),r);
if(mean(x_adj)<0)
  x_adj = -x_adj;
end

vectormags = x_adj;

%%%%%%
% Step 3: Use the mean and std of x_adj to determine the probability that actual preferred direction is the reverse of what we calculated

% First need to rescale this so that the distribution is Gaussian. The reason it's not already Gaussian is that vector values are
% constrained to be in the range of [-1 1]. So how to rescale these? Answer: (1) Rescale to [0 1]; (2) Perform logit transformation, where
% logit(x) = x/(1-x). The logit transformation is used to rescale probabilities, which are constrained to be [0 1], so that their range is
% [-inf inf]. It seems to work well here.

% (1) Rescale to [0 1]
q = (x_adj+1)/2;

% (2) Calculate logit
logit_x_adj = real(log(q ./ (1-q)));

vectormags_scaled = logit_x_adj;

% (3) Calculate p value from the rescaled values
p_reverse = normcdf(0,mean(logit_x_adj),std(logit_x_adj));

