function plotdDIdXscatter(prefix,expnames)

%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

for k=1:3,
	dDir_dX{k} = struct('x',[],'y',[]);
    dDI_dX{k} = struct('x',[],'y',[]);
	dOT_dX{k} = struct('x',[],'y',[]);
	dDir_dXt{k} = struct('x',[],'y',[]);
    dDI_dXt{k} = struct('x',[],'y',[]);
	dOT_dXt{k} = struct('x',[],'y',[]);
end;


for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
	stacknames = findallstacks(ds);
    
    for j=1:length(stacknames),
        load([getscratchdirectory(ds) filesep stacknames{j} '_dDIdXscatterdata.mat'],'dirx','diry','dix','diy','otx','oty','eyesopen','dirxt','diryt','dixt','diyt','otxt','otyt');

        if eyesopen<=2, k = 1; else, k = 3; end;
        dDir_dX{k}.x = cat(2,dDir_dX{k}.x,dirx); dDir_dX{k}.y = cat(2,dDir_dX{k}.y,diry);
        dDI_dX{k}.x = cat(2,dDI_dX{k}.x,dix); dDI_dX{k}.y = cat(2,dDI_dX{k}.y,diy);
        dOT_dX{k}.x = cat(2,dOT_dX{k}.x,otx); dOT_dX{k}.y = cat(2,dOT_dX{k}.y,oty);
        if ~isempty(otxt),
            k = 2;
            dDir_dX{k}.x = cat(2,dDir_dX{k}.x,dirxt); dDir_dX{k}.y = cat(2,dDir_dX{k}.y,diryt);
            dDI_dX{k}.x = cat(2,dDI_dX{k}.x,dixt); dDI_dX{k}.y = cat(2,dDI_dX{k}.y,diyt);
            dOT_dX{k}.x = cat(2,dOT_dX{k}.x,otxt); dOT_dX{k}.y = cat(2,dOT_dX{k}.y,otyt);
        end;
    end;
end;

yvar = { dDir_dX , dDI_dX, dOT_dX};
yvarscale = [242/512 242/512 242/512];
xlabels = {'\Delta position (\mum)','\Delta position (\mum)','\Delta position (\mum)'};
ylabels = {'\Delta Dir pref (^circ)', '\Delta DI', '\Delta OT'};
filenames = {'dDirPref_vs_dPos.ps','dDI_vs_dPos.ps','dOT_vs_dPos'};

%binsx = { [0:5:250 ], [0:5:250 ],  [0:5:250 ],  [],[],[],[],[]};
%binsy = { [0:5:180 ], [0:0.01:1],  [0:0.01:1 ],  [],[],[],[],[]};
binsx = { [0:20:260 ], [0:20:260 ],  [0:20:260 ]};
binsy = { [0:20:200 ], [0:20:200],  [0:20:200 ]};

axlimit = [ NaN NaN NaN NaN;NaN NaN NaN NaN;NaN NaN NaN NaN;0 1 0 0.4;0 1 0 0.4;0 1 0 0.1;0 1 0 0.1; 0 1.5 0 1.5];

  % now make our plots
for k=1:3,
	figure;
	for jj=1:3,
	mat=[yvarscale(k)*yvar{k}{jj}.y' yvar{k}{jj}.x'];
	vXCoord = 0.5*(binsx{k}(1:end-1)+binsx{k}(2:end));
	vYCoord = 0.5*(binsy{k}(1:end-1)+binsy{k}(2:end));
	if ~isempty(mat),
		mHist = hist2d(mat,binsx{k},binsy{k});
        num=sum(mHist')';
        mHist = mHist./repmat(num,1,size(mHist,2));
		subplot(2,2,jj);
		pcolor(vXCoord,vYCoord,100*mHist');colorbar;
        xlabel(xlabels{k}); ylabel(ylabels{k});
        if jj==1, title(['Eyes open < 2 days']);
        elseif jj==2, title(['Trained']);
        elseif jj==3, title(['Eyes open 3-16 days.']);
        end;
        caxis([0 50]);
	%else, axis([min(vXCoord) max(vXCoord) min(vYCoord) max(vYCoord)]); colorbar;
	end;


	end; % jj

	%eval(['print -dpsc ' output_path filenames{k}]);
end;
return;
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
