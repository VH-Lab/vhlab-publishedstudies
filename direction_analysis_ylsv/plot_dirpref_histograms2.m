function [DPbglob, DPaglob] = plot_dirpref_histograms(prefix,expernames,trainDir,finalmoviename)

histfig = figure;
histallfig = figure;
scatterfig = figure;
polarfig = figure;
polarallfig = figure;
globalhistfig = figure;
globalhistallfig = figure;
globalscatterfig = figure;
globaldpreffig = figure;
globalpolarfig = figure;
globalpolarallfig = figure;
globalOTfig = figure;
globaldOTfig = figure;
globaldOTtunefig = figure;

labels={'Initial', 'Training'};
property = {'TP Ach OT Fit Pref','TP FE Ach OT Fit Pref'};
dirproperty = {'TP Ach OT Fit Direction index blr','TP FE Ach OT Fit Direction index blr'};
pthreshold_assoc = {'TP Ach OT visual response p','TP FE Ach OT visual response p'};

hist_bins = [ -Inf 0:20:360 Inf]; hist_xaxis = 0:20:360-20+20/2;

DPbglob = []; DPaglob = [];  DPballglob = [];
DIbglob = []; DIaglob = [];  DIballglob = [];
allmycells = {}; allmycellnames = {};
OTwbglob = []; OTwaglob = [];

