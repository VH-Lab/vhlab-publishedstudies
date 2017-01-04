function chr2_histogramplay2(vars)


figure;

labels_hist = {'motion','const','nochr2'};

mn = {};
stde = {};
individuals = {};
N = [];
x = {};
g = {};
p_anova = {};
anova_stats = {};
p_kw = {};
kw_stats = {};

%bins = [ -0.1 0.1 0; 1 4 mean([1 4]); 4 7 mean([4 7])];  % this is the single point version
bins = [ -0.1 0.1 NaN; 1 4 NaN; 4 7 NaN];               % this is the all available points version

for i=1:3,
	indexes = find(vars.trainingstimid==i);
	disp(['i=' int2str(i) ', indexes is length ' int2str(length(indexes)) '.']);
	[N{i},mn{i},stde{i},individuals{i}] = chr2_histogramovertime(vars.indexlookup(indexes),...
		vars.di_raw(indexes), vars.t(indexes),bins);
	subplot(3,1,i);
	bar([1 2 3],mn{i});
	hold on;
	h=myerrorbar([1 2 3],mn{i},stde{i},stde{i});
	delete(h(2));
	title([labels_hist{i} ',N=' mat2str(N{i})]);
	box off;
	matchaxes(gca,'axis','axis',0,1);
	set(gca,'xticklabel',{'Time 0','1-4 hr','4-7 hr'});
	[x{i},g{i}] = cell2group(individuals{i});
	[p_anova{i},dummy,anova_stats{i}] = anova1(x{i},g{i},'off');
	[p_kw{i},dummy,kw_stats{i}] = kruskalwallis(x{i},g{i},'off');

end;

