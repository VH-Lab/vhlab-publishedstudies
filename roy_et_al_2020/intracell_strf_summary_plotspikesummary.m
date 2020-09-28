function intracell_strf_summary_plotspikesummary(spikeshape_struct)

c = [0 1 0 ; 1 0 1 ] ; % green for young, magenta for old

agestr = {'y','o'};

currentfigs = get(0,'children');
fig = figure;

spikeshapes = {[] []};
included = {[] []};

t_master = vlt.data.colvec(-0.005:0.0001:0.005);
plotindex = 1;

all_spikekink_values = [];
all_fullwidthhalfmax_values = [];
all_maxdvdt_values = [];

for i=1:numel(spikeshape_struct),
	all_spikekink_values(end+1) = spikeshape_struct(i).spike_summary.median_spikekink_vm;
	all_fullwidthhalfmax_values(end+1) = spikeshape_struct(i).spike_summary.median_fullwidthhalfmaximum;
	all_maxdvdt_values(end+1) = spikeshape_struct(i).spike_summary.median_max_dvdt;
	if spikeshape_struct(i).spike_summary.number_of_spikes>15,
		included{1+1-spikeshape_struct(i).young}(end+1) = i;
		vlt.plot.supersubplot(fig,3,3,plotindex);
		plot(spikeshape_struct(i).spike_summary.sample_times, spikeshape_struct(i).spike_summary.mean_spikewave,...
			'color',c(1+1-spikeshape_struct(i).young,:),'linewidth',2);
		title([spikeshape_struct(i).name ', ' spikeshape_struct(i).reference ' ' agestr{1+1-spikeshape_struct(i).young}]);
		spikeshapes{1+1-spikeshape_struct(i).young}(:,end+1) = interp1(spikeshape_struct(i).spike_summary.sample_times(:),...
				spikeshape_struct(i).spike_summary.mean_spikewave(:),t_master,'linear');
		box off;
		plotindex = plotindex + 1;
	end;
end;

added_figs = setdiff(get(0,'children'),currentfigs);

numbers = [];
for i=1:numel(added_figs),
	numbers(i) = get(added_figs(i),'Number');
end;

[numbers_sorted,sortindexes] = sort(numbers);

for i=1:numel(numbers_sorted),
	set(numbers_sorted(i),'tag',['SpikeWave_Fig_' int2str(i)]);
end;

 % want to plot
 %  plot with average data
 %  maxDVDT
 %  kinkVoltage
 %  fullwidthhalfmax

fig = figure('tag','spikewidth_stats_fig');

subplot(2,2,1);

plot(t_master(:),nanmean(spikeshapes{1},2)','linewidth',2,'color',c(1,:));
hold on;
mean_coords = vlt.data.colvec(nanmean(spikeshapes{1},2)');
stderrpatch_coords = vlt.data.colvec(vlt.data.nanstderr(spikeshapes{1}'));
good_coords = find(~isnan(stderrpatch_coords));
p1 = patch([t_master(good_coords(:)); t_master(good_coords(end:-1:1))],[mean_coords(good_coords(:))+stderrpatch_coords(good_coords(:)); mean_coords(good_coords(end:-1:1))-stderrpatch_coords(good_coords(end:-1:1))], c(1,:))
set(p1,'EdgeAlpha',0,'FaceAlpha',0.5);
plot(t_master(:),nanmean(spikeshapes{2},2)','linewidth',2,'color',c(2,:));
mean_coords = vlt.data.colvec(nanmean(spikeshapes{2},2)');
stderrpatch_coords = vlt.data.colvec(vlt.data.nanstderr(spikeshapes{2}'));
good_coords = find(~isnan(stderrpatch_coords));
p2 = patch([t_master(good_coords(:)); t_master(good_coords(end:-1:1))],[mean_coords(good_coords(:))+stderrpatch_coords(good_coords(:)); mean_coords(good_coords(end:-1:1))-stderrpatch_coords(good_coords(end:-1:1))], c(2,:))
set(p2,'EdgeAlpha',0,'FaceAlpha',0.5);

xlabel('Time(s)');
ylabel('Membrane potential (V)');
box off
axis([-0.0030 0.0030 0 0.08])

subplot(2,2,2);
vlt.plot.plotbargraphwithdata({ all_spikekink_values(included{1}) all_spikekink_values(included{2}) },'color',[0 0 0]);
xlabel('Naive/Experienced');
ylabel('Spike kink (V)');
[h,pkink] = ttest2(all_spikekink_values(included{1}), all_spikekink_values(included{2}));
title(['T-test N/E kink: ' num2str(pkink)])
box off;

subplot(2,2,3);
vlt.plot.plotbargraphwithdata({ all_fullwidthhalfmax_values(included{1}) all_fullwidthhalfmax_values(included{2}) },'color',[0 0 0]);
xlabel('Naive/Experienced');
ylabel('FWHM (V)');
[h,pfwhm] = ttest2(all_fullwidthhalfmax_values(included{1}), all_fullwidthhalfmax_values(included{2}));
title(['T-test N/E FWHM: ' num2str(pfwhm)])
box off;

subplot(2,2,4);
vlt.plot.plotbargraphwithdata({ all_maxdvdt_values(included{1}) all_maxdvdt_values(included{2}) },'color',[0 0 0]);
xlabel('Naive/Experienced');
ylabel('Max DV/DT (V/s)');
[h,pdvdt] = ttest2(all_maxdvdt_values(included{1}), all_maxdvdt_values(included{2}));
title(['T-test N/E maxdvdt: ' num2str(pdvdt)])
box off;


