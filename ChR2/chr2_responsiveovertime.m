function chr2_responsivenessovertime(vars)


figure;

labels_hist = {'motion','const','nochr2'};

%bins = [ -0.1 0.1 0; 1 4 mean([1 4]); 4 7 mean([4 7])];  % this is the single point version
bins = [ -0.1 0.1 NaN; 1 4 NaN; 4 7 NaN];               % this is the all available points version

plot_colors_symb = ['rgk'];
plot_edgecolors_symb = ['rgk']; %['kkw'];
plot_symb = ['ods'];
plot_colors = { [1 0 0] ; [0 1 0] ; [ 0 0 0 ] };


P = {};
mn = {};
stde = {};
x = [];
G = [];

for i=1:3,
	mn{i} = [];
	stde{i} = [];
	indexes = find(vars.trainingstimid==i);
	disp(['i=' int2str(i) ', indexes is length ' int2str(length(indexes)) '.']);

	cellindexeshere = unique(vars.indexlookup(indexes));

	expers = unique(vars.experids(cellindexeshere));

	for r=1:size(bins,1),
		P{i,r} = [];
		for k=1:length(expers),
			mycells = find(vars.experids==expers(k));
			n_ = 0;
			d_ = 0;
			for c = 1:length(mycells),
				indexes2 = find(vars.trainingstimid==i&vars.t>=bins(r,1)&...
					vars.t<bins(r,2)&ismember(vars.indexlookup,mycells(c)));
				d_ = d_ + 1;
				if any(~isnan(vars.di_raw(indexes2))),
					n_ = n_ + 1;
				end;
			end;
			P{i,r}(end+1) = 100 * n_/d_;
			x = [x(:); P{i,r}(:)];
			G = [G; repmat([i r],numel(P{i,r}),1)];
		end;
		mn{i}(r) = mean((P{i,r}));
		stde{i}(r) = stderr(P{i,r}');
	end;
	subplot(3,1,i);
	hb=bar([1 2 3],mn{i},0.5);
	set(hb,'facecolor',[0.5 0.5 0.5]);
	hold on;
	h=myerrorbar([1 2 3],mn{i},stde{i},stde{i},'k');
	delete(h(2));
	set(h(1),'linewidth',2);
	title(labels_hist{i});
	box off;
	axis([0.5 3.5 0 100]);
	set(gca,'linewidth',1);
end;

G,

figure;
[p,table,stats]=anovan(x,G);


