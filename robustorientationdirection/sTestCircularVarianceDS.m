function output = sTestCircularVarianceDS(varargin)
% sTestCircularVarianceDS  Compare DSI vs. 1 - Circular Variance for measuring direction selectivity
%
%   sTestCircularVarianceDS
%  
%   Produces a simulation of direction-selective responses for underlying direction selectivity values
%   ranging from 0.05 to 1.
%
%   In the first figure, the raw underlying direction selectivity curves are plotted.
%
%   In the second figure, cumulative distribution of the empirically measured DSI values for
%   100 example simulations at each underlying DSI value are plotted.
%
%   In the third figure, cumulative distribution of the empirically measured 1-DirCirVar values for
%   100 example simulations at each underlying DSI value are plotted.
%
%   In the fourth figure, the simulation results are presented in reverse: we show the cumulative
%   distribution of the underlying DSI values for empirical DSI values.
% 
%   In the fifth figure, the simulation results are again presented in reverse: we show the cumulative
%   distribution of the underling DSI values for empirical 1-DirCirVar values.
%
%   The number of simulations run can be adjusted from 100 by giving an input argument:
% 
%   sTestCircularVarianceDS(NUMSIMS)
%
%   Some parameters can be adjusted by providing name/value pairs.
%   PARAMETER:
%   num_repeats_per_stim                 :  Number of repeats for each stimulus (default 100)
%   noise_level                          :  Standard deviation of gaussian noise added to each trial 
%                                        :     (default 5, which is 50%)
%   numTrials                            :  Number of trials for each simulated recording (default 7)
%   anglestep                            :  Size of the step in direction angle for each stim (default 22.5)
%   doplots                              |  0/1 Should we plot the figures? (default 1)
%
%   Example:
%   sTestCircularVarianceDS('num_repeats_per_stim',10000,'noise_level',2)


num_repeats_per_sim = 100;
numTrials = 7;
noise_level = 5;
anglestep = 22.5;
doplots = 1;


assign(varargin{:});

dis = [];
di_theory = [];
dcvs_theory = [];
dcvs = [];

if doplots,
	theory_curve_figure = figure; % the noiseless curve figure
end;

 % Step 1 - simulate curves with 21 steps of direction selectivity values, plotting ndiseless curves as we go
 
for i=1:21,
	% plot the 'ndiseless curve'
	[dummy,real_fit] = otfit_carandini_err([0 10 40 20 10-(i-1)/2],0:359);
	if doplots,
		figure(theory_curve_figure);
		hold on;
		plot(0:359,real_fit);
	end;
	di_t = compute_directionindex(0:359,real_fit);
	dcvs_t = compute_dircircularvariance(0:359,real_fit);
        for j=1:num_repeats_per_sim,  
		output = OriDirCurveDemo('Rp',10,'Rn',10-(i-1)/2,'Rsp',0,'Opref',360*rand,...
			'sigma',(generate_random_data(1,'gamma',3,6)+10)/1.18,...
			'doplotting',0,'dofitting',0,'anglestep',anglestep,'noise_level',noise_level,'numTrials',numTrials);
		di_theory(i,j) = di_t;
		dcvs_theory(i,j) = dcvs_t;
		dis(i,j) = compute_directionindex(output.measured_angles,output.dirmean);
		dcvs(i,j) = compute_dircircularvariance(output.measured_angles,output.dirmean);
	end;
end;

  % Step 2 forward percentile ranges, Underyling DSI vs. empirically-measured DSI and vs. empirically-measured CVS
dis_conf_90 = []; dis_conf_75 = [];
dis_conf_25 = []; dis_conf_10 = [];
dcvs_conf_90 = []; dcvs_conf_75 = [];
dcvs_conf_25 = []; dcvs_conf_10 = [];
for i=1:size(dcvs,1),
	dis_conf_90(i) = prctile(dis(i,:),90);
	dis_conf_75(i) = prctile(dis(i,:),75);
	dis_conf_25(i) = prctile(dis(i,:),25);
	dis_conf_10(i) = prctile(dis(i,:),10);
	dcvs_conf_90(i) = prctile(1-dcvs(i,:),90);
	dcvs_conf_10(i) = prctile(1-dcvs(i,:),10);
	dcvs_conf_75(i) = prctile(1-dcvs(i,:),75);
	dcvs_conf_25(i) = prctile(1-dcvs(i,:),25);
