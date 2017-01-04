function comparediagehistograms(prefix,expnames)

%prefix = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
%expnames = {'2006-07-11'};

try, mkdir(prefix,'direction_analysis2'); end;
output_path = fixpath([fixpath(prefix) 'direction_analysis2']);

    %1=naive, 2=motion, 3=flash, 4=experienced, 5=naive_responly, 
    %6=motion_responly, 7=flash_responly, 8=naive_presentonly,
    %9=motion_presentonly, 10=flash_presentonly, 11=naive_flash
    %12=naive w/ motion or flash,
    %13=motion w/naive
    %14=flash w/ naive

for k=1:14,
    DI{k} = [];   % Direction index (Rp-Rn)/Rp
    OI{k} = [];   % Orientation index (Pref-Orth)/Pref
    DIsp{k} = []; % Direction index w/ spontaneous corrected (Rp-Rn)/(Rp-Sp)
    OIsp{k} = []; % Orientation index w/ spontaneous corrected (Pref-Orth)/(Pref-Sp)
    DIbr{k} = []; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
    OIbr{k} = []; % Direction index w/ blank subtracted (Rp-Rn)/(Rp-blank)
    blr{k} = [];  % blank response
    DIr{k} = [];  % Direction index, raw data
    OIr{k} = [];  % Orientation index, raw data
    
    unc{k} = [];  % uncertainty in direction preference via bootstrap
    orth{k} = []; % orthogonal response
    drift{k} = [];% median drift of cell
    pref{k} = [];
    null{k} = [];
    anim{k} = [];
