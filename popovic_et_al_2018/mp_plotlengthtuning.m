function output=mp_plotlengthtuning(cellinfo)
% MP_PLOTLENGTHTUNING - plot length tuning information from cells
%
%  OUTPUT = MP_PLOTLENGTHTUNING(CELLINFO)
%
%  Plot CELLINFO that is returned from MP_DONORMSURRANALYSIS
%
% 

struct2var(mp_definestudygroups(cellinfo)); % define variables for study groups

axis_max = -Inf;
axis_min = Inf;

axis_xmax = -Inf;

max_firing_rate_criterion = 1;
distance_exclusion_criteria_max = 50;
distance_exclusion_criteria_min = 31;

N = zeros(1,4);

P = length(myinds);

lengthfigure = figure('tag','Length_LengthTuningResponses');

for p = 1:P,

	subplot(3,P,p);
	hold on;
	mygoodcells = []; % only include responsive cells
	for i=1:length(myinds{p}),
		if ~isempty(cellinfo(myinds{p}(i)).length_info.vis_resp_p),
			if (cellinfo(myinds{p}(i)).length_info.vis_resp_p < 0.05) & ( max(cellinfo(myinds{p}(i)).length_info.length_curve(2,4)) >  max_firing_rate_criterion),
				if (numornan(cellinfo(myinds{p}(i)).length_info.distance) > distance_exclusion_criteria_max) | (numornan(cellinfo(myinds{p}(i)).length_info.distance) < distance_exclusion_criteria_min)
					mygoodcells(end+1) = myinds{p}(i);
				end;
			end;
		end;
	end;

	N(p) = length(mygoodcells);
	% now we have all good cells

	length_curves_ind{p} = [];

	length_curve_end_ratio{p} = [];
	length_curve_end220_ratio{p} = [];
	length_curve_endslope{p} = [];
	length_curve_peak_loc{p} = [];
	length_curve_end_resp{p} = [];
	length_curve_halfmax_resp{p} = [];
	length_curve_halfmax_loc{p} = [];
	length_curve_half70_resp{p} = [];
	length_curve_half70_loc{p} = [];

	length_fit_width{p} = [];
	length_fit_b{p} = [];

	for i=1:length(mygoodcells),
		length_curves_ind{p}(end+1,:) = cellinfo(mygoodcells(i)).length_info.length_curve(2,:);
		[peak,length_curve_peak_loc{p}(end+1)] = max( cellinfo(mygoodcells(i)).length_info.length_curve(2,:) );
		interp_x = linspace(cellinfo(mygoodcells(i)).length_info.length_curve(1,1), ...
					cellinfo(mygoodcells(i)).length_info.length_curve(1,end));
		interp_y = interp1(cellinfo(mygoodcells(i)).length_info.length_curve(1,:), cellinfo(mygoodcells(i)).length_info.length_curve(2,:), interp_x, 'linear');
		length_curve_halfmax_loc{p}(end+1) = find(interp_y>=0.5*max(interp_y),1,'first');
		length_curve_halfmax_resp{p}(end+1) = interp_x(length_curve_halfmax_loc{p}(end));
		length_curve_half70_loc{p}(end+1) = find(interp_y>=0.5*0.7*max(interp_y),1,'first');
		length_curve_half70_resp{p}(end+1) = interp_x(length_curve_half70_loc{p}(end));
		length_curve_end_ratio{p}(end+1) = cellinfo(mygoodcells(i)).length_info.length_curve(2,end) / peak;
		length_curve_end220_ratio{p}(end+1) = cellinfo(mygoodcells(i)).length_info.length_curve(2,end) / ...
			(cellinfo(mygoodcells(i)).length_info.length_curve(2,5) + cellinfo(mygoodcells(i)).length_info.length_curve(2,end) );
		[PP,SS]=polyfit(cellinfo(mygoodcells(i)).length_info.length_curve(1,end-3:end), (peak./peak)*cellinfo(mygoodcells(i)).length_info.length_curve(2,end-3:end),1);
		length_curve_endslope{p}(end+1) = PP(1);
		length_curve_end_resp{p}(end+1) = cellinfo(mygoodcells(i)).length_info.length_curve(2,end);
		plot(cellinfo(mygoodcells(i)).length_info.length_curve(1,:),cellinfo(mygoodcells(i)).length_info.length_curve(2,:),'color',[0.5 0.5 0.5],'linewidth',1);
		axis_xmax = max(axis_xmax,max(cellinfo(mygoodcells(i)).length_info.length_curve(1,:)));
		if length(cellinfo(mygoodcells(i)).lengthfit.outputs.fit_responses)>9 & cellinfo(mygoodcells(i)).lengthfit.outputs.r_squared>0.2,
			length_fit_width{p}(end+1) = cellinfo(mygoodcells(i)).lengthfit.outputs.halfwidth;
			length_fit_b{p}(end+1) = cellinfo(mygoodcells(i)).lengthfit.outputs.b;
		end;
		
	end;
	if length(mygoodcells)>1,
		AA=nanmean(length_curves_ind{p});
		BB=nanstderr(length_curves_ind{p});
		h=myerrorbar(cellinfo(mygoodcells(i)).length_info.length_curve(1,:),AA,BB,BB);
		set(h,'color',[0 0 0],'linewidth',1.5);
	end;

	box off;
	title([title_strings{p} ', n=' int2str(N(p))]);
	xlabel('Length');
	ylabel('Spikes/sec');
	A = axis;
	axis_max = max(axis_max,A(4));
	axis_min = min(axis_min,A(3));

	subplot(3,P,P+p);
	hold on;
	aperture_curves_ind{p} = [];
	for i=1:length(mygoodcells),
		if size(cellinfo(mygoodcells(i)).length_info.aperture_curve,1)>1,
			aperture_curves_ind{p}(end+1,:) = cellinfo(mygoodcells(i)).length_info.aperture_curve(2,:);
			plot(cellinfo(mygoodcells(i)).length_info.aperture_curve(1,:),cellinfo(mygoodcells(i)).length_info.aperture_curve(2,:),'color',[0.5 0.5 0.5],'linewidth',1);
		end;
	end;
	if length(mygoodcells)>1,
		AA=nanmean(aperture_curves_ind{p});
		BB=nanstderr(aperture_curves_ind{p});
		h=myerrorbar(cellinfo(mygoodcells(i)).length_info.aperture_curve(1,:),AA,BB,BB);
		set(h,'color',[0 0 0],'linewidth',1.5);
	end;
	box off;
	xlabel('Aperture');
	ylabel('Spikes/sec');
	A=axis;
	axis([A(1) axis_xmax -1 1]);

	subplot(3,P,2*P+p);
	hold on;
	length_curves_ind_norm{p} = [];
	for i=1:length(mygoodcells),
		length_curves_ind_norm{p}(end+1,:) = cellinfo(mygoodcells(i)).length_info.length_curve_norm(2,:);
		plot(cellinfo(mygoodcells(i)).length_info.length_curve_norm(1,:),cellinfo(mygoodcells(i)).length_info.length_curve_norm(2,:),'color',[0.5 0.5 0.5],'linewidth',1);
	end;
	if length(mygoodcells)>1,
		AA=nanmean(length_curves_ind_norm{p});
		BB=nanstderr(length_curves_ind_norm{p});
		h=myerrorbar(cellinfo(mygoodcells(i)).length_info.length_curve_norm(1,:),AA,BB,BB);
		set(h,'color',[0 0 0],'linewidth',1.5);
	end;

	box off;
	xlabel('Length');
	ylabel('Norm Spikes/sec');
	A=axis;
	axis([A(1) axis_xmax -1 1]);

