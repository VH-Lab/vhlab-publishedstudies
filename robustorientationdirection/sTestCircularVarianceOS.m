function output = sTestCircularVarianceOS(varargin)
% sTestCircularVarianceOS  Compare OSI vs. 1 - Circular Variance for measuring orientation selectivity
%
%   sTestCircularVarianceOS
%  
%   Produces a simulation of orientation-selective responses for underlying orientation selectivity values
%   ranging from 0.05 to 1.
%
%   In the first figure, the raw underlying orientation selectivity curves are plotted.
%
%   In the second figure, cumulative distribution of the empirically measured OSI values for
%   100 example simulations at each underlying OSI value are plotted.
%
%   In the third figure, cumulative distribution of the empirically measured 1-CirVar values for
%   100 example simulations at each underlying OSI value are plotted.
%
%   In the fourth figure, the simulation results are presented in reverse: we show the cumulative
%   distribution of the underlying OSI values for empirical OSI values.
% 
%   In the fifth figure, the simulation results are again presented in reverse: we show the cumulative
%   distribution of the underling OSI values for empirical 1-CirVar values.
%
%   Some parameters can be adjusted by providing name/value pairs.
%   PARAMETER:
%   num_repeats_per_stim                 :  Number of repeats for each stimulus (default 100)
%   noise_level                          :  Standard deviation of gaussian noise added to each trial
%                                        :     (default 5, which is 50%)
%   numTrials                            :  Number of trials for each simulated recording (default 4)
%   anglestep                            :  Size of the step in direction angle for each stim (default 22.5)
%   doplots                              |  0/1 Should we plot the figures? (default 1)
%
%   Example:
%   sTestCircularVarianceOS('num_repeats_per_stim',10000,'noise_level',2)
%

num_repeats_per_sim = 100;
noise_level = 5;
numTrials = 4;
anglestep = 22.5;
doplots = 1;
noise_method = 0;

assign(varargin{:});

ois = [];
oi_theory = [];
cvs_theory = [];
cvs = [];

if doplots,
	theory_curve_figure = figure; % the noiseless curve figure
end;

 % Step 1 - simulate curves with 21 steps of orientation selectivity values, plotting noiseless curves as we go
 
for i=1:21,
	% plot the 'noiseless curve'
	[dummy,real_fit] = otfit_carandini_err([10-(i-1)/2 (i-1)/2 40 20 (i-1)/4],0:359);
	if doplots,
		figure(theory_curve_figure);
		hold on;
		plot(0:359,real_fit);
	end;
	oi_t = compute_orientationindex(0:359,real_fit);
	cvs_t = compute_circularvariance(0:359,real_fit);
        for j=1:num_repeats_per_sim,  
		output = OriDirCurveDemo('Rp',(i-1)/2,'Rn',(i-1)/4,'Rsp',10-(i-1)/2,'Opref',360*rand,...
			'sigma',(generate_random_data(1,'gamma',3,6)+10)/1.18,...
			'doplotting',0,'dofitting',0,'anglestep',anglestep,'noise_level',noise_level,'numTrials',numTrials);
		oi_theory(i,j) = oi_t;
		cvs_theory(i,j) = cvs_t;
		ois(i,j) = compute_orientationindex(output.measured_angles,output.dirmean);
		cvs(i,j) = compute_circularvariance(output.measured_angles,output.dirmean);
	end;
end;

  % Step 2 forward percentile ranges, Underyling OSI vs. empirically-measured OSI and vs. empirically-measured CVS
ois_conf_90 = []; ois_conf_75 = [];
ois_conf_25 = []; ois_conf_10 = [];
cvs_conf_90 = []; cvs_conf_75 = [];
cvs_conf_25 = []; cvs_conf_10 = [];
for i=1:size(cvs,1),
	ois_conf_90(i) = prctile(ois(i,:),90);
	ois_conf_75(i) = prctile(ois(i,:),75);
	ois_conf_25(i) = prctile(ois(i,:),25);
	ois_conf_10(i) = prctile(ois(i,:),10);
	cvs_conf_90(i) = prctile(1-cvs(i,:),90);
	cvs_conf_10(i) = prctile(1-cvs(i,:),10);
	cvs_conf_75(i) = prctile(1-cvs(i,:),75);
	cvs_conf_25(i) = prctile(1-cvs(i,:),25);
