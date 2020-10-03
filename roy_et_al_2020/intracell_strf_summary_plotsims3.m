function intracell_strf_summary_plotsim(sims_resps, oristruct, vmf_model, sims_resps_norandom)

f = figure('tag','simulation_summary');

young = 1;
old = 2;
pref = 2;
null = 3;
di = 1;

plot_var = 2;
warning('edit here to switch between plotting DI and pref');

[out_young, out_old] = intracell_strf_oriprops2diprefnull(oristruct, vmf_model);

 % indexes are {young,young}, {old, young}, {young, old}, {old, old}

hold on;

for index=1:4,
	age2 = 1+double(index>2);
	age1 = index-2*(age2-1);
	plot(index+1+[0.5 0.5 1.5 1.5],[0 mean(sims_resps{age1}{age2}(:,plot_var)) mean(sims_resps{age1}{age2}(:,plot_var)) 0],'k-');
	plot(index+1+[1 1],[mean(sims_resps{age1}{age2}(:,plot_var))+[-1 1]*vlt.data.nanstderr(sims_resps{age1}{age2}(:,plot_var))],'k-');
	plot(index+1+1+0.1*randn(size(sims_resps{age1}{age2}(:,plot_var))),sims_resps{age1}{age2}(:,plot_var),'ko');
end;

plot([0.5 0.5 1.5 1.5],[0 mean(sims_resps_norandom{1}{1}(:,plot_var)) mean(sims_resps_norandom{1}{1}(:,plot_var)) 0],'k-');
plot([1 1],[mean(sims_resps_norandom{1}{1}(:,plot_var))+[-1 1]*vlt.data.nanstderr(sims_resps_norandom{1}{1}(:,plot_var))],'k-');
plot(1+0.1*randn(size(sims_resps_norandom{1}{1}(:,plot_var))),sims_resps_norandom{1}{1}(:,plot_var),'ko');

plot(7+[0.5 0.5 1.5 1.5],[0 mean(sims_resps_norandom{2}{2}(:,plot_var)) mean(sims_resps_norandom{2}{2}(:,plot_var)) 0],'k-');
plot(7+[1 1],[mean(sims_resps_norandom{2}{2}(:,plot_var))+[-1 1]*vlt.data.nanstderr(sims_resps_norandom{2}{2}(:,plot_var))],'k-');
plot(8+0.1*randn(size(sims_resps_norandom{2}{2}(:,plot_var))),sims_resps_norandom{2}{2}(:,plot_var),'ko');

box off;