end;

for p=1:P,
	subplot(3,P,p);
	A=axis;
	axis([A(1) axis_xmax axis_min axis_max]);

	subplot(3,P,P+p);
	A=axis;
	axis([A(1) axis_xmax axis_min axis_max]);
end;

lengthfigure_stats = figure('tag','Length_LengthStats1');

for p=1:P,

	binspl = [0:1:9];
	binspl_centers = (binspl(1:end-1) + binspl(2:end)) / 2;

	histNpl = histc(length_curve_peak_loc{p}, binspl);
	histNpl = histNpl(1:end-1) / sum(histNpl(1:end-1)); 

	binser = [-0.1:.1:1.2];
	binser_centers = (binser(1:end-1) + binser(2:end)) / 2;

	histNer = histc(length_curve_end_ratio{p}, binser);
	histNer = histNer(1:end-1) / sum(histNer(1:end-1)); 

	binser2 = [-0.1:0.1:1.2];
	binser2_centers = (binser2(1:end-1) + binser2(2:end)) / 2;

	histNer2 = histc(length_curve_end220_ratio{p}, binser2);
	histNer2 = histNer2(1:end-1) / sum(histNer2(1:end-1)); 

	subplot(3,P,p);

	bar(binspl_centers,histNpl);

	box off;
	title([title_strings{p} ', n=' int2str(N(p))]);
	xlabel('Peak location');
	ylabel('Fraction of neurons');
	axis([0 9 0 1]);

	subplot(3,P,P+p);

	bar(binser_centers,histNer);

	box off;
	title([title_strings{p} ', n=' int2str(N(p))]);
	xlabel('Normalized end ratio');
	ylabel('Fraction of neurons');
	dbin = mean(diff(binser_centers));
	axis([0-dbin binser_centers(end)+dbin 0 1]);

	subplot(3,P,2*P+p);

	bar(binser2_centers,histNer2);

	box off;
	title([title_strings{p} ', n=' int2str(N(p))]);
	xlabel('Normalized 220 ratio');
	ylabel('Fraction of neurons');
	dbin = mean(diff(binser2_centers));
	axis([0-dbin binser2_centers(end)+dbin 0 1]);

