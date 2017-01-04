function makedirscatterplots(prefix,expnames)


%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

try, mkdir(prefix,'direction_analysis'); end;
output_path = fixpath([fixpath(prefix) 'direction_analysis']);

for k=1:3,
	dDir_dX{k} = struct('x',[],'y',[]); dDI_dX{k} = struct('x',[],'y',[]);
	dOT_dX{k} = struct('x',[],'y',[]);
    DI_OT{k} = struct('x',[],'y',[]);
	Rm_DI{k} = struct('x',[],'y',[]); Rm_OT{k} = struct('x',[],'y',[]);
	Noise_DI{k} = struct('x',[],'y',[]); Noise_OT{k} = struct('x',[],'y',[]);
end;

agemin = Inf; agemax = 0;

usesaved = 1;

if ~usesaved,
for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	stacknames = findallstacks(ds);
    age = findassociate(cells{1},'Eyes open','','');
	agemax = max(agemax,age.data); agemin = min(agemin,age.data);
	if age.data<2, k=1,
	elseif age.data<110, k=2,
	elseif age.data<100, k=3,
	end;

	for j=1:length(stacknames),
		mycells = selectstackcells(ds,stacknames{j});
		mxr = []; nz = []; di = []; ot = [];
	        incl = []; inclds = []; inclos = [];
		for z=1:length(mycells),
			pvalasoc = findassociate(mycells{z},'OT visual response p','','');
			if ~isempty(pvalasoc),
				if pvalasoc.data<0.05,
					incl(end+1)=z;
					maxresp = findassociate(mycells{z},'OT Max Response','','');
					mxr(end+1) = maxresp.data;
					diassoc = findassociate(mycells{z},'OT Direction index 2 peak','','');
					di(end+1) = diassoc.data;
					otassoc = findassociate(mycells{z},'OT Orientation index 2 peak','','');
					ot(end+1) = otassoc.data;
					respassoc = findassociate(mycells{z},'Best orientation resp','','');
					nz(end+1) = nanmean(respassoc.data.curve(4,:));
                    if di(end)>=0.3, inclds(end+1) = z; else, inclos(end+1) = z; end;
				end;
			end;
		end;
		[dirx,diry]=tpdscatterplot(mycells, inclds, inclos,'OT Fit Pref','min(abs([x1-x2;x1-x2-360;x1-x2+360]))',...
			'pixellocs','sqrt( (mean(x1.x)-mean(x2.x))^2+(mean(x1.y)-mean(x2.y))^2  )','OT visual response p',0.05);
		%[dix,diy]=tpdscatterplot(mycells,incl, incl,'OT Direction index 2 peak','min(abs([x1-x2;]))',...
		%	'pixellocs','sqrt( (mean(x1.x)-mean(x2.x))^2+(mean(x1.y)-mean(x2.y))^2  )','OT visual response p',0.05);
		%[otx,oty]=tpdscatterplot(mycells,incl, incl,'OT Orientation index 2 peak','min(abs([x1-x2;]))',...
		%	'pixellocs','sqrt( (mean(x1.x)-mean(x2.x))^2+(mean(x1.y)-mean(x2.y))^2  )','OT visual response p',0.05);
		[dix,diy]=tpdscatterplot(mycells, inclds, inclds,'OT Fit Pref 2 Peak','min(abs([x1-x2;x1-x2-360;x1-x2+360]))',...
			'pixellocs','sqrt( (mean(x1.x)-mean(x2.x))^2+(mean(x1.y)-mean(x2.y))^2  )','OT visual response p',0.05);
		[otx,oty]=tpdscatterplot(mycells,incl, incl,'OT Fit Pref 2 Peak','min(abs([x1-x2;x1-x2-360;x1-x2+360]))',...
			'pixellocs','sqrt((mean(x1.x)-mean(x2.x))^2+(mean(x1.y)-mean(x2.y))^2  )','OT visual response p',0.05);
        dDir_dX{k}.x = cat(2,dDir_dX{k}.x,dirx); dDir_dX{k}.y = cat(2,dDir_dX{k}.y,diry);
		dDI_dX{k}.x = cat(2,dDI_dX{k}.x,dix); dDI_dX{k}.y = cat(2,dDI_dX{k}.y,diy);
		dOT_dX{k}.x = cat(2,dOT_dX{k}.x,otx); dOT_dX{k}.y = cat(2,dOT_dX{k}.y,oty);
		Rm_DI{k}.x = cat(2,Rm_DI{k}.x,mxr); Rm_DI{k}.y = cat(2,Rm_DI{k}.y,di);
		DI_OT{k}.x = cat(2,DI_OT{k}.x,di); DI_OT{k}.y = cat(2,DI_OT{k}.y,ot);
		Rm_OT{k}.x = cat(2,Rm_OT{k}.x,mxr); Rm_OT{k}.y = cat(2,Rm_OT{k}.y,ot);
		Noise_DI{k}.x = cat(2,Noise_DI{k}.x,nz); Noise_DI{k}.y = cat(2,Noise_DI{k}.y,di);
		Noise_OT{k}.x = cat(2,Noise_OT{k}.x,nz); Noise_OT{k}.y = cat(2,Noise_OT{k}.y,ot);
	end;
