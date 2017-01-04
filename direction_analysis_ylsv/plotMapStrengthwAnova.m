function plotMapStrengthwAnova(prefix,expnames)

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
    D = dir([getscratchdirectory(ds) filesep '*_mapstrength.mat']);
    
    for j=1:length(D),
        fname = [getscratchdirectory(ds) filesep D(j).name];
        load(fname);
        if sqrt(length(mapstrength))<40, disp(['excluding ' fname ]); break; end;

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

for K=1:1,
    for norm=0:1,
        figure;
        for P = 1:4,
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
            H=myerrorbar(hist_xaxis(2:end)*240/512,mns2(2:end),stde2(2:end),['-' cols(P,2)]);
            set(H,'linewidth',2,'color',thecolors{1+double(P==2|P==4)}(2,:));
            xlabel(xlabs{P});
            ylabel(ylabs{K,norm+1}{P});
            title(titles{P});
            axis([0 250 Yaxis{norm+1}(K,[1 2]+double(P>2)*2)]);
        end;
    end;
end

return;

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