for i=1:length(expernames),

	% load cells
	expernames{i},
	ds = dirstruct([prefix filesep expernames{i}]);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

	myinds = [];  
	DPb = []; DPa = [];
	DIb = []; DIa = [];
	DPball = []; DIball = [];

	for j=1:length(cells),
		%dirf2 = findassociate(cells{j},'OT Direction index 2 peak','','');
		dirf2 = findassociate(cells{j},'TP Ach OT Fit Direction index blr','','');
        dirf2t = findassociate(cells{j},'TP FE Ach OT Fit Direction index blr','',''); 
		vp   = findassociate(cells{j},'TP Ach OT visual response p','','');
		vpt   = findassociate(cells{j},'TP FE Ach OT visual response p','','');
		vecp   = findassociate(cells{j},'TP Ach OT vec varies p','','');
		vecpt   = findassociate(cells{j},'TP FE Ach OT vec varies p','','');
		OTi  = findassociate(cells{j},'TP Ach OT Fit Orientation index','','');
		OTit  = findassociate(cells{j},'TP FE Ach OT Fit Orientation index','','');
		OTr = findassociate(cells{j},'TP Ach OT Response curve','','');
		OTrt = findassociate(cells{j},'TP FE Ach OT Response curve','','');
		OTr2 = findassociate(cells{j},'TP Ach OT Fit R2','','');
		OTr2t = findassociate(cells{j},'TP FE Ach OT Fit R2','','');
		OTfit = findassociate(cells{j},'TP Ach OT Carandini Fit Params','','');
		OTfitt= findassociate(cells{j},'TP FE Ach OT Carandini Fit Params','','');
		tw = findassociate(cells{j},'TP Ach OT Tuning width','','');
		twt = findassociate(cells{j},'TP FE Ach OT Tuning width','','');
		if ~isempty(dirf2)&vecp.data<0.05,
			Dirpref = findassociate(cells{j},'TP Ach OT Fit Pref','','');
			DPball(end+1) = Dirpref.data; %mod(Dirpref.data-prevailDir(i)+90,360);
			DIball(end+1) = (OTfit.data(2)-OTfit.data(5))/OTfit.data(2);
		end;
		if ~isempty(dirf2)&~isempty(dirf2t)&vecp.data<0.05&vecpt.data<0.05,
			Dirpref = findassociate(cells{j},'TP Ach OT Fit Pref','','');
			DPb(end+1) = Dirpref.data;
			Dirpreft = findassociate(cells{j},'TP FE Ach OT Fit Pref','','');
			DPa(end+1) = Dirpreft.data;
			DIb(end+1) = (OTfit.data(2)-OTfit.data(5))/OTfit.data(2);
			DIa(end+1) = (OTfitt.data(2)-OTfitt.data(5))/OTfitt.data(2);
			myinds(end+1) = j; 
            OTwbglob(end+1) = tw.data; OTwaglob(end+1) = twt.data; 
		end;
	end;
	mycells = cells(myinds);
	mycellnames = cellnames(myinds);
	allmycells = cat(2,allmycells,mycells); allmycellnames = cat(1,allmycellnames,mycellnames);

	prevailOri = median(mod(DPa,180));
	if length(find(angdiffwrap(DPa-prevailOri,360)<10))>length(find(angdiffwrap(180+DPa-prevailOri,360)<10)),
		prevailDir(i) = prevailOri;
	else, prevailDir(i) = mod(prevailOri+180,360);
	end;

	figure(histfig);
	subplot(2,length(expernames),i);
	N = histc(DPb,hist_bins);N=N(2:end-2);
	plot([trainDir(i) trainDir(i)],[-1000 1000],'k--','linewidth',1);
	hold on;
	plot(mod([trainDir(i) trainDir(i)]+180,360),[-1000 1000],'k--','linewidth',1);
	bar(hist_xaxis,100*N/sum(N));
	axis([0 360 0 50]);
	title({expernames{i},['Dir pref initial, N=' int2str(sum(N)) '.']});
	if i==1, ylabel('Percent cells'); else, set(gca,'yticklabel',''); end;

	subplot(2,length(expernames),length(expernames)+i);
	N = histc(DPa,hist_bins);N=N(2:end-2);
	plot([trainDir(i) trainDir(i)],[-1000 1000],'k--','linewidth',1);
	hold on;
	plot(mod([trainDir(i) trainDir(i)]+180,360),[-1000 1000],'k--','linewidth',1);
	bar(hist_xaxis,100*N/sum(N));
	axis([0 360 0 50]);
	title(['Dir pref training, N=' int2str(sum(N)) '.']);
	xlabel('Degrees');
	if i==1, ylabel('Percent cells'); else, set(gca,'yticklabel',''); end;

	[mx,ind] = max(N);
	%prevailDir(i) = median(DPa(find(angdiffwrap(DPa-hist_xaxis(ind),360)<10)));
    prevailDir(i) = trainDir(i);
    
	if ~isempty(finalmoviename),
		moviefilename = [getpathname(ds) filesep 'analysis' filesep 'DIDPmovie.avi'];
		M = makeDIDPmovie(DPb,DPa,DIb,DIa,30,1,prevailDir(i)+90);
		movie2avi(M,moviefilename,'compression','none','fps',6);
	end;

	DPballglob = [DPballglob mod(DPball-prevailDir(i)+90,360)];
	DPbglob = [DPbglob mod(DPb-prevailDir(i)+90,360)]; DPaglob = [DPaglob mod(DPa-prevailDir(i)+90,360)];

	DIballglob = [DIballglob DIball];
	DIbglob = [DIbglob DIb]; DIaglob = [DIaglob DIa];


	figure(histallfig);
	subplot(2,length(expernames),i);
	N = histc(DPball,hist_bins);N=N(2:end-2);
	plot([trainDir(i) trainDir(i)],[-1000 1000],'k--','linewidth',1);
	hold on;
	plot(mod([trainDir(i) trainDir(i)]+180,360),[-1000 1000],'k--','linewidth',1);
	bar(hist_xaxis,100*N/sum(N));
	axis([0 360 0 50]);
	title({expernames{i},['Dir pref initial all cells, N=' int2str(sum(N)) '.']});
	if i==1, ylabel('Percent cells'); else, set(gca,'yticklabel',''); end;

	subplot(2,length(expernames),length(expernames)+i);
	N = histc(DPa,hist_bins); N=N(2:end-2);
	plot([trainDir(i) trainDir(i)],[-1000 1000],'k--','linewidth',1);
	hold on;
	plot(mod([trainDir(i) trainDir(i)]+180,360),[-1000 1000],'k--','linewidth',1);
	bar(hist_xaxis,100*N/sum(N));
	axis([0 360 0 50]);
	title(['Dir pref training, N=' int2str(sum(N)) '.']);
	xlabel('Degrees');
	if i==1, ylabel('Percent cells'); else, set(gca,'yticklabel',''); end;

	figure(scatterfig);
	subplot(1,length(expernames),i);
	[Xn,Yn]=tpscatterplot(mycells,mycellnames,'TP Ach OT Fit Pref','x','TP FE Ach OT Fit Pref','y',2,...
		'markersize',6,'colors',[0 0 0],'marker','.','clickfunction','plottpresponseclick','property','Recovery OT Fit Pref');
	axis([0 360 0 360]);
	if i==1, ylabel('Dir pref after(\circ)'); else, set(gca,'yticklabel',''); end;
	xlabel('Dir pref before(\circ)');
	title(expernames{i},'interp','none');
	axis equal;

	figure(polarfig);
	subplot(2,length(expernames),i);
	polar(pi*[trainDir(i) trainDir(i)]/180,[0 1],'k--');
	hold on;
	polar(pi*mod([trainDir(i) trainDir(i)]+180,360)/180,[0 1],'k--');
	polar(pi*DPb/180,DIb,'ko');
	%axis([0 2*pi 0 50]);
	title({expernames{i},['Dir pref initial, N=' int2str(sum(N)) '.']});

	subplot(2,length(expernames),length(expernames)+i);
	polar(pi*[trainDir(i) trainDir(i)]/180,[0 1],'k--');
	hold on;
	polar(pi*mod([trainDir(i) trainDir(i)]+180,360)/180,[0 1],'k--');
	polar(pi*DPa/180,DIa,'ko');
	%axis([0 2*pi 0 50]);
	title({expernames{i},['Dir pref training, N=' int2str(sum(N)) '.']});
