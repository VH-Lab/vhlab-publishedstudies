function plotMapStrength(prefix,expnames)

%prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

hist_bins = [ -Inf -49:50:251 Inf]; hist_xaxis = [0 (0:50:250-50)+50/2];

themeans = {}; thestderrs = {};

for I=1:3, for J=1:2, for K=1:6, themeans{I,J,K} = []; thestderrs{I,J,K} = []; end; end; end;

   % themeans{i,j,k}
   %   i = {1,2,3} ({naive, train, old}), j = {1,2} ({ori, dir})
   %   k = {1,2,3,4,5}, ({xc, pref, ind, di*di, dp*dp})

IJ = [ 2 4 6 14 16 16];
noise = [ 0 0 0 0 0 0.0950];
mapnaive = []; maptrain = []; mapold = [];

for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
    D = dir([getscratchdirectory(ds) filesep '*_mapstrength.mat']);
    
    for j=1:length(D),
        fname = [getscratchdirectory(ds) filesep D(j).name],
        load(fname);
        if sqrt(length(mapstrength))<10, disp(['excluding ' fname ]); break; end;

		%mapstrength = mapstrength(find(mapstrength(:,[10])<=0.2&mapstrength(:,[11])<=0.2),:);
		%if ~isempty(mapstrengtht), mapstrengtht = mapstrengtht(find(mapstrengtht(:,[10])<=0.2&mapstrengtht(:,[11])<=0.2),:); end;
           
        if eyesopen<=2,
    		mapnaive = [mapnaive; mapstrength];
    		maptrain = [maptrain; mapstrengtht];
            if ~isempty(mapstrength),
                for K=1:6,
                    [themeans{1,1,K}(end+1,:),thestderrs{1,1,K}(end+1,:),...
                        themeans{1,2,K}(end+1,:),thestderrs{1,2,K}(end+1,:)] = ...
                        doMapStrengthMean(mapstrength,hist_bins,IJ(K),IJ(K)+1,noise(K));
					if K==3, [max(mapstrength(:,3)) min(mapstrength(:,3))], end;
					if K==2, themeans{1,1,K} = abs(themeans{1,1,K}); themeans{1,2,K} = abs(themeans{1,2,K}); end;
                end;
            end;
            if ~isempty(mapstrengtht),
                for K=1:6,
                    [themeans{2,1,K}(end+1,:),thestderrs{2,1,K}(end+1,:),...
                        themeans{2,2,K}(end+1,:),thestderrs{2,2,K}(end+1,:)]= ...
                        doMapStrengthMean(mapstrengtht,hist_bins,IJ(K),IJ(K)+1,noise(K));
					if K==3, [max(mapstrength(:,3)) min(mapstrength(:,3))], end;
					if K==2, themeans{2,1,K} = abs(themeans{2,1,K}); themeans{2,2,K} = abs(themeans{2,2,K}); end;
                end;                
            end;
        else,    
            mapold = [mapold; mapstrength];
            if ~isempty(mapstrength),
                for K=1:6,
                    [themeans{3,1,K}(end+1,:),thestderrs{3,1,K}(end+1,:),...
                        themeans{3,2,K}(end+1,:),thestderrs{3,2,K}(end+1,:)] = ...
                        doMapStrengthMean(mapstrength,hist_bins,IJ(K),IJ(K)+1,noise(K));
					if K==3, [max(mapstrength(:,3)) min(mapstrength(:,3))], end;
					if K==2, themeans{3,1,K} = abs(themeans{3,1,K}); themeans{3,2,K} = abs(themeans{3,2,K}); end;
                end;
            end;
        end;
    end;
end;

% now plot normalized and unnormalized

Yaxis{1} = [ -0.4 1.5 -.1 0.25; 0 90 0 180 ; 0 0.8 0 0.5 ; -0.4 1.5 -.05 0.4; -0.4 1.5 -.2 0.45;  -0.4 1.5 -0.2 0.45;]; 
Yaxis{2} = [ -0.4 1.5 -.2 0.7; 0 90 0 180 ; 0 0.8 0 0.5; -0.4 1.5 -.1 0.7; -0.4 1.5 -.2 0.7;  -0.4 1.5 -0.2 0.7;]; 

