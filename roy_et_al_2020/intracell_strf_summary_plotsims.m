function intracell_strf_summary_plotsim(sim_resps)

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

for age1=1:2,
	for age2=1:2,
		index = age1+2*(age2-1);
		mn(index) = mean(sim_resps{age1}{age2}(:,plot_var));
		q = iqr(sim_resps{age1}{age2}(:,plot_var));
		qrt_low(index) = prctile(sim_resps{age1}{age2}(:,plot_var),25);
		qrt_high(index) = prctile(sim_resps{age1}{age2}(:,plot_var),75);
		prc_low(index) = prctile(sim_resps{age1}{age2}(:,plot_var),5);
		prc_high(index) = prctile(sim_resps{age1}{age2}(:,plot_var),95);
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
	age1 = index-2*(age2-1)
	ys = sim_resps{age1}{age2}(:,plot_var);
	plot(index+0.25+0.02*randn(size(ys)), ys,'ko');
end;

f = figure('tag','simulation_summary_pref_null');

mn_p = zeros(4,1);
qrt_low_p = zeros(4,1);
qrt_high_p = zeros(4,1);
prc_low_p = zeros(4,1);
prc_high_p = zeros(4,1);

mn_n = zeros(4,1);
qrt_low_n = zeros(4,1);
qrt_high_n = zeros(4,1);
prc_low_n = zeros(4,1);
prc_high_n = zeros(4,1);

for age1=1:2,
	for age2=1:2,
		index = age1+2*(age2-1);
		mn_p(index) = mean(sim_resps{age1}{age2}(:,pref));
		qrt_low_p(index) = prctile(sim_resps{age1}{age2}(:,pref),25);
		qrt_high_p(index) = prctile(sim_resps{age1}{age2}(:,pref),75);
		prc_low_p(index) = prctile(sim_resps{age1}{age2}(:,pref),5);
		prc_high_p(index) = prctile(sim_resps{age1}{age2}(:,pref),95);
		mn_n(index) = mean(sim_resps{age1}{age2}(:,null));
		qrt_low_n(index) = prctile(sim_resps{age1}{age2}(:,null),25);
		qrt_high_n(index) = prctile(sim_resps{age1}{age2}(:,null),75);
		prc_low_n(index) = prctile(sim_resps{age1}{age2}(:,pref),5);
		prc_high_n(index) = prctile(sim_resps{age1}{age2}(:,pref),95);
	end;
end;

 % indexes are {young,young}, {old, young}, {young, old}, {old, old}

hb = bar([1:8], reshape([mn_p mn_n]', 8, 1));
set(hb,'facecolor',[0.5 0.5 0.5]);

hold on;

h = myerrorbar([1:2:8],mn_p,qrt_low_p-mn_p,qrt_high_p-mn_p);
delete(h(2));
set(h(1),'color',[0 0 0]);
box off;
axis([0 5 0 1]);

h = myerrorbar([2:2:8],mn_n,qrt_low_n-mn_n,qrt_high_n-mn_n);
delete(h(2));
set(h(1),'color',[0 0 0]);
box off;
axis([0 9 0 20]);

if plot_95_5,
	h = myerrorbar([1:2:8],mn_p,prc_low_p-mn_p,prc_high_p-mn_p);
	delete(h(2));
	set(h(1),'color',[0 0 0]);
	box off;
	axis([0 5 0 1]);

	h = myerrorbar([2:2:8],mn_n,prc_low_n-mn_n,prc_high_n-mn_n);
	delete(h(2));
	set(h(1),'color',[0 0 0]);
	box off;
	axis([0 9 0 20]);
end;