end;
changeDIme=[]; changeDIfe=[];
ages = [];
for i=1:length(expnames),
	tpf = [prefix expnames{i}],
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    age = findassociate(cells{1},'Eyes open','','');
    age = age.data;
    ages(end+1) = age;
    if age<=2, K = 1; else, K = 4; end;

    for j=1:length(cells),
        di_ = findassociate(cells{j},'TP Ach OT Fit Direction index','','');
	    ot_ = findassociate(cells{j},'TP Ach OT Fit Orientation index','','');
        di_s = findassociate(cells{j},'TP Ach OT Fit Direction index sp','','');
	    ot_s = findassociate(cells{j},'TP Ach OT Fit Orientation index sp','','');
        di_bl = findassociate(cells{j},'TP Ach OT Fit Direction index blr','','');
	    ot_bl = findassociate(cells{j},'TP Ach OT Fit Orientation index blr','','');        
        di_r = findassociate(cells{j},'TP Ach OT Direction index','','');
	    ot_r = findassociate(cells{j},'TP Ach OT Orientation index','','');        
		pvalasoc = findassociate(cells{j},'TP Ach OT vec varies p','','');
        blr_ = findassociate(cells{j},'TP Ach OT Blank Response','','');
        fitv = findassociate(cells{j},'TP Ach OT Carandini Fit','','');

        di_m = findassociate(cells{j},'TP ME Ach OT Fit Direction index','','');
	    ot_m = findassociate(cells{j},'TP ME Ach OT Fit Orientation index','','');
        di_sm = findassociate(cells{j},'TP ME Ach OT Fit Direction index sp','','');
	    ot_sm = findassociate(cells{j},'TP ME Ach OT Fit Orientation index sp','','');
        di_blm = findassociate(cells{j},'TP ME Ach OT Fit Direction index blr','','');
	    ot_blm = findassociate(cells{j},'TP ME Ach OT Fit Orientation index blr','','');        
		pvalasocm = findassociate(cells{j},'TP ME Ach OT vec varies p','','');
        blr_m = findassociate(cells{j},'TP ME Ach OT Blank Response','','');
        di_rm = findassociate(cells{j},'TP ME Ach OT Direction index','','');
	    ot_rm = findassociate(cells{j},'TP ME Ach OT Orientation index','','');        
        fitvm = findassociate(cells{j},'TP ME Ach OT Carandini Fit','','');

        di_f = findassociate(cells{j},'TP FE Ach OT Fit Direction index','','');
	    ot_f = findassociate(cells{j},'TP FE Ach OT Fit Orientation index','','');
        di_sf = findassociate(cells{j},'TP FE Ach OT Fit Direction index sp','','');
	    ot_sf = findassociate(cells{j},'TP FE Ach OT Fit Orientation index sp','','');
        di_blf = findassociate(cells{j},'TP FE Ach OT Fit Direction index blr','','');
	    ot_blf = findassociate(cells{j},'TP FE Ach OT Fit Orientation index blr','','');        
		pvalasocf = findassociate(cells{j},'TP FE Ach OT vec varies p','','');
        blr_f = findassociate(cells{j},'TP FE Ach OT Blank Response','','');
        di_rf = findassociate(cells{j},'TP FE Ach OT Direction index','','');
	    ot_rf = findassociate(cells{j},'TP FE Ach OT Orientation index','','');        
        fitvf = findassociate(cells{j},'TP FE Ach OT Carandini Fit','','');

        BS = findassociate(cells{j},'TP Ach OT Bootstrap Individual Responses','','');
        BSf = findassociate(cells{j},'TP Ach OT Bootstrap Carandini Fit Params','','');
        BSrs = findassociate(cells{j},'TP Ach OT Response struct','','');

        BSme = findassociate(cells{j},'TP ME Ach OT Bootstrap Individual Responses','','');
        BSfme = findassociate(cells{j},'TP ME Ach OT Bootstrap Carandini Fit Params','','');
        BSrsme = findassociate(cells{j},'TP ME Ach OT Response struct','','');

        BSfe = findassociate(cells{j},'TP FE Ach OT Bootstrap Individual Responses','','');
        BSffe = findassociate(cells{j},'TP FE Ach OT Bootstrap Carandini Fit Params','','');
        BSrsfe = findassociate(cells{j},'TP FE Ach OT Response struct','','');

		if ~isempty(pvalasoc)&pvalasoc.data<0.05,
            for k=[K 5 8 11 12],
                if (k==K)|((k==5)&((~isempty(pvalasocm)&pvalasocm.data>=0.05)|(~isempty(pvalasocf)&pvalasocf.data>=0.05)))|...
                        ((k==8)&isempty(pvalasocm)&isempty(pvalasocf))|((k==11)&isempty(pvalasocm)&~isempty(pvalasocf))|...
                        ((k==12)&(~isempty(pvalasocm)&pvalasocm.data<0.05)|((~isempty(pvalasocf)&pvalasocf.data<0.05))),
                    if k==12,
                        DIs = calc_bootstrap_di(BSf.data,BSrs.data.blankind,BS.data);
                    end;
                    DI{k}(end+1) = di_.data(1);
                    OI{k}(end+1) = ot_.data;
                    DIsp{k}(end+1) = di_s.data;
                    OIsp{k}(end+1) = ot_s.data;
                    DIbr{k}(end+1) = di_bl.data;
                    OIbr{k}(end+1) = ot_bl.data;
                    blr{k}(end+1) = blr_.data(1);
                    DIr{k}(end+1) = di_r.data;
                    OIr{k}(end+1) = ot_r.data;
                    unc{k}(end+1) = dpuncertainty(BSf.data(:,3));
                    pref{k}(end+1) = fit2pref(fitv.data);
                    null{k}(end+1) = fit2null(fitv.data);
                    orth{k}(end+1) = fit2orth(fitv.data);
                    drift{k}(end+1) = getdriftcorrection(cells{j},ds,1);
                    anim{k}(end+1) = i;
                end;
            end;
        end;
		if ~isempty(pvalasocm)&pvalasocm.data<0.05,
            for k=[2 6 9 13],
                if (k==2)|(k==6&(~isempty(pvalasoc)&pvalasoc.data>=0.05))|(k==9&isempty(pvalasoc))|...
                        ((k==13)&(~isempty(pvalasoc)&pvalasoc.data<0.05)),
                    if k==13,
                        [DIsme,angme] = calc_bootstrap_di(BSfme.data,BSrsme.data.blankind,BSme.data);
                        DIs = abs(DIs);
                        I = find(angdiff(angme-BSf.data(:,3))>90);
                        DIs(I) = - DIs(I);
                        changeDIme(end+1) = median(DIsme-DIs);
                    end;
                    DI{k}(end+1) = di_m.data;
                    OI{k}(end+1) = ot_m.data;
                    DIsp{k}(end+1) = di_sm.data;
                    OIsp{k}(end+1) = ot_sm.data;
                    DIbr{k}(end+1) = di_blm.data;
                    OIbr{k}(end+1) = ot_blm.data;
                    blr{k}(end+1) = blr_m.data(1);
                    DIr{k}(end+1) = di_rm.data;
                    OIr{k}(end+1) = ot_rm.data;
                    unc{k}(end+1) = dpuncertainty(BSfme.data(:,3));
                    orth{k}(end+1) = fit2orth(fitvm.data);
                    drift{k}(end+1) = getdriftcorrection(cells{j},ds,0);
                    pref{k}(end+1) = fit2pref(fitvm.data);
                    null{k}(end+1) = fit2null(fitvm.data);        
                    anim{k}(end+1) = i;
                end;
            end;
        end;
		if ~isempty(pvalasocf)&pvalasocf.data<0.05,
            for k=[3 7 10 14],
                if (k==3)|(k==7&(~isempty(pvalasoc)&pvalasoc.data>=0.05))|(k==10&~isempty(pvalasoc))|...
                        ((k==14)&(~isempty(pvalasoc)&pvalasoc.data<0.05)),
                    if k==14,
                        [DIsfe,angfe] = calc_bootstrap_di(BSffe.data,BSrsfe.data.blankind,BSfe.data);
                        DIs = abs(DIs);
                        I = find(angdiff(angfe-BSf.data(:,3))>90);
                        DIs(I) = - DIs(I);
                        changeDIfe(end+1) = median(DIsfe-DIs);
                    end;
                    DI{k}(end+1) = di_f.data;
                    OI{k}(end+1) = ot_f.data;
                    DIsp{k}(end+1) = di_sf.data;
                    OIsp{k}(end+1) = ot_sf.data;
                    DIbr{k}(end+1) = di_blf.data;
                    OIbr{k}(end+1) = ot_blf.data;
                    blr{k}(end+1) = blr_f.data(1);
                    DIr{k}(end+1) = di_rf.data;
                    OIr{k}(end+1) = ot_rf.data;            
                    unc{k}(end+1) = dpuncertainty(BSffe.data(:,3));
                    orth{k}(end+1) = fit2orth(fitvf.data);
                    drift{k}(end+1) = getdriftcorrection(cells{j},ds,0);
                    pref{k}(end+1) = fit2pref(fitvf.data);
                    null{k}(end+1) = fit2null(fitvf.data);      
                    anim{k}(end+1) = i;
                end;
            end;
        end;        
	end;