end;

figure(globalhistfig);

subplot(2,1,1);
N = histc(DPbglob,hist_bins);N=N(2:end-2);
bar(hist_xaxis,100*N/sum(N));
axis([0 360 0 50]);
title(['Dir pref initial, N=' int2str(sum(N)) '.']);
xlabel('Degrees');

subplot(2,1,2);
N = histc(DPaglob,hist_bins);N=N(2:end-2);
bar(hist_xaxis,100*N/sum(N));
axis([0 360 0 50]);
title(['Dir pref training, N=' int2str(sum(N)) '.']);
xlabel('Degrees');

figure(globalhistallfig);
subplot(2,1,1);
N = histc(DPballglob,hist_bins);N=N(2:end-2);
bar(hist_xaxis,100*N/sum(N));
axis([0 360 0 50]);
title(['Dir pref initial, N=' int2str(sum(N)) '.']);
xlabel('Degrees');

subplot(2,1,2);
N = histc(DPaglob,hist_bins);N=N(2:end-2);
bar(hist_xaxis,100*N/sum(N));
axis([0 360 0 50]);
title(['Dir pref training, N=' int2str(sum(N)) '.']);
xlabel('Degrees');

figure(globalscatterfig);
plot(DPbglob,DPaglob,'k.');  % don't use clickable version since we don't have training direction coded
%[Xn,Yn]=tpscatterplot(allmycells,allmycellnames,'OT Fit Pref','dirpref4train(cell,1)','Recovery OT Fit Pref','dirpref4train(cell,0)',2,...
%		'markersize',6,'colors',[0 0 0],'marker','.','clickfunction','plottpresponseclick','property','Recovery OT Fit Pref');
axis([0 360 0 360]);
ylabel('Dir pref before (\circ)');
xlabel('Dir pref after(\circ)');
title(['Dir pref initial vs. train, N=' int2str(length(allmycells))],'interp','none');
axis equal;

figure(globaldpreffig);
plot(DPbglob,angdiffwrapsign(DPaglob-DPbglob,360),'k.');
axis([0 360 -180 180]);
ylabel('\Delta Dir pref (\circ)'); xlabel('Dir pref before (\circ)');
title(['Change in dir pref, N=' int2str(length(DPbglob))],'interp','none');
axis equal;

figure(globalpolarfig);
subplot(1,2,1);
polar(pi*mod(DPbglob-90*0,360)/180,DIbglob,'k.');
title(['Change in DI and DP, N = ' int2str(length(DPbglob))]);

subplot(1,2,2);
polar(pi*mod(DPaglob-90*0,360)/180,DIaglob,'k.');
title(['Change in DI and DP, N = ' int2str(length(DPaglob))]);

figure(globalpolarallfig);
subplot(1,2,1);
polar(pi*mod(DPballglob-90*0,360)/180,DIballglob,'k.');
title(['Change in DI and DP, N = ' int2str(length(DPballglob))]);

subplot(1,2,2);
polar(pi*mod(DPaglob-90*0,360)/180,DIaglob,'k.');
title(['Change in DI and DP, N = ' int2str(length(DPaglob))]);

if ~isempty(finalmoviename),
	moviefilename = [finalmoviename];
	M = makeDIDPmovie(mod(DPbglob-90*0,360),mod(DPaglob-90*0,360),DIbglob,DIaglob,30,1,180);
	movie2avi(M,moviefilename,'compression','none','fps',6);
end;

figure(globalOTfig);
plot(mod(DPbglob,180),mod(DPaglob,180),'k.');
title(['Orientation preference before and after training']);
ylabel('90+OP_{after}-TO (\circ)'); xlabel('90+OP_{before}-TO(\circ)');
hold on
plot([0 1000],[0 1000],'k--');
axis([0 180 0 180]); axis equal;

figure(globaldOTfig);
plot(mod(DPbglob,180),angdiffwrapsign(mod(DPaglob,180)-mod(DPbglob,180),180),'k.');
title(['Orientation preference before and after training']);
ylabel('\DeltaOT Pref (\circ)'); xlabel('90+OP_{before}-TO(\circ)');
axis([0 180 -90 90]);

figure(globaldOTtunefig);
plot(mod(DPbglob,180),OTwaglob-OTwbglob,'k.');
title(['Tuning width changes after training']);
ylabel('\Delta Tuning width(\circ)'); xlabel('90+OP_{before}-TO(\circ)');

keyboard;