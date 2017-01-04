function plotMapStrength(prefix,expnames)

%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

hist_bins = [ -Inf -49:50:501 Inf]; hist_xaxis = [0 (0:50:500-50)+50/2];

themeans = {}; thestderrs = {};

for I=1:3, for J=1:2, for K=1:3, themeans{I,J,K} = []; thestderrs{I,J,K} = []; end; end; end;

   % themeans{i,j,k}
   %   i = {1,2,3} ({naive, train, old}), j = {1,2} ({ori, dir})
   %   k = {1,2,3}, ({xc, pref, ind})

IJ = [ 2 4 6];
mapnaive = []; maptrain = []; mapold = [];

for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
    D = dir([getscratchdirectory(ds) filesep '*_mapstrengthcross.mat']);
    
    for j=1:length(D),
        fname = [getscratchdirectory(ds) filesep D(j).name];
        load(fname);
        if sqrt(length(mapstrength))<0, disp(['excluding ' fname ]); break; end;

        if eyesopen<=2,
    		mapnaive = [mapnaive; mapstrength];
    		maptrain = [maptrain; mapstrengtht];
            if ~isempty(mapstrength),
                for K=1:3,
                    [themeans{1,1,K}(end+1,:),thestderrs{1,1,K}(end+1,:),...
                        themeans{1,2,K}(end+1,:),thestderrs{1,2,K}(end+1,:)] = ...
                        doMapStrengthMean(mapstrength,hist_bins,IJ(K),IJ(K)+1);
			if K==3, [max(mapstrength(:,3)) min(mapstrength(:,3))], end;
                end;
            end;
            if ~isempty(mapstrengtht),
                for K=1:3,
                    [themeans{2,1,K}(end+1,:),thestderrs{2,1,K}(end+1,:),...
                        themeans{2,2,K}(end+1,:),thestderrs{2,2,K}(end+1,:)]= ...
                        doMapStrengthMean(mapstrengtht,hist_bins,IJ(K),IJ(K)+1);
			if K==3, [max(mapstrength(:,3)) min(mapstrength(:,3))], end;
                end;                
            end;
        else,    
            mapold = [mapold; mapstrength];
            if ~isempty(mapstrength),
                for K=1:3,
                    [themeans{3,1,K}(end+1,:),thestderrs{3,1,K}(end+1,:),...
                        themeans{3,2,K}(end+1,:),thestderrs{3,2,K}(end+1,:)] = ...
                        doMapStrengthMean(mapstrength,hist_bins,IJ(K),IJ(K)+1);
			if K==3, [max(mapstrength(:,3)) min(mapstrength(:,3))], end;
                end;
            end;
        end;
    end;
end;

% now plot normalized and unnormalized

Yaxis{1} = [ -0.4 1.5 -.05 0.2; 0 90 0 180 ; 0 0.8 0 0.5]; 
Yaxis{2} = [ -0.4 1.5 -.2 0.7; 0 90 0 180 ; 0 0.8 0 0.5]; 

cols = ['os';'od';'os';'od']; thecolors = { [0.66 0.66 0.66; 0 0 0] , [0.66 0.66 0.66; 0.33 0.33 0.33]};
combs = [ 1 1 3 1; 1 1 2 1; 1 2 3 2; 1 2 2 2];   % [I J]
xlabs = {'','','\Delta position (\mum)','\Delta position (\mum)'};
ylabs{1,1} = {'OT Map Corr','','Dir Map Corr',''};
ylabs{1,2} = {'OT Map Corr (norm)','','Dir Map Corr (norm)',''};
ylabs{2,1} = {'\Delta OT Pref','','\Delta Dir Pref',''};
ylabs{2,2} = {'\Delta OT Pref (norm)','','\Delta Dir Pref (norm)',''};
ylabs{3,1} = {'\Delta OI','','\Delta DI',''};
ylabs{3,2} = {'\Delta OI (norm)','','\Delta DI (norm)',''};
titles = {'Naive=blue, experienced=red','Naive=blue, trained=green','',''};
anovalabs = {'OT Naive vs. adult','OT Naive vs. trained','DIR Naive vs. adult','DIR Naive vs. trained'};

