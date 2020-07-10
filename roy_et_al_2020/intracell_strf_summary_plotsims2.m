function intracell_strf_summary_plotsim(sim_resps, oristruct, vmf_model)

f = figure('tag','simulation_summary');

young = 1;
old = 2;
pref = 2;
null = 3;
di = 1;

plot_var = di;

plot_95_5 = 0;

mn = zeros(4,1);
qrt_low = zeros(4,1);
qrt_high = zeros(4,1);
prc_low = zeros(4,1);
prc_high = zeros(4,1);

di_line_x = {};
di_line_y = {};
bin_edges = [ 0:0.025:1 ];
bin_edges_resp = [ 0:0.5:35 ];
di_line_x_resp = {};
di_line_y_resp = {};
prc_low_p = zeros(4,1);
prc_high_p = zeros(4,1);

[out_young, out_old] = intracell_strf_oriprops2diprefnull(oristruct, vmf_model);

for age1=1:2,
	for age2=1:2,
		index = age1+2*(age2-1);
		mn(index) = mean(sim_resps{age1}{age2}(:,plot_var));
		q = iqr(sim_resps{age1}{age2}(:,plot_var));
		qrt_low(index) = prctile(sim_resps{age1}{age2}(:,plot_var),25);
		qrt_high(index) = prctile(sim_resps{age1}{age2}(:,plot_var),75);
		prc_low(index) = prctile(sim_resps{age1}{age2}(:,plot_var),5);
		prc_high(index) = prctile(sim_resps{age1}{age2}(:,plot_var),95);
		counts = histc(sim_resps{age1}{age2}(:,plot_var),bin_edges);
		[di_line_x{age1}{age2}, di_line_y{age1}{age2}] = hist2line(bin_edges, counts);
		counts_resp = histc(sim_resps{age1}{age2}(:,pref),bin_edges_resp);
		[di_line_x_resp{age1}{age2}, di_line_y_resp{age1}{age2}] = hist2line(bin_edges_resp, counts_resp);
		prc_low_p(index) = prctile(sim_resps{age1}{age2}(:,pref),5);
		prc_high_p(index) = prctile(sim_resps{age1}{age2}(:,pref),95);
	end;
end;

 % indexes are {young,young}, {old, young}, {young, old}, {old, old}

hb = bar([1:4], mn);
set(hb,'facecolor',[0.5 0.5 0.5]);

hold on;

h = myerrorbar([1:4]-0.25,mn,qrt_low-mn,qrt_high-mn);
delete(h(2));
set(h(1),'color',[0 0 0]);
if plot_95_5,
	h = myerrorbar([1:4]-0.25,mn,prc_low-mn,prc_high-mn);
	delete(h(2));
	set(h(1),'color',[0 0 0]);
end;
box off;
axis([0 5 0 1]);

for index=1:4,
	age2 = 1+double(index>2);
	age1 = index-2*(age2-1);
	ys = sim_resps{age1}{age2}(:,plot_var);
	plot(index+0.25+0.02*randn(size(ys)), ys,'ko');
end;

f = figure('tag','simulation_summary_histograms');

scale = 20;

for index = 1:4,
	age2 = 1+double(index>2);
	age1 = index-2*(age2-1);
	hold on;
	plot(2+index + scale*di_line_y{age1}{age2}/10000, di_line_x{age1}{age2},'k-');
	plot(2+index*[1 1], [0 1] ,'k-','linewidth',0.51);
	plot(2+index + [0 scale*10/1000], [1 1],'k-');
	hold on; 
	plot(2+index + 0.5 + [0 0.25], prc_high(index)*[1 1], 'k-'); 
	plot(2+index + 0.5 + [0 0.25], prc_low(index)*[1 1], 'k-'); 
	plot(2+index + 0.5 + mean([0 0.25])*[1 1], [prc_high(index) prc_low(index)],'k-'); 
end;

plot([0.5 0.5 1.5 1.5],[0 mean(out_young(:,1)) mean(out_young(:,1)) 0],'k-');
plot([1 1],[mean(out_young(:,1))+[-1 1]*nanstderr(out_young(:,1))],'k-');
plot(1+0.1*randn(size(out_young(:,1))),out_young(:,1),'ko');

plot(7+[0.5 0.5 1.5 1.5],[0 mean(out_old(:,1)) mean(out_old(:,1)) 0],'k-');
plot(7+[1 1],[mean(out_old(:,1))+[-1 1]*nanstderr(out_old(:,1))],'k-');
plot(8+0.1*randn(size(out_old(:,1))),out_old(:,1),'ko');

box off;

f = figure('tag','simulation_summary_response_histograms');

scale = 40;

for index = 1:4,
	age2 = 1+double(index>2);
	age1 = index-2*(age2-1);
	hold on;
	plot(2+index + scale*di_line_y_resp{age1}{age2}/10000, di_line_x_resp{age1}{age2},'k-');
	plot(2+index + [0 scale*50/10000], [35 35],'k-');
	plot(2+index*[1 1], [0 35] ,'k-','linewidth',0.51);
	hold on; 
	plot(2+index + 0.5 + [0 0.25], prc_high_p(index)*[1 1], 'k-'); 
	plot(2+index + 0.5 + [0 0.25], prc_low_p(index)*[1 1], 'k-'); 
	plot(2+index + 0.5 + mean([0 0.25])*[1 1], [prc_high_p(index) prc_low_p(index)],'k-'); 
end;

plot([0.5 0.5 1.5 1.5],[0 nanmean(out_young(:,4)) nanmean(out_young(:,4)) 0],'k-');
plot([1 1],[nanmean(out_young(:,4))+[-1 1]*nanstderr(out_young(:,4))],'k-');
plot(1+0.1*randn(size(out_young(:,4))),out_young(:,4),'ko');

plot(7+[0.5 0.5 1.5 1.5],[0 nanmean(out_old(:,4)) nanmean(out_old(:,4)) 0],'k-');
plot(7+[1 1],[nanmean(out_old(:,4))+[-1 1]*nanstderr(out_old(:,4))],'k-');
plot(8+0.1*randn(size(out_old(:,4))),out_old(:,4),'ko');

box off;

return;