cols = ['os';'od';'os';'od']; thecolors = { [0.66 0.66 0.66; 0 0 0] , [0.66 0.66 0.66; 0.33 0.33 0.33]};
combs = [ 1 1 3 1; 1 1 2 1; 1 2 3 2; 1 2 2 2];   % [I J]
xlabs = {'','','\Delta position (\mum)','\Delta position (\mum)'};
ylabs{1,1} = {'OT Map Corr','','Dir Map Corr',''};
ylabs{1,2} = {'OT Map Corr (norm)','','Dir Map Corr (norm)',''};
ylabs{2,1} = {'\Delta OT Pref','','\Delta Dir Pref',''};
ylabs{2,2} = {'\Delta OT Pref (norm)','','\Delta Dir Pref (norm)',''};
ylabs{3,1} = {'\Delta OI','','\Delta DI',''};
ylabs{3,2} = {'\Delta OI (norm)','','\Delta DI (norm)',''};
ylabs{4,1} = {'Map Corr OI','','Map Corr DI',''};
ylabs{4,2} = {'Map Corr OI (norm)','','Map Corr DI (norm)',''};
ylabs{5,1} = {'Map Corr OP','','Map Corr DP',''};
ylabs{5,2} = {'Map Corr OP (norm)','','Map Corr DP (norm)',''};
ylabs{6,1} = {'Dir uncertainty','','Dir uncertainty',''};
ylabs{6,2} = {'Dir uncertainty (norm)','','Dir uncertainty (norm)',''};
titles = {'Naive=blue, experienced=red','Naive=blue, trained=green','',''};
anovalabs = {'OT Naive vs. adult','OT Naive vs. trained','DIR Naive vs. adult','DIR Naive vs. trained'};

%keyboard;

for K=[1 4 5 6],
    for norm=0,
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
            H=myerrorbar(hist_xaxis(2:end),mns1(2:end),stde1(2:end),['-']);% cols(P,1)]);
            set(H,'linewidth',1,'color',thecolors{1+double(P==2|P==4)}(1,:));
            hold on;
            H=myerrorbar(hist_xaxis(2:end),mns2(2:end),stde2(2:end),['-']);% cols(P,2)]);
            set(H,'linewidth',1,'color',thecolors{1+double(P==2|P==4)}(2,:));
            xlabel(xlabs{P});
            ylabel(ylabs{K,norm+1}{P});
            title(titles{P});
            axis([0 250 Yaxis{norm+1}(K,[1 2]+double(P>2)*2)]);
			box off;
			if ~norm & P==3|P==4, 
                %keyboard;
                m=fminsearch(@(m) mymin(m,mns1(2:end),mns2(2:end)),1);
                [K P m],
				h=plot(hist_xaxis(2:end),m*mns1(2:end),'b--');
			end;
			
			if ~norm,
			% perform an anovan
			M = []; G = [];
			sz = size(themeans{combs(P,1),combs(P,2),K}(2:end,:));
			dists = repmat(1:sz(2),sz(1),1);
			g = ones(sz);
			M = reshape(themeans{combs(P,1),combs(P,2),K}(2:end,:),prod(sz),1);
			G = [reshape(g,prod(sz),1) reshape(dists,prod(sz),1)];
			
			sz = size(themeans{combs(P,3),combs(P,4),K}(2:end,:));
			dists = repmat(1:sz(2),sz(1),1);
			g = 2*ones(sz);
			M = [M;reshape(themeans{combs(P,3),combs(P,4),K}(2:end,:),prod(sz),1);];
			G = [G;reshape(g,prod(sz),1) reshape(dists,prod(sz),1)];			
			[p,atab] = anovan(M,G,'model',2,'sstype',3,'display','off','varnames',strvcat('Group', 'Dist'));
			disp([anovalabs{P} '):'])
			atab,
			end;
        end;
    end;
end

return;


function [mns1,stderrs1,mns2,stderrs2,Ns] = doMapStrengthMean(map,hist_bins,I,J,noise)

 % compute bin membership
 [N,bins] = histc(map(:,1)*240/512,hist_bins); bins = bins - 1;
 N = N(2:end-2);
 for i=1:length(N),
    myinds = find(bins==i);
    if noise, 
        mynoise = rand(size(myinds));
        map(myinds,J) = map(myinds,J) .* ((mynoise>=noise)-(mynoise<noise));
    end;
    mns1(i) = mean(map(myinds,I));
    stderrs1(i) = stderr(map(myinds,I));
    mns2(i) = mean(map(myinds,J));
    stderrs2(i) = stderr(map(myinds,J));
    Ns(i) = length(myinds);
 end;

function err = mymin(m,x,y)
inds = ~isnan(x)&~isnan(y);
err=sum((m*x(inds)-y(inds)).^2);
     