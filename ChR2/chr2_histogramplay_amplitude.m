function out=chr2_histogramplay2(vars, use_absolute)

if use_absolute,  % absolute
	propname = 'maxresp_abs';
	axheight = 35;
else, % relative
	propname = 'maxresp_norm';
	axheight = 4;
end;
fig_main = figure;

labels_hist = {'motion','const','nochr2'};

mn = {};
stde = {};
individuals = {};
indsofindividuals = {};
N = [];
x = {};
g = {};
p_anova = {};
anova_stats = {};
p_kw = {};
kw_stats = {};
p33 = {};
p67 = {};

fig_alt = figure;

figure(fig_main);


%bins = [ -0.1 0.1 0; 1 4 mean([1 4]); 4 7 mean([4 7])];  % this is the single point version
bins = [ -0.1 0.1 NaN; 1 4 NaN; 4 7 NaN];               % this is the all available points version

plot_colors_symb = ['rgk'];
plot_edgecolors_symb = ['rgk']; %['kkw'];
plot_symb = ['ods'];
plot_colors = { [1 0 0] ; [0 1 0] ; [ 0 0 0 ] };

for i=1:3,
	indexes = find(vars.trainingstimid==i);
	disp(['i=' int2str(i) ', indexes is length ' int2str(length(indexes)) '.']);
	X = eval(['vars.' propname ';']);
	Y = vars.maxresp_abs;
	Z = vars.di_unsigned;
	if use_absolute,
		[N{i},mn{i},stde{i},individuals{i}] = chr2_histogramovertime(vars.indexlookup(indexes),...
			X(indexes), vars.t(indexes),bins);
	else,
		total_cell_list = unique(vars.indexlookup);
		for zz=1:length(total_cell_list),
			mycellpts = find(vars.indexlookup==total_cell_list(zz));
			X(mycellpts) = Y(mycellpts)./Y(mycellpts(1));
		end;
		[N{i},mn{i},p33{i},p67{i},individuals{i},indsofindividuals{i}] = chr2_histogramovertime_median(vars.indexlookup(indexes),...
			X(indexes), vars.t(indexes),bins, vars.di_esigned_init(indexes));
		N{i}, length(indsofindividuals{i}{3}),
		figure(fig_alt);
		subplot(2,2,i);
		plot(X(indsofindividuals{i}{3}),Z(indsofindividuals{i}{3}),[plot_colors_symb(i) plot_symb(i)]);
		xlabel('Normalized max response');
		ylabel('Change in DSI');
		title(['N = ' int2str(length(indsofindividuals{i}{3})) ]);
		box off;
		i,
		p = quickregressionpvalue(X(indsofindividuals{i}{3})',Z(indsofindividuals{i}{3})'),
		[slope,offset,slope_confinterval] = quickregression(X(indsofindividuals{i}{3})',Z(indsofindividuals{i}{3})',0.05),
		hold on;
		linesymb = '--';
		if p<0.05,  linesymb = '-'; end;
		plot([0 4],offset+slope*[0 4],[linesymb plot_colors_symb(i)]);
		matchaxes(gca,0,4,-1,1);
		figure(fig_main);
	end;
	subplot(3,1,i);
	hb=bar([1 2 3],mn{i},0.5); % width of 0.5
	set(hb,'facecolor',[0.5 0.5 0.5]);
	hold on;
	if use_absolute,
		h=myerrorbar([1 2 3],mn{i},stde{i},stde{i});
	else,
		h=myerrorbar([1 2 3],mn{i},p33{i},p67{i});
	end;
	delete(h(2));
	set(h(1),'color',[0 0 0],'linewidth',4);
	hold on;
	for j=1:3,
		plot(0.5+j+0.25*(rand(size(individuals{i}{j}))-0.5),individuals{i}{j},[plot_colors_symb(i) plot_symb(i)],...
			'MarkerFaceColor',plot_colors_symb(i),'MarkerEdgeColor',plot_edgecolors_symb(i),'MarkerSize',4);
	end;
	title([labels_hist{i} ',N=' mat2str(N{i})]);
	box off;
	matchaxes(gca,'axis','axis',0,axheight);
	set(gca,'xticklabel',{'Time 0','1-4 hr','4-7 hr'});
	[x{i},g{i}] = cell2group(individuals{i});
	[p_anova{i},dummy,anova_stats{i}] = anova1(x{i},g{i},'off');
	[p_kw{i},dummy,kw_stats{i}] = kruskalwallis(x{i},g{i},'off');

end;

figure;
Is = cat(2,indsofindividuals{1}{3},indsofindividuals{2}{3});
for i=1:2,
	plot(X(indsofindividuals{i}{3}),Z(indsofindividuals{i}{3}),[plot_colors_symb(i) plot_symb(i)]);
	hold on;
end;
box off;
linesymb = '--';
p = quickregressionpvalue(X(Is)',Z(Is)');
if p<0.05, linesymb = '-'; end;
[slope,offset,slope_confinterval,RESID, RESIDINT, STATS] = quickregression(X(Is)',Z(Is)',0.05),
plot([0 4],offset+slope*[0 4],[linesymb 'b']);
matchaxes(gca,0,4,-1,1);
xlabel('Normalized max response');
ylabel('Change in DI');
plot([0 4],[0 0],'k--');



out=workspace2struct;
