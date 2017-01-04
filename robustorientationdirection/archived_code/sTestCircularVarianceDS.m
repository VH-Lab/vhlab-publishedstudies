function sTestCircularVarianceDS(varargin)
% sTestCircularVarianceDS  Compare DSI vs. 1 - Dir Circular Variance for measuring orientation selectivity
%
%   Produces a simulation of direction-selective responses for underlying direction selectivity values
%   ranging from 0.05 to 1.
%
%   In the first figure, the raw underlying direction selectivity curves are plotted.
%
%   In the second figure, DSI and 1-DirCirVar values for 5 example simulations at each underlying DSI
%   value are plotted. The mean DSI and 1-DirCirVar values for 25*5 example simulations at each
%   underlying DSI are shown.
%
%   In the third figure, the average standard deviation of DSI and 1-DirCirVar values for 25 runs of
%   5 simulations.


dis = [];
di_theory = [];
di_theory_all = [];
dcvs = [];
dcvs_all = [];
dis_all = [];

numsims = 25;

num_repeats_per_sim = 5;

assign(varargin{:});

theory_curve_figure = figure;
 
for k=1:numsims,
    disp(['Starting simulation run ' int2str(k) ' of ' int2str(numsims) '.']);
    for i=1:21,
        output = OriDirCurveDemo('Rp',10,'Rn',10-(i-1)/2,'Rsp',0,'sigma',20,...
			'doplotting',0,'dofitting',1,'anglestep',22.5,'noise_level',0);
	[dummy,real_fit] = otfit_carandini_err([output.Rsp output.Rp output.Opref output.sigma output.Rn],0:359);
	if k==1,
		figure(theory_curve_figure);
		hold on;
		plot(0:359,real_fit);
	end;
	di_t = compute_directionindex(0:359,real_fit);
        for j=1:num_repeats_per_sim,  
            output = OriDirCurveDemo('Rp',10,'Rn',10-i/2,'Rsp',0,'sigma',20,'Opref',360*rand,...
			'doplotting',0,'dofitting',0,'anglestep',22.5,'noise_level',5,'numTrials',4);
            di_theory(i,j) = di_t;
            di_theory_all(i,j+(k-1)*num_repeats_per_sim) = di_t;
            dis(i,j) = compute_directionindex(output.measured_angles,output.dirmean);
            dis_all(i,j+(k-1)*num_repeats_per_sim) = compute_directionindex(output.measured_angles,output.dirmean);
            dcvs(i,j) = compute_dircircularvariance(output.measured_angles,output.dirmean);
            dcvs_all(i,j+(k-1)*num_repeats_per_sim) = compute_dircircularvariance(output.measured_angles,output.dirmean);
        end;
    end;
    std_2(k,:) = std(dis,0,2)';
    std_4(k,:) = std(1-dcvs,0,2)';
    if k==numsims,
	%plot forward percentile ranges
	dis_conf_90 = []; dis_conf_75 = [];
	dis_conf_25 = []; dis_conf_10 = [];
	dcvs_conf_90 = []; dcvs_conf_75 = [];
	dcvs_conf_25 = []; dcvs_conf_10 = [];
	for i=1:size(dcvs_all,1),
		dis_conf_90(i) = prctile(dis_all(i,:),90);
		dis_conf_75(i) = prctile(dis_all(i,:),75);
		dis_conf_25(i) = prctile(dis_all(i,:),25);
		dis_conf_10(i) = prctile(dis_all(i,:),10);
		dcvs_conf_90(i) = prctile(1-dcvs_all(i,:),90);
		dcvs_conf_10(i) = prctile(1-dcvs_all(i,:),10);
		dcvs_conf_75(i) = prctile(1-dcvs_all(i,:),75);
		dcvs_conf_25(i) = prctile(1-dcvs_all(i,:),25);
	end;
	figure;
	patch([di_theory(:,1);di_theory(end:-1:1,1)],[dis_conf_10 dis_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(di_theory(:,1),median(dis_all,2),'k-','linewidth',2); % lines
	plot(di_theory(:,1),dis_conf_75,'k-','linewidth',2); % lines
	plot(di_theory(:,1),dis_conf_25,'k-','linewidth',2); % lines
	ylabel('DSI values');
	xlabel('Underlying direction selectivity');
	axis([-0.05 1.05 0 1.5]);
	figure;
	patch([di_theory(:,1);di_theory(end:-1:1,1)],[dcvs_conf_10 dcvs_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(di_theory(:,1),median(1-dcvs_all,2),'k-','linewidth',2); % lines
	plot(di_theory(:,1),dcvs_conf_75,'k-','linewidth',2); % lines
	plot(di_theory(:,1),dcvs_conf_25,'k-','linewidth',2); % lines
	ylabel('DCVS values');
	xlabel('Underlying direction selectivity');
	axis([0 1.05 0 1.5]);
	keyboard;

	% now go in the reverse direction
	bins_dis = (0:0.05:1.5)-0.025;
	dis_theory_conf_90 = hist_percentile(bins_dis,dis_all,di_theory_all,90);
	dis_theory_conf_75 = hist_percentile(bins_dis,dis_all,di_theory_all,75);
	dis_theory_conf_50 = hist_percentile(bins_dis,dis_all,di_theory_all,50);
	dis_theory_conf_25 = hist_percentile(bins_dis,dis_all,di_theory_all,25);
	dis_theory_conf_10 = hist_percentile(bins_dis,dis_all,di_theory_all,10);

	xaxis_dis = (bins_dis(1:end-1) + bins_dis(2:end)) / 2;
	figure;
	patch([xaxis_dis xaxis_dis(end:-1:1)],[dis_theory_conf_10 dis_theory_conf_90(end:-1:1)],[0.7 0.7 0.7]);
	hold on;
	plot(xaxis_dis,dis_theory_conf_50,'k--','linewidth',2); % lines
	plot(xaxis_dis,dis_theory_conf_75,'k-','linewidth',2); % lines
	plot(xaxis_dis,dis_theory_conf_25,'k-','linewidth',2); % lines
	ylabel('Underlying DSI values');

	bins_dcvs = (0:0.05:1)-0.025;
	dcvs_theory_conf_90 = hist_percentile(bins_dcvs,1-dcvs_all,di_theory_all,90);
	dcvs_theory_conf_75 = hist_percentile(bins_dcvs,1-dcvs_all,di_theory_all,75);
	dcvs_theory_conf_50 = hist_percentile(bins_dcvs,1-dcvs_all,di_theory_all,50);
	dcvs_theory_conf_25 = hist_percentile(bins_dcvs,1-dcvs_all,di_theory_all,25);
	dcvs_theory_conf_10 = hist_percentile(bins_dcvs,1-dcvs_all,di_theory_all,10);

	xaxis_dcvs = (bins_dcvs(1:end-1) + bins_dcvs(2:end)) / 2;
	goodvalues = find(~isnan(dcvs_theory_conf_90));
	figure;
	patch([xaxis_dcvs(goodvalues) xaxis_dcvs(goodvalues(end:-1:1))],...
		[dcvs_theory_conf_10(goodvalues) dcvs_theory_conf_90(goodvalues(end:-1:1))],[0.7 0.7 0.7]);
	hold on;
	plot(xaxis_dcvs,dcvs_theory_conf_50,'k--','linewidth',2); % lines
	plot(xaxis_dcvs,dcvs_theory_conf_75,'k-','linewidth',2); % lines
	plot(xaxis_dcvs,dcvs_theory_conf_25,'k-','linewidth',2); % lines
	ylabel('Underlying DSI values');
	axis([0 1 0 1.05]);
    end;
end;
 
%
x = mean(di_theory,2)

disp(['Real underlying DSI: ' mat2str(x) ]);

