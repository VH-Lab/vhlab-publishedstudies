function [maxDSI, finalDSI, finalgmaxearly, finalgmaxlate, finalmaxrate] = sl_feedforwardstdp

filelist1 = {'ml12','ml22', 'ml32','ml42','ml52'};
filelist2 = {'ml13','ml23', 'ml33','ml433','ml53'};

lags = [ 0.200 0.150 0.100 0.050 0.025 ];
isi = [ 2.2 1.65 1.1 0.55 0.275];

sl_limitsHebbianfig;

stdplabels = {'Triplet','Classic'};

for i=1:2,
	maxDSI{i} = [];
	finalDSI{i} = [];
	finalgmaxearly{i} = [];
	finalgmaxlate{i} = [];
	finalmaxrate{i} = [];
	initialarray{i} = {};
	finalarray{i} = {};
	
	eval(['filelist = filelist' int2str(i) ';']);

	fig = figure;
	
	for j=1:length(filelist),
		initialarray{i}{j} = [];
		finalarray{i}{j} = [];
		if exist([filelist{j} '.mat'])==2,
			g = load([filelist{j} '.mat']);
			[early,late] = sl_earlylate(sqrt(size(g.out.gmaxes,1)));
			if ~exist([filelist{j} 'p.mat']),
				% project out to 4800 more reps
				rates = (g.out.gmaxes(:,end) - g.out.gmaxes(:,end-100))/100;
				gmaxes_projected = g.out.gmaxes(:,end) + 4800*rates;
				gmaxes_projected = max(gmaxes_projected,gmaxes_projected*0);
				gmaxes_projected = min(gmaxes_projected,gmaxes_projected*0+GsynMax_list(j));
				[dummy,di,r_up,r_down] = directionselectivityNcelldemo('isi',isi(j),'N',sqrt(size(g.out.gmaxes,1)),...
					'R',sqrt(size(g.out.gmaxes,1)),...
					'latency',lags(j),'lag',lags(j),'synapseparams',{'tau2',0.020},'Syn_Gmax_initial', gmaxes_projected');
				save([filelist{j} 'p.mat'],'r_up','r_down','gmaxes_projected','-mat');
			end;
			p = load([filelist{j} 'p.mat']);
			dsi = (g.out.r_up - g.out.r_down)./(g.out.r_up + g.out.r_down);
			dsi(end+1) = (p.r_up - p.r_down)./(p.r_up + p.r_down);
			finalDSI{i}(j) = dsi(end);
			maxDSI{i}(j) = max(dsi);
			finalgmaxearly{i}(j) = mean(p.gmaxes_projected(early));
			finalgmaxlate{i}(j) = mean(p.gmaxes_projected(late));
			finalmaxrate{i}(j) = p.r_up;
			finalarray{i}{j} = p.gmaxes_projected;
			initialarray{i}{j} = g.out.gmaxes(:,1);
		end;
	end;

	subplot(3,2,1);
	plot(lags,finalDSI{i},'k-o');
	hold on;
	plot(lags,0.5+0*lags,'k--');
	xlabel('Lag(s)');
	ylabel('Final DSI');
	box off;
	title(stdplabels{i});

	subplot(3,2,2);
	plot(lags,maxDSI{i},'k-o');
	hold on;
	plot(lags,0.5+0*lags,'k--');
	xlabel('Lag(s)');
	ylabel('Max DSI');
	box off;

	subplot(3,2,3);
	plot(lags,finalgmaxearly{i},'k-o');
	hold on;
	plot(lags,GsynAP_list,'r--');
	plot(lags,GsynMax_list,'b--');
	xlabel('Lag(s)');
	ylabel('Early G');
	box off;

	subplot(3,2,4);
	plot(lags,finalgmaxlate{i},'k-o');
	hold on;
	plot(lags,GsynAP_list,'r--');
	plot(lags,GsynMax_list,'b--');
	xlabel('Lag(s)');
	ylabel('Late G');
	box off;

	subplot(3,2,5);
	plot(lags,finalmaxrate{i},'k-o');
	xlabel('Lag(s)');
	ylabel('Max Response (Spikes)');
	box off;

	figure;
	subplot(2,2,1)
	pcolor(pcolordummyrowcolumn(reshape(initialarray{i}{5},5,5)));
	shading faceted;
	caxis([0 2e-9]);
	axis square;
	axis([1 6 1 6]);
	subplot(2,2,2);
	title(stdplabels{i});
	subplot(2,2,3)
	pcolor(pcolordummyrowcolumn(reshape(finalarray{i}{5},5,5)));
	shading faceted;
	caxis([0 2e-9]);
	axis square;
	axis([1 6 1 6]);
	subplot(2,2,4);
	pcolor(pcolordummyrowcolumn(reshape(finalarray{i}{5},5,5)));
	caxis([0 2e-9]);
	colorbar;

end;