end;


labs{1} = {'DI','DI blank subtracted','DI raw'};
labs{2} = {'OI','OI blank subtracted','OI raw'};
cols = ['bgrk'];



D=figure; O=figure;
for i=1:2,
    if i==1, myDI = DI; myOI = OI; bins=[-Inf 0:0.01:1+0.01 Inf]; X = 0:0.01:1+ 0.01/2;
    elseif i==3, myDI = DIr; myOI = OIr; bins=[-Inf 0:0.01:2+0.01 Inf]; X = 0:0.01:2+ 0.01/2;
    elseif i==2, myDI = DIbr; myOI = OIbr; bins=[-Inf 0:0.01:1+0.01 Inf]; X = 0:0.01:1+ 0.01/2;
    end;
    
    for j=1:2,
        if j==1, figure(D); myD = myDI; else, figure(O); myD=myOI; end;
        subplot(2,1,i);
        inc = 1;
        for k=[1 13 14 4], % naive, motion, flash, experienced
            N=histc(myD{k},bins); N = 100*cumsum(N)/sum(sum(N));
            Y = [0:0.1:100];
            X = [0 prctile(myD{k},Y) 1];
            plot(X,[0 Y 100],['-' cols(inc)]);
            inc = inc + 1;
            hold on;
            plot([0 1],[50 50],'k--');
            axis([0 max(X) 0 100]);
            
            set(gca,'box','off');
            title(labs{j}{i});
        end;
    end;
end;

keyboard;
figure;

K=[1 13 14 4];
clf;
for i=1:4,
    anlist = unique(anim{K(i)});
    for j=1:length(anlist),
        inds = find(anim{K(i)}==anlist(j));
        mnsP{i}(j) = nanmean(pref{K(i)}(inds)-blr{K(i)}(inds));
        mnsN{i}(j) = nanmean(null{K(i)}(inds)-blr{K(i)}(inds));
    end;
    mymeanP(i) = mean(mnsP{i}');
    mystdeP(i) = stderr(mnsP{i}');
    mymeanN(i) = mean(mnsN{i}');
    mystdeN(i) = stderr(mnsN{i}');
end;
h=myerrorbar([1 4 7 10],mymeanP,mystdeP);
delete(h(2));hold on;
h=myerrorbar(1+[1 4 7 10],mymeanN,mystdeN);
delete(h(2));
bar([1 4 7 10],mymeanP,0.1);
bar(1+[1 4 7 10],mymeanN,0.1);

deltaRM = []; deltaRF = [];
deltaRNM = []; deltaRNF = [];
anlist = unique(anim{1});
for j=1:length(anlist),
    inds1 = find(anim{12}==anlist(j));
    inds2=find(anim{14}==anlist(j));
    inds3=find(anim{13}==anlist(j));
    [length(inds1) length(inds2) length(inds3)],
	if ~isempty(inds2),
        deltaRF =  [deltaRF pref{12}(inds1)-blr{12}(inds1)-(pref{14}(inds2)-blr{14}(inds2))];
        deltaRNF =  [deltaRNF null{12}(inds1)-blr{12}(inds1)-(null{14}(inds2)-blr{14}(inds2))];        
    elseif ~isempty(inds3),
        deltaRM = [deltaRM pref{12}(inds1)-blr{12}(inds1)-(pref{13}(inds3)-blr{13}(inds3))];
        deltaRNM = [deltaRNM null{12}(inds1)-blr{12}(inds1)-(null{13}(inds3)-blr{13}(inds3))];        
    end;
end;
