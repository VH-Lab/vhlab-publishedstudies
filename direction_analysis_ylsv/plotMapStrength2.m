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
    D = dir([getscratchdirectory(ds) filesep '*_mapstrength.mat']);
    
    for j=1:length(D),
        load([getscratchdirectory(ds) filesep D(j).name]);

        if eyesopen<=2,
    		mapnaive = [mapnaive; mapstrength];
    		maptrain = [maptrain; mapstrengtht];
        else,    
            mapold = [mapold; mapstrength];
        end;
    end;
end;

if ~isempty(mapnaive),
                    for K=1:3,
                    [themeans{1,1,K}(end+1,:),thestderrs{1,1,K}(end+1,:),...
                        themeans{1,2,K}(end+1,:),thestderrs{1,2,K}(end+1,:)] = ...
                        doMapStrengthMean(mapnaive,hist_bins,IJ(K),IJ(K)+1);
                end;
end;

if ~isempty(maptrain),
                    for K=1:3,
                    [themeans{2,1,K}(end+1,:),thestderrs{2,1,K}(end+1,:),...
                        themeans{2,2,K}(end+1,:),thestderrs{2,2,K}(end+1,:)]= ...
                        doMapStrengthMean(maptrain,hist_bins,IJ(K),IJ(K)+1);
                end;      
end;

if ~isempty(mapold),
                for K=1:3,
                    [themeans{3,1,K}(end+1,:),thestderrs{3,1,K}(end+1,:),...
                        themeans{3,2,K}(end+1,:),thestderrs{3,2,K}(end+1,:)] = ...
                        doMapStrengthMean(mapold,hist_bins,IJ(K),IJ(K)+1);
                end;
end;


% now plot normalized and unnormalized

Yaxis = [ -0.4 1.5 -.1 0.7; 0 180 0 360 ; 0 1.5 0 1]; 

cols = ['br';'bg';'br';'bg'];
combs = [ 1 1 3 1; 1 1 2 1; 1 2 3 2; 1 2 2 2];   % [I J]
xlabs = {'','','\Delta position (\mum)','\Delta position (\mum)'};
ylabs{1,1} = {'OT Map Corr','','Dir Map Corr',''};
ylabs{1,2} = {'OT Map Corr (norm)','','Dir Map Corr (norm)',''};
ylabs{2,1} = {'\Delta OT Pref','','\Delta Dir Pref',''};
ylabs{2,2} = {'\Delta OT Pref (norm)','','\Delta Dir Pref (norm)',''};
ylabs{3,1} = {'\Delta OI','','\Delta DI',''};
ylabs{3,2} = {'\Delta OI (norm)','','\Delta DI (norm)',''};
titles = {'Naive=blue, experienced=red','Naive=blue, trained=green','',''};

keyboard;

for K=1:3,
    for norm=0:1,
        figure;
        for P = 1:4,
            subplot(2,2,P);
            disp('starting plot');
            mns1 = themeans{combs(P,1),combs(P,2),K};
            stde1 = thestderrs{combs(P,1),combs(P,2),K};
            mns2 = themeans{combs(P,3),combs(P,4),K};
            stde2 = thestderrs{combs(P,3),combs(P,4),K};
            if norm,
                mns1 = mns1./mns1(1); stde1 = stde1./mns1(1);
                mns2 = mns2./mns2(1); stde2 = stde2./mns2(1);
            end;
            hold off;
            myerrorbar(hist_xaxis(2:end)*240/512,mns1(2:end),stde1(2:end),['-o' cols(P,1)]);
            hold on;
            myerrorbar(hist_xaxis(2:end)*240/512,mns2(2:end),stde2(2:end),['-o' cols(P,2)]);
            disp('here');
            xlabel(xlabs{P});
            ylabel(ylabs{K,norm+1}{P});
            title(titles{P});
            axis([0 250 Yaxis(K,[1 2]+double(P>2)*2)]);
        end;
    end;
end

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