end;
  % step 2.2 - Underlying OSI vs. empirically-measured OSI

if doplots,
	figure;
	patch([oi_theory(:,1);oi_theory(end:-1:1,1)],[ois_conf_10 ois_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(oi_theory(:,1),median(ois,2),'k-','linewidth',2); % lines
	plot(oi_theory(:,1),ois_conf_75,'k-','linewidth',2); % lines
	plot(oi_theory(:,1),ois_conf_25,'k-','linewidth',2); % lines
	ylabel('OSI values');
	xlabel('Underlying orientation selectivity');
	axis([0.0 1.05 0 1.5]);

	figure;
	patch([oi_theory(:,1);oi_theory(end:-1:1,1)],[cvs_conf_10 cvs_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(oi_theory(:,1),median(1-cvs,2),'k-','linewidth',2); % lines
	plot(oi_theory(:,1),cvs_conf_75,'k-','linewidth',2); % lines
	plot(oi_theory(:,1),cvs_conf_25,'k-','linewidth',2); % lines
	ylabel('1-CVS values');
	xlabel('Underlying orientation selectivity');
	axis([0 1.05 0 1.5]);
end;

% Step 3 now go in the reverse direction, and plot empircally-measured OSI, CVS vs. underlying OSI
bins_ois = (0:0.05:1.5)-0.025;
ois_theory_conf_90 = hist_percentile(bins_ois,ois,oi_theory,90);
ois_theory_conf_75 = hist_percentile(bins_ois,ois,oi_theory,75);
ois_theory_conf_50 = hist_percentile(bins_ois,ois,oi_theory,50);
ois_theory_conf_25 = hist_percentile(bins_ois,ois,oi_theory,25);
ois_theory_conf_10 = hist_percentile(bins_ois,ois,oi_theory,10);
ois_theory_stddev = hist_std(bins_ois,ois,oi_theory);

xaxis_ois = (bins_ois(1:end-1) + bins_ois(2:end)) / 2;

if doplots,
	figure;
	patch([xaxis_ois xaxis_ois(end:-1:1)],[ois_theory_conf_10 ois_theory_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(xaxis_ois,ois_theory_conf_50,'k--','linewidth',2); % lines
	plot(xaxis_ois,ois_theory_conf_75,'k-','linewidth',2); % lines
	plot(xaxis_ois,ois_theory_conf_25,'k-','linewidth',2); % lines
	ylabel('Underlying OSI values');
	xlabel('Empirical OSI value');
end;

bins_cvs = (0:0.05:1)-0.025;
cvs_theory_conf_90 = hist_percentile(bins_cvs,1-cvs,oi_theory,90);
cvs_theory_conf_75 = hist_percentile(bins_cvs,1-cvs,oi_theory,75);
cvs_theory_conf_50 = hist_percentile(bins_cvs,1-cvs,oi_theory,50);
cvs_theory_conf_25 = hist_percentile(bins_cvs,1-cvs,oi_theory,25);
cvs_theory_conf_10 = hist_percentile(bins_cvs,1-cvs,oi_theory,10);
cvs_theory_stddev = hist_std(bins_cvs,1-cvs,oi_theory);

xaxis_cvs = (bins_cvs(1:end-1) + bins_cvs(2:end)) / 2;
goodvalues = find(~isnan(cvs_theory_conf_90));
if doplots,
	figure;
	patch([xaxis_cvs(goodvalues) xaxis_cvs(goodvalues(end:-1:1))],...
	[cvs_theory_conf_10(goodvalues) cvs_theory_conf_90(goodvalues(end:-1:1))],[0.7 0.7 0.7]);
	hold on;
	plot(xaxis_cvs,cvs_theory_conf_50,'k--','linewidth',2); % lines
	plot(xaxis_cvs,cvs_theory_conf_75,'k-','linewidth',2); % lines
	plot(xaxis_cvs,cvs_theory_conf_25,'k-','linewidth',2); % lines
	xlabel('Empirical 1-CirVar value');
	ylabel('Underlying OSI values');
	axis([0 1 -0.05 1.05]);
end;
 
%
x = mean(oi_theory,2);
y = mean(cvs_theory,2);

if doplots,
	disp(['Real underlying OSI: ' mat2str(x,3) ]);
	disp(['Real underlying 1-CirVar: ' mat2str(1-y,3)]);
end;

output = workspace2struct;
