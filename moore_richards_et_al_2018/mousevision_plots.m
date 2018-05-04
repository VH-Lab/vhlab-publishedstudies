function mousevision_plots(sanity)
% MOUSEVISION_PLOTS - PERFORM ANALYSIS OF PARADIS/VANHOOSER EXPERIMENTS
%
%   MOUSEVISION_PLOTS(SANITY)
%
%   This will perform all plotting of fitted directories for the
%   Paradis/VanHooser lab ocular dominance project.
%
%   If available, it will pull a variable called 'mousevision_plots_data' from
%   the calling function's workspace (the main workspace if it is called from the
%   command line). This will save the function from having to read all of the values from
%   disk.
%
%   If SANITY is 1, then all individual cell measurements will be plotted in order to check
%   the quality of fits and index measurements.
%
%   At the conclusion of its analysis, the function will post a variable 'mousevision_plots_data'
%   to the calling workspace (the main workspace if it is called from the command line)
%   which will reduce the time required for the function to run a second time.

if evalin('caller',['exist(''mousevision_plots_data'',''var'')']),
	mousevision_plots_data = evalin('base','mousevision_plots_data');
	san = sanity;
	struct2var(mousevision_plots_data);
	sanity = san;
else,
	prefix = '/Volumes/Data3/Paradis_VanHooser/';
	expernames = {'2014-07-08','2014-07-23','2014-06-16','2014-06-10','2014-06-12','2014-06-30',...
		'2014-07-09','2014-07-10','2014-07-11','2014-07-14','2014-07-17','2014-07-31','1014-07-31','2014-08-01','2014-08-11','2014-08-12','1014-08-12','2014-08-22'};
	expernames = {'2014-07-11','2014-07-31','1014-07-31','2014-08-01','2014-08-11','2014-08-12','1014-08-12','2014-08-22','2014-08-25','2014-08-26','2014-08-27','2014-09-02','2014-09-01','2014-09-06','2014-09-07','2014-09-14','1014-09-14'};

	output = mousevisiontpanalysis(prefix,expernames);
	[cells,cellnames,experind]=readcellsfromexperimentlist(prefix,expernames,1,4);

	assignin('caller','mousevision_plots_data',workspace2struct);
end;

fig_output = [prefix filesep 'grant_eps'];

labels = {'KO','WT','CKO','RI Het','CHet','WT no dep','KO no dep'};
ylabels = {'1-CV','ODI','DI','1-CVbe','DIbe'};
datafields = {'CV','CI','DIbr','CV_be','DIbr_be'};
extravars = { {'subtract1',1},{'dorescale',1,'rescalefrom',[-1 1],'rescaleto',[-1 1]},{},{'subtract1',1}, {} ,{'dorescale',1,'rescalefrom',[-1 1],'rescaleto',[-1 1]} };

for i=1:length(datafields),
	figure;
	h=median_within_between_plot(getfield(output,datafields{i}),output.experindex,labels,...
		'expernames',expernames,extravars{i}{:});
	ylabel(ylabels{i});
	saveas(gcf,[fig_output filesep 'overall_' ylabels{i} '.eps'],'eps');
	saveas(gcf,[fig_output filesep 'overall_' ylabels{i} '.fig'],'fig');
end;

if sanity,
	plotallfits(5,5,cells,cellnames,['odicellinclude(''TP'',0)'],['odicellplot(''TP'',0)']);

end;

colors = [0 1 0 ; 0 1 0 ; 1 1 1 ; 1 1 1 ; 1 1 1; 0 0 0;  0.5 0.5 0.5 ; 0 0 0];
contra_ipsi_fig = figure;
cifields = {'contmax','ipsimax'};
cilabels = {'contra','ipsi'};
ci_xrange = [0 0.35];
ci_sym = {'--','--','','','','-','-'};

hist_fig = figure;
subplotid = 1;

for i=[1 2 6 7],
	for j=[2],
		figure(hist_fig);
		subplot(2,2,subplotid);
		bins = [-1:0.2:1];
		thedata = getfield(output,datafields{j});
		datahere=rescale(thedata{i},[-1 1],[-1 1]);
		if i==1,
			datahere1 = datahere;
		elseif i==2,
			datahere2 = datahere;
		end;
		N = histc(datahere,bins);
		Nnorm = N./sum(N);
		bar(bins,Nnorm);
		ylabel(['N = ' int2str(sum(N)) '.'],'interp','none');
		title(labels{i},'interp','none');
		xlabel(ylabels{j});
		box off;
		subplotid = subplotid + 1;

		figure(contra_ipsi_fig);
		for k=1:2,
			if (i==1) | (i==7), 
				row = 1;
				label_row = ['KO '];
			elseif (i==2) | (i==6),
				row = 2;
				label_row = ['WT '];
			end;
			subplot(2,2,(row-1)*2+k);
			hold on;
			coridata = getfield(output,cifields{k});
			coridatahere=coridata{i};
			[X,Y]=cumhist(coridatahere,ci_xrange,0.1);
			plot(X,Y,ci_sym{i},'color',colors(i,:),'linewidth',2);
			xlabel('DF/F');
			ylabel('Cumulative percentage');
			title([label_row cilabels{k}],'interp','none');
		end;
	end;
end;

saveas(hist_fig,[fig_output filesep 'histogram_fig.fig'],'fig');
saveas(hist_fig,[fig_output filesep 'histogram_fig.eps'],'eps');
saveas(contra_ipsi_fig,[fig_output filesep 'contraipsi_fig.fig'],'fig');
saveas(contra_ipsi_fig,[fig_output filesep 'contraipsi_fig.eps'],'eps');

[h,p]=ttest2(datahere1,datahere2)

bar_fig = figure;

for k=1:2, % ori and direction
	subplot(2,2,k);

	j = 3 + k; % 4 or 5

	mns = [];
	stde = [];

	I = [ 1 2 6 7 ];
	
	for i=1:length(I),
        mydata = getfield(output,datafields{j});
        if k==1,
            mns(i) = nanmean(1-mydata{I(i)});
            stde(i) = nanstderr(1-mydata{I(i)});
        elseif k==2,
            mns(i) = nanmean(1-mydata{I(i)});
            stde(i) = nanstderr(1-mydata{I(i)});
        end;
	end;
	bar([1 2 3 4],mns);
    hold on;
	h=myerrorbar([1 2 3 4],mns,stde,stde);
	delete(h(2));
	set(gca,'xtick',[1 2 3 4],'xticklabel',{'KO Dep','WT Dep','WT','KO'});
	if k==1, ylabel('1-CV'); elseif k==2, ylabel('1-DCV'); end;
    box off;
end;

saveas(bar_fig,[fig_output filesep 'orientationdirection_fig.fig'],'fig');
saveas(bar_fig,[fig_output filesep 'orientationdirection_fig.eps'],'eps');


assignin('caller','mousevision_plots_data',workspace2struct);


