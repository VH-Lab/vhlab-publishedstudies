function chr2_histogramplay(vars)


labels_hist = {'motion','const','nochr2'};
title_hist = ['N='];

V = [];
G = [];

figure;
for i=1:length(labels_hist),
        cell_indexes = find(vars.cell_trainingstimid==i & ~isnan(vars.delta_di_unsigned_overall));
        mn_ = nanmean(vars.delta_di_unsigned_overall(cell_indexes));
	V = cat(2,V,vars.delta_di_unsigned_overall(cell_indexes));
	G = cat(2,G,i*ones(1,length(cell_indexes)));
        sde_ = nanstderr(vars.delta_di_unsigned_overall(cell_indexes));
        title_hist = [title_hist int2str(length(cell_indexes)) ','];
        bar(i,mn_);
        hold on;
        myerrorbar(i,mn_,sde_,sde_);
end;
set(gca,'xtick',[1 2 3],'xticklabel',labels_hist);
ylabel('Means delta unsigned DI');
title(title_hist);

[p,table,stats]=anova1(V,G);

 % create alternative delta_di_unsigned

alt_delta_di_unsigned = [];

for i=1:length(vars.cells),
	inds = find(vars.indexlookup == i);
	di_vals_here = vars.di_raw(inds);
	if isnan(di_vals_here(1)) | all(isnan(di_vals_here(2:end))),
		alt_delta_di_unsigned(i) = NaN;
	else,
		nanvals_indexes = find(~isnan(di_vals_here));
		alt_delta_di_unsigned(i) = di_vals_here(nanvals_indexes(end)) - di_vals_here(1);
	end;
end;

V2 = [];
G2 = [];
title_hist2 = ['N='];

figure;
for i=1:length(labels_hist),
        cell_indexes = find(vars.cell_trainingstimid==i & ~isnan(alt_delta_di_unsigned));
        mn_ = nanmean(alt_delta_di_unsigned(cell_indexes));
        V2 = cat(2,V2,alt_delta_di_unsigned(cell_indexes));
        G2 = cat(2,G2,i*ones(1,length(cell_indexes)));
        sde_ = nanstderr(alt_delta_di_unsigned(cell_indexes));
        title_hist2 = [title_hist2 int2str(length(cell_indexes)) ','];
        bar(i,mn_);
        hold on;
        myerrorbar(i,mn_,sde_,sde_);
end;
set(gca,'xtick',[1 2 3],'xticklabel',labels_hist);
ylabel('Means delta unsigned DI, alternate');
title(title_hist2);


keyboard;