end;
save([output_path 'makedirscatterdata.mat'],'-mat');
else,
load([output_path 'makedirscatterdata.mat'],'-mat');
end;

yvar = { dDir_dX , dDI_dX, dOT_dX, Rm_DI, Rm_OT, Noise_DI, Noise_OT, DI_OT};
yvarscale = [242/512 242/512 242/512 1 1 1 1 1];
xlabels = {'\Delta position (\mum)','\Delta position (\mum)','\Delta position (\mum)','DI','OT','DI','OT','OT'};
ylabels = {'\Delta Dir pref (^circ)', '\Delta DI', '\Delta OT', 'R_{max}', 'R_{max}','Std. err','Std. err','DI'};
filenames = {'dDirPref_vs_dPos.ps','dDI_vs_dPos.ps','dOT_vs_dPos','Rm_vs_DI','Rm_vs_OT','SE_vs_DI','SE_vs_OT','DI_vs_OT'};

%binsx = { [0:5:250 ], [0:5:250 ],  [0:5:250 ],  [],[],[],[],[]};
%binsy = { [0:5:180 ], [0:0.01:1],  [0:0.01:1 ],  [],[],[],[],[]};
binsx = { [0:20:260 ], [0:20:260 ],  [0:20:260 ],  [],[],[],[],[]};
binsy = { [0:20:200 ], [0:20:200],  [0:20:200 ],  [],[],[],[],[]};

axlimit = [ NaN NaN NaN NaN;NaN NaN NaN NaN;NaN NaN NaN NaN;0 1 0 0.4;0 1 0 0.4;0 1 0 0.1;0 1 0 0.1; 0 1.5 0 1.5];

  % now make our plots

for k=1:length(yvar),

   if isempty(binsx{k}),
	figure;
	subplot(2,2,1);
	plot(yvarscale(k)*yvar{k}{1}.y,yvar{k}{1}.x,'ro');
	xlabel(xlabels{k}); ylabel(ylabels{k});
	title(['Eyes open < 2 days']);
	axis(axlimit(k,:));

	subplot(2,2,2);
	plot(yvarscale(k)*yvar{k}{2}.y,yvar{k}{2}.x,'bx');
	xlabel(xlabels{k}); ylabel(ylabels{k});
	title(['Eyes open 2-7 days.']);
	axis(axlimit(k,:));

	subplot(2,2,3);
	plot(yvarscale(k)*yvar{k}{3}.y,yvar{k}{3}.x,'ks');
	xlabel(xlabels{k}); ylabel(ylabels{k});
%	title(['Ages 39 - ' int2str(agemax) '.']);
    title(['Eyes open 8-16 days']);
    axis(axlimit(k,:));

	subplot(2,2,4);
	plot(yvarscale(k)*yvar{k}{1}.y,yvar{k}{1}.x,'ro');
	hold on;
	plot(yvarscale(k)*yvar{k}{2}.y,yvar{k}{2}.x,'bx');
	plot(yvarscale(k)*yvar{k}{3}.y,yvar{k}{3}.x,'ks');
	xlabel(xlabels{k}); ylabel(ylabels{k});
	title('Combined');
	axis(axlimit(k,:));
	eval(['print -dpsc ' output_path filenames{k}]);
   else,
	figure;
	for jj=1:3,
	mat=[yvarscale(k)*yvar{k}{jj}.y' yvar{k}{jj}.x'];
	vXCoord = 0.5*(binsx{k}(1:end-1)+binsx{k}(2:end));
	vYCoord = 0.5*(binsy{k}(1:end-1)+binsy{k}(2:end));
	if ~isempty(mat),
		mHist = hist2d(mat,binsx{k},binsy{k});
        num=sum(sum(mHist));
		subplot(2,2,jj);
		pcolor(vXCoord,vYCoord,100*mHist'/num);colorbar;
	else, axis([min(vXCoord) max(vXCoord) min(vYCoord) max(vYCoord)]); colorbar;
	end;
	xlabel(xlabels{k}); ylabel(ylabels{k});
	if 0,
        if jj==1, title(['Ages ' int2str(agemin) ' - 34 PND.']);
        elseif jj==2, title(['Ages 35-38 PND.']);
        elseif jj==3, title(['Ages 39 - ' int2str(agemax) '.']);
        end;
    else,
        if jj==1, title(['Eyes open < 2 days']);
        elseif jj==2, title(['Eyes open 2-7 days']);
        elseif jj==3, title(['Eyes open 8-16 days.']);
        end;
    end;

	end; % jj

	eval(['print -dpsc ' output_path filenames{k}]);
   end;
end;
for k=4:length(yvar),
	for jj=1:3,
		if ~isempty(yvar{k}{jj}.x),
			[P,S]=polyfit(yvarscale(k)*yvar{k}{jj}.y,yvar{k}{jj}.x,1);
			[B,Bint]=regress(yvar{k}{jj}.x'-P(2),yvarscale(k)*yvar{k}{jj}.y',0.05);
			if ~(Bint(1)<0&Bint(2)>0),
				disp(['Slope of ' xlabels{k} ' vs. ' ylabels{k} ' is significant.']);
				[jj B Bint P(1) P(2) ],
			end;
		end;

	end;
end;