end;

[End_ratio, End_ratio_groups] = cell2group(length_curve_end_ratio);
[End220_ratio, End220_ratio_groups] = cell2group(length_curve_end_ratio);

e_ratio_kw = kruskal_wallis_test(length_curve_end_ratio{:}),  % kw because so many points are at ceiling (1)

[e220_ratio_panova, e220_ratio_anovatable] = anova1(End220_ratio, End220_ratio_groups, 'off');

e220_ratio_panova=e220_ratio_panova

lengthfigure_stats2 = figure('tag','Length_LengthStats2');

axis_max1 = -Inf;
axis_min1 = Inf;
axis_max2 = -Inf;
axis_min2 = Inf;

for p=1:P,

	subplot(3,P,p);

	plot(length_curve_endslope{p},'o');
	title([title_strings{p} ', n=' int2str(N(p))]);
	ylabel('Slope of last 4 points (spikes/pixel)');
	xlabel('Cell number');
	box off;
	A = axis;
	axis_max1 = max(axis_max1,A(4));
	axis_min1 = min(axis_min1,A(3));
	

	subplot(3,P,P+p);

	plot(length_curve_end_resp{p},'o');
	title([title_strings{p} ', n=' int2str(N(p))]);
	ylabel('Response of last point (spikes/sec)');
	xlabel('Cell number');
	box off;
	A = axis;
	axis_max2 = max(axis_max2,A(4));
	axis_min2 = min(axis_min2,A(3));

end;

for p=1:P,
	subplot(3,P,p);
	A = axis;
	axis([A(1) A(2) axis_min1 axis_max1]);
	subplot(3,P,P+p);
	A = axis;
	axis([A(1) A(2) axis_min2 axis_max2]);
end;

[Endslope, Endslope_groups] = cell2group(length_curve_endslope);

[Endslope_pvalue, Endslope_anovatable] = anova1(Endslope, Endslope_groups, 'off');

Endslope_pvalue = Endslope_pvalue,

Endslope_pvalue_kw = kruskal_wallis_test(length_curve_endslope{:});

Endslope_pvalue_kw = Endslope_pvalue_kw,


lengthfigure_fitstats = figure('tag','Length_LengthFitStats');

fit_width_mean = [];
fit_width_err = [];
fit_b_mean = [];
fit_b_err = [];
empirical_width_mean = [];
empirical_width_err = [];
empirical_width70_mean = [];
empirical_width70_err = [];

bar_x = [];

