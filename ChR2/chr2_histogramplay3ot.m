function chr2_histogramplay2(vars, varname)
 
  % edit for OT rather than di_raw

  % 2nd argument can be 'di_raw', 'cv_raw', 'dcv_raw'
  %  
  
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

plot_colors_symb = ['rgk'];
plot_edgecolors_symb = ['rgk']; %['kkw'];
plot_symb = ['ods'];
plot_colors = { [1 0 0] ; [0 1 0] ; [ 0 0 0 ] };

for i=1:3,
	indexes = find(vars.trainingstimid==i);
	disp(['i=' int2str(i) ', indexes is length ' int2str(length(indexes)) '.']);
	myvalues = eval(['vars.' varname '(indexes);']);
	[N{i},mn{i},stde{i},individuals{i}] = chr2_histogramovertime(vars.indexlookup(indexes),...
		myvalues, vars.t(indexes),bins);
	subplot(3,1,i);
	hb=bar([1 2 3],mn{i},0.5); % width of 0.5
	set(hb,'facecolor',[0.5 0.5 0.5]);
	hold on;
	h=myerrorbar([1 2 3],mn{i},stde{i},stde{i});
	delete(h(2));
	set(h(1),'color',[0 0 0],'linewidth',4);
	hold on;
	for j=1:3,
		plot(0.5+j+0.25*(rand(size(individuals{i}{j}))-0.5),individuals{i}{j},[plot_colors_symb(i) plot_symb(i)],...
			'MarkerFaceColor',plot_colors_symb(i),'MarkerEdgeColor',plot_edgecolors_symb(i),'MarkerSize',4);
	end;
	title([labels_hist{i} ',N=' mat2str(N{i})]);
	box off;
	matchaxes(gca,'axis','axis',0,1);
	set(gca,'xticklabel',{'Time 0','1-4 hr','4-7 hr'});
	[x{i},g{i}] = cell2group(individuals{i});
	[p_anova{i},dummy,anova_stats{i}] = anova1(x{i},g{i},'off');
	[p_kw{i},dummy,kw_stats{i}] = kruskalwallis(x{i},g{i},'off');

    
end;


p_anova,

p_kw,

keyboard;