end;
  % step 2.2 - Underlying DSI vs. empirically-measured DSI

if doplots,
	figure;
	patch([di_theory(:,1);di_theory(end:-1:1,1)],[dis_conf_10 dis_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(di_theory(:,1),median(dis,2),'k-','linewidth',2); % lines
	plot(di_theory(:,1),dis_conf_75,'k-','linewidth',2); % lines
	plot(di_theory(:,1),dis_conf_25,'k-','linewidth',2); % lines
	ylabel('DSI values');
	xlabel('Underlying direction selectivity');
	axis([0.0 1.05 0 1.5]);

	figure;
	patch([di_theory(:,1);di_theory(end:-1:1,1)],[dcvs_conf_10 dcvs_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(di_theory(:,1),median(1-dcvs,2),'k-','linewidth',2); % lines
	plot(di_theory(:,1),dcvs_conf_75,'k-','linewidth',2); % lines
	plot(di_theory(:,1),dcvs_conf_25,'k-','linewidth',2); % lines
	ylabel('1-DCV values');
	xlabel('Underlying direction selectivity');
	axis([0 1.05 0 1.5]);
end;

% Step 3 now go in the reverse direction, and plot empircally-measured DSI, CVS vs. underlying DSI
bins_dis = (0:0.05:1.5)-0.025;
dis_theory_conf_90 = hist_percentile(bins_dis,dis,di_theory,90);
dis_theory_conf_75 = hist_percentile(bins_dis,dis,di_theory,75);
dis_theory_conf_50 = hist_percentile(bins_dis,dis,di_theory,50);
dis_theory_conf_25 = hist_percentile(bins_dis,dis,di_theory,25);
dis_theory_conf_10 = hist_percentile(bins_dis,dis,di_theory,10);
dis_theory_stddev = hist_std(bins_dis,dis,di_theory);

xaxis_dis = (bins_dis(1:end-1) + bins_dis(2:end)) / 2;
if doplots,
	figure;
	patch([xaxis_dis xaxis_dis(end:-1:1)],[dis_theory_conf_10 dis_theory_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(xaxis_dis,dis_theory_conf_50,'k--','linewidth',2); % lines
	plot(xaxis_dis,dis_theory_conf_75,'k-','linewidth',2); % lines
	plot(xaxis_dis,dis_theory_conf_25,'k-','linewidth',2); % lines
	ylabel('Underlying DSI values');
	xlabel('Empirical DSI value');
end;

bins_dcvs = (0:0.05:1)-0.025;
dcvs_theory_conf_90 = hist_percentile(bins_dcvs,1-dcvs,di_theory,90);
dcvs_theory_conf_75 = hist_percentile(bins_dcvs,1-dcvs,di_theory,75);
dcvs_theory_conf_50 = hist_percentile(bins_dcvs,1-dcvs,di_theory,50);
dcvs_theory_conf_25 = hist_percentile(bins_dcvs,1-dcvs,di_theory,25);
dcvs_theory_conf_10 = hist_percentile(bins_dcvs,1-dcvs,di_theory,10);
dcvs_theory_stddev = hist_std(bins_dcvs,1-dcvs,di_theory);

xaxis_dcvs = (bins_dcvs(1:end-1) + bins_dcvs(2:end)) / 2;
goodvalues = find(~isnan(dcvs_theory_conf_90));
if doplots,
	figure;
	patch([xaxis_dcvs(goodvalues) xaxis_dcvs(goodvalues(end:-1:1))],...
		[dcvs_theory_conf_10(goodvalues) dcvs_theory_conf_90(goodvalues(end:-1:1))],[0.7 0.7 0.7]);
	hold on;
	plot(xaxis_dcvs,dcvs_theory_conf_50,'k--','linewidth',2); % lines
	plot(xaxis_dcvs,dcvs_theory_conf_75,'k-','linewidth',2); % lines
	plot(xaxis_dcvs,dcvs_theory_conf_25,'k-','linewidth',2); % lines
	xlabel('Empirical 1-DirCirVar value');
	ylabel('Underlying DSI values');
	axis([0 1 -0.05 1.05]);
end;
 
%
x = mean(di_theory,2);
y = mean(dcvs_theory,2);

if doplots,
	disp(['Real underlying DSI: ' mat2str(x,3) ]);

	disp(['Real underlying 1-DirCirVar: ' mat2str(1-y,3)]);
end;

output = workspace2struct;