for p=1:P,

	fit_width_mean(end+1) = nanmean(length_fit_width{p});
	fit_width_err(end+1) = nanstderr(length_fit_width{p});
	fit_b_mean(end+1) = nanmean(length_fit_b{p});
	fit_b_err(end+1) = nanstderr(length_fit_b{p});
	empirical_width_mean(end+1) = nanmean(length_curve_halfmax_resp{p});
	empirical_width_err(end+1) = nanstderr(length_curve_halfmax_resp{p});
	empirical_width70_mean(end+1) = nanmean(length_curve_half70_resp{p});
	empirical_width70_err(end+1) = nanstderr(length_curve_half70_resp{p});
	bar_x(end+1) = p;

	bins_b = [-1:.1:1];
	bins_b_centers = (bins_b(1:end-1) + bins_b(2:end)) / 2;

	histN_b = histc(length_fit_b{p}, bins_b);
	histN_b = histN_b(1:end-1) / sum(histN_b(1:end-1)); 

	bins_width = [0:5:500];
	bins_width_centers = (bins_width(1:end-1) + bins_width(2:end)) / 2;

	histN_width = histc(length_fit_width{p}, bins_width);
	histN_width = histN_width(1:end-1) / sum(histN_width(1:end-1)); 

	subplot(3,P,p);

	bar(bins_width_centers,histN_width);

	box off;
	title([title_strings{p} ', n=' int2str(length(length_fit_width{p}))]);
	xlabel('Width');
	ylabel('Fraction of neurons');
	axis([0 500 0 1]);

	subplot(3,P,P+p);

	bar(bins_b_centers,histN_b);

	box off;
	title([title_strings{p} ', n=' int2str(length(length_fit_b{p}))]);
	xlabel('Parameter b');
	ylabel('Fraction of neurons');
	axis([-1.1 1.1 0 1]);

	if p==P,
		subplot(3,P,2*P+1);
		h=bar(bar_x,fit_width_mean);
		hold on;
		set(h,'facecolor',[0 0 0]);
		h2 = errorbar(bar_x,fit_width_mean, fit_width_err, fit_width_err);
		set(h2,'LineStyle','none','color',[0 0 0]);
		title(['Fit halfwidth means']);
		xlabel(['Condition']);
		ylabel(['Halfwidth']);
		box off;


		subplot(3,P,2*P+2);
		h=bar(bar_x,fit_b_mean);
		hold on;
		set(h,'facecolor',[0 0 0]);
		h2 = errorbar(bar_x,fit_b_mean,fit_b_err,fit_b_err);
		set(h2,'LineStyle','none','color',[0 0 0]);
		title(['Fit b means']);
		xlabel(['Condition']);
		ylabel(['b']);
		box off;

		subplot(3,P,2*P+3);
		h=bar(bar_x,empirical_width_mean);
		hold on;
		set(h,'facecolor',[0 0 0]);
		h2 = errorbar(bar_x,empirical_width_mean,empirical_width_err, empirical_width_err);
		set(h2,'LineStyle','none','color',[0 0 0]);
		title(['Empirical halfwidth means']);
		xlabel(['Condition']);
		ylabel(['Halfwidth']);
		box off;

		subplot(3,P,2*P+4);
		h=bar(bar_x,empirical_width70_mean);
		hold on;
		set(h,'facecolor',[0 0 0]);
		h2 = errorbar(bar_x,empirical_width70_mean,empirical_width70_err, empirical_width70_err);
		set(h2,'LineStyle','none','color',[0 0 0]);
		title(['Empirical half70 means']);
		xlabel(['Condition']);
		ylabel(['Half 70']);
		box off;

		[x,groups]=cell2group(length_fit_width);
		[p_anova_fit_width,p_anovatable_fit_width,p_anovastats_fit_width] = anova1(x,groups,'off');
		disp(['Fit halfwidth differences ANOVA: ' num2str(p_anova_fit_width)]);

		[x,groups]=cell2group(length_fit_b);
		[p_anova_fit_b,p_anovatable_fit_b,p_anovastats_fit_b] = anova1(x,groups,'off');
		disp(['Fit B differences ANOVA: ' num2str(p_anova_fit_b)]);

		[x,groups]=cell2group(length_curve_halfmax_resp);
		[p_anova_empirical_halfmax,p_anovatable_empirical_halfmax,p_anovastats_empirical_halfmax] = anova1(x,groups,'off');
		disp(['Empirical halfwidth differences ANOVA:' num2str(p_anova_empirical_halfmax)]);

	end;
end;

output = workspace2struct;
output = rmfield(output,{'i','A','p','axis_max','axis_min','axis_max1','axis_min1','axis_max2','axis_min2'});