for K=1:1,
    for norm=0,
        figure;
        for P = [2 4],
            subplot(2,2,P);
            mns1 = nanmean(themeans{combs(P,1),combs(P,2),K});
            stde1 = nanstderr(themeans{combs(P,1),combs(P,2),K});
            mns2 = nanmean(themeans{combs(P,3),combs(P,4),K});
            stde2 = nanstderr(themeans{combs(P,3),combs(P,4),K});
            if norm,
                mns1 = mns1./mns1(1); stde1 = stde1./mns1(1);
                mns2 = mns2./mns2(1); stde2 = stde2./mns2(1);
            end;
            hold off;
            H=myerrorbar(hist_xaxis(2:end)*240/512,mns1(2:end),stde1(2:end),['-' cols(P,1)]);
            set(H,'linewidth',2,'color',thecolors{1+double(P==2|P==4)}(1,:));
            hold on;
			if 0,
            H=myerrorbar(hist_xaxis(2:end)*240/512,mns2(2:end),stde2(2:end),['-' cols(P,2)]);
            set(H,'linewidth',2,'color',thecolors{1+double(P==2|P==4)}(2,:));
			end;
            xlabel(xlabs{P});
            ylabel(ylabs{K,norm+1}{P});
            title(titles{P});
            axis([0 250 Yaxis{norm+1}(K,[1 2]+double(P>2)*2)]);
        end;
    end;
end

subplot(2,2,1);
inds = find(mapnaive(:,1)==0);
dis = abs(mapnaive(inds,[12 13])*[1 sqrt(-1)]');
plot(dis, mapnaive(inds,3),'k.');
xlabel('Initial DI');
ylabel('Inital X Trained');
set(gca,'YScale','log');
hold on; plot([0 1],[0 1],'k--'); plot([0 1],[0 -1],'k--');

[Yn,Xn] = slidingwindowfunc(dis, mapnaive(inds,3), -.1, 0.05, 0.9, 0.2, 'mean',0)

hold on;
plot(Xn,max([Yn; 1e-14+zeros(size(Yn))]),'k-','linewidth',2);

subplot(2,2,3);
plot(dis,-mapnaive(inds,3),'k.');
hold on; plot([0 1],[0 1],'k--'); plot([0 1],[0 -1],'k--');
xlabel('Initial DI');
ylabel('Inital X Trained');
set(gca,'yscale','log','ydir','reverse');
hold on;
plot(Xn,min([-Yn; 1e-14+zeros(size(Yn))]),'k-','linewidth',2);

mn = mean(mapnaive(inds,3));
se = stderr(mapnaive(inds,3));
[h,p] = ttest(mapnaive(inds,3));
disp(['Mean IxF: ' num2str(mn) ' +/- ' num2str(se) ', prob ' num2str(p) '.']);

[sv,svi] = sort(dis);
divis = round(linspace(1,length(svi),5)),
disp(['Bins: ' num2str(dis(svi(divis))') '.']);

myvals = mapnaive(inds(svi),3);
divis(1) = 0;

for i=1:4,
	[h,pvalues(i)] = ttest(myvals([divis(i)+1:divis(i+1)]),0,0.05,'right');
end;
pvalues,

if 0,
mybins = [-Inf 0 0.05 0.1 0.15 0.2 0.25 0.30 0.35 1 Inf];
pvalues = [];
[N,binid] = histc(dis,mybins); binid = binid - 1;
 N = N(2:end-2);
 N,
 for i=1:length(N),
    myinds = find(binid==i);
	[h,pvalues(i)] = ttest(mapnaive(inds(myinds),3),0,0.05,'right');
 end;
pvalues,
end;

[b,bint] = regress(mapnaive(inds,3)-mn, dis);
bint,


%figure;
subplot(2,2,2);
hold off;

siginds = find(mapnaive(inds,16)<0.01);
nonsiginds = find(mapnaive(inds,16)>=0.01);
siginds = find(dis>.5);
nonsiginds = find(dis<=.5);
dirs_before = angle(mapnaive(inds,[12 13])*[1 sqrt(-1)]') * 180/pi ;
dirs_after = angle(mapnaive(inds,[14 15])*[1 sqrt(-1)]') * 180/pi ;

S = angdiffwrap(dirs_before'-dirs_after',360)' < 90;

H=bar([1 2],[sum(S(siginds))/ length(siginds)  sum(S(nonsiginds))/length(nonsiginds)]); 
set(H,'facecolor',[0 0 0]);

set(gca,'xticklabel',{ ['Sig D N=' int2str(length(siginds))], ['NSig D N=' int2str(length(nonsiginds)) ]});

return;



subplot(2,2,4);
disa = abs(mapnaive(inds,[14 15])*[1 sqrt(-1)]');
plot(dis,disa-dis,'.k');
xlabel('Initial DI');
ylabel('Change in DI');

mn2 = mean(disa-dis);
ste2 = stderr(disa-dis);
[h,p2] = ttest(disa-dis);
disp(['Mean dDI: ' num2str(mn2) ' +/- ' num2str(ste2) ', prob ' num2str(p2) '.']);
[b,bint] = regress(disa-dis-mn2,dis);
bint,
keyboard;

binsx = { [0:20:260 ], [0:20:260 ],  [0:20:260 ]};
binsy{1} = { [-1.5:0.15:1.5], [0:10:100],  [0:0.05:1.5] ;
          [-0.5:0.05:0.5], [0:20:200],  [0:0.05:1]};
binsy{2} = { [-1:0.1:1], [0:10:100],  [0:0.05:1.5] ;
          [-1:0.1:1], [0:20:200],  [0:0.05:1]};
      
xlabs = {'','',''; ...
        '\Delta position (\mum)','\Delta position (\mum)','\Delta position (\mum)'};
ylabs{1,1} = {'OT Map Corr','',''; 'Dir Map Corr','',''};
ylabs{1,2} = {'OT Map Corr(norm)','','';'Dir Map Corr','',''};
ylabs{2,1} = {'\Delta OT Pref (\circ)','',''; '\Delta Dir Pref (\circ)','',''};
ylabs{2,2} = {'\Delta OT Pref (norm)','','';'\Delta Dir Pref (norm)','',''};
ylabs{3,1} = {'\Delta OI','',''; '\Delta DI','',''};
ylabs{3,2} = {'\Delta OI','','';'\Delta DI (norm)','',''};

for K=1:3,
    for norm=0:1,
        figure;
        for P=1:3,
            for J=1:2,
                if P==1, mymat = [mapnaive(:,[1 IJ(K)+J-1])];
                elseif P ==2, mymat = [maptrain(:,[1 IJ(K)+J-1])];
                elseif P==3, mymat = [mapold(:,[1 IJ(K)+J-1])];
                end;
                mymat(:,1) = mymat(:,1)*242/512;
                if norm,
                    mymat(:,2) = mymat(:,2)./nanmean(mymat(find(mymat(:,1)==0),2));
                end;
                mymat = mymat(find(mymat(:,1)~=0),:);
                vXCoord = 0.5*(binsx{K}(1:end-1)+binsx{K}(2:end));
                vYCoord = 0.5*(binsy{norm+1}{J,K}(1:end-1)+binsy{norm+1}{J,K}(2:end));
                if ~isempty(mymat),
                    mHist = hist2d(mymat,binsx{K},binsy{norm+1}{J,K});
                    num=sum(mHist')';
                    mHist = mHist./repmat(num,1,size(mHist,2));
                    subplot(2,3,P+(J-1)*3);
                    pcolor(vXCoord,vYCoord,100*mHist');
                    xlabel(xlabs{J,P}); ylabel(ylabs{K,norm+1}{J,P});
                    caxis([0 50]);
                    if P==3, colorbar; colormap(jet(256)); end;
                end;
            end;
        end;
    end;
end;


function [mns1,stderrs1,mns2,stderrs2] = doMapStrengthMean(map,hist_bins,I,J)

 % compute bin membership
 [N,bins] = histc(map(:,1),hist_bins); bins = bins - 1;
 N = N(2:end-2);
 for i=1:length(N),
    myinds = find(bins==i);
    mns1(i) = mean(map(myinds,I));
    stderrs1(i) = stderr(map(myinds,I));
    mns2(i) = mean(map(myinds,J));
    stderrs2(i) = stderr(map(myinds,J));
 end;
