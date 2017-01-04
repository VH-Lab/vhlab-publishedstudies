function analyzebootstrapdi(prefix,expernames) 

	%1=>all naive, 2=>naive only, 3=>naive w/ ME 4=>naive w/FE
        %5=>all ME, 6=>ME only, 7=>ME w/ naive
        %8=>all FE, 9=>FE only, 10=>FE w/ naive

for i=1:10, sigdi{i} = []; totdi{i} = []; end;

sigME = []; totME = [];
sigFE = []; totFE = [];
MEval = [];

dis = [];
disme = [];
disfe = [];

cis = [];
cisme = [];
cisfe = [];

sigMEori = [];
sigFEori = [];

cellarch = {};
cellnamearch = {};

for i=1:length(expernames),

	tpf = [prefix filesep expernames{i}],
	ds = dirstruct(tpf);
	[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');
    cellarch{end+1} = cells;
    cellnamearch{end+1} = cellnames;
    
	for j=1:length(cells),

		P = findassociate(cells{j},'TP Ach OT vec varies p','','');
		PME = findassociate(cells{j},'TP ME Ach OT vec varies p','','');
		PFE = findassociate(cells{j},'TP FE Ach OT vec varies p','','');
		DIA = findassociate(cells{j},'TP Ach OT Fit Direction index bl','','');
		DIAME = findassociate(cells{j},'TP ME Ach OT Fit Direction index bl','','');
		DIAFE = findassociate(cells{j},'TP FE Ach OT Fit Direction index bl','','');

		[pbefore,pafterme,pafterfe,pchangeme,pchangefe,cib,cime,cife,changeorime,changeorife]=bootstrap_di(cells{j});

		if ~isempty(P)&P.data<0.05,
			dis(end+1) = DIA.data;
            cis(end+1) = cib;
			totdi{1}(end+1) = i+j/10000;
			if pbefore<0.05, sigdi{1}(end+1) = i+j/10000; end;
			if (isempty(PME)|PME.data>=0.05)&(isempty(PFE)|PFE.data>=0.05),
				totdi{2}(end+1) = i+j/10000;
				if pbefore<0.05, sigdi{2}(end+1) = i+j/10000; end;
			end;
		end;
		if ~isempty(PME)&PME.data<0.05,
			disme(end+1) = DIAME.data;
            cisme(end+1) = cime;
			totdi{5}(end+1) = i+j/10000;
			if pafterme<0.05, sigdi{5}(end+1) = i+j/10000; end;
			if (isempty(P)|P.data>=0.05),
				totdi{6}(end+1) = i+j/10000;
				if pafterme<0.05, sigdi{6}(end+1) = i+j/10000; end;
            elseif ~isnan(P.data),
				totdi{7}(end+1) = i+j/10000;
				if pafterme<0.05, sigdi{7}(end+1) = i+j/10000; end;
			end;
		end;
		if ~isempty(PFE)&PFE.data<0.05,
			disfe(end+1) = DIAFE.data;
            cisfe(end+1) = cife;
			totdi{8}(end+1) = i+j/10000;
			if pafterfe<0.05, sigdi{8}(end+1) = i+j/10000; end;
			if (isempty(P)|P.data>=0.05),
				totdi{9}(end+1) = i+j/10000;
				if pafterfe<0.05, sigdi{9}(end+1) = i+j/10000; end;
            elseif ~isnan(P.data),
				totdi{10}(end+1) = i+j/10000;
				if pafterfe<0.05, sigdi{10}(end+1) = i+j/10000; end;
			end;
		end;

		if ~isempty(P)&~isempty(PME)&P.data<0.05&PME.data<0.05,
			totdi{3}(end+1) = i+j/10000;
			if pbefore<0.05, sigdi{3}(end+1) = i+j/10000; end;

			totME(end+1) = i+j/10000;
            MEval(end+1) = pchangeme;
            if changeorime<0.05, sigMEori(end+1) = i+j/10000; end;
			if pchangeme<0.05&pchangeme>=0, sigME(end+1) = i+j/10000;
			elseif pchangeme<0&pchangeme>-0.05, sigME(end+1) = -(i+j/10000);
			end;
		end;

		if ~isempty(P)&~isempty(PFE)&P.data<0.05&PFE.data<0.05,
			totdi{4}(end+1) = i+j/10000;
			if pbefore<0.05, sigdi{4}(end+1) = i+j/10000; end;

			totFE(end+1) = i+j/10000;
            if changeorife<0.05, sigFEori(end+1) = i+j/10000; end;
			if pchangefe<0.05&pchangefe>=0, sigFE(end+1) = i+j/10000;
			elseif pchangefe<0&pchangefe>-0.05, sigFE(end+1) = -(i+j/10000);
			end;
		end;
	end;
end;

keyboard;

 % generate plots
 
siginds = find(MEval>=0&MEval<0.05);
typicalinds=find( abs(MEval-median(abs(MEval)))<.2*median(abs(MEval)));

myinds = [ siginds([1 2 3 19 26 21 27 28 29]) typicalinds([4 15 28]) ];  %4 15

myfig=figure;
for i=1:length(myinds),
    subplot(4,3,i);
    hold on;
    plot([-100 1000],[0 0],'--','color',[0.001 0.001 .001],'linewidth',2);
    I = fix(totME(myinds(i)));
    c = round(10000*(totME(myinds(i))-fix(totME(myinds(i)))));
    plottpresponse(cellarch{I}{c},cellnamearch{I}{c},'Recovery OT Fit Pref BS',1,1);
    cellnamearch{I}{c},
    ch = get(gca,'children');
    for j=1:length(ch),
        try,
            set(ch(j),'linewidth',2);
            set(ch(j),'Marker','none');
            col = get(ch(j),'color');
            if eqlen(col,[0 0 0]), set(ch(j),'color',[1 0 0]); end;
            if eqlen(col,[0 0 0+.001]), set(ch(j),'color',[0 0 0]); end;
        end;
    end;
    set(gca,'visible','off'); xlabel(''); ylabel(''); title('');
    DIA = findassociate(cellarch{I}{c},'TP Ach OT Fit Direction index blr','','');
	DIAME = findassociate(cellarch{I}{c},'TP ME Ach OT Fit Direction index blr','','');
    text(180,.3,['DI=' num2str(DIA.data,2) ',' num2str(DIAME.data,2)],'horizontalalignment','center');
    axis([-10 359 -.05 0.25]);
end;
delete(findobj(myfig,'style','pushbutton'));

myfig=figure;
for i=1:length(myinds),
    subplot(4,3,i);
    hold on;
    plot([-100 1000],[0 0],'--','color',[0.001 0.001 .001],'linewidth',2);
    I = fix(totME(myinds(i)));
    c = round(10000*(totME(myinds(i))-fix(totME(myinds(i)))));
    testname = 'Best orientation test'; dataname = 'Best orientation resp raw';
    fname = ['e:\2photon\ferretdirection\' cellnamearch{I}{c}(end-9:end)];
    fname(find(fname=='_')) = '-';
    ds = dirstruct(fname);
    psth = tpquickpsth(ds,testname,dataname,cellarch{I}{c},cellnamearch{I}{c},1,1.5,0.5);
    cellnamearch{I}{c},
    bestsum = -Inf; bestind = [];
    intv = 10:19;
    if 1,
    for j=1:length(psth.avg),
        if sum(psth.avg{j}(intv))>bestsum,
            bestsum = sum(psth.avg{j}(intv));
            bestind = j;
        end;
    end;
    plot(psth.bins,psth.avg{bestind},'linewidth',2);
    else,
        for j=1:length(psth.avg),
            plot(psth.bins,psth.avg{j},'linewidth',2);                
        end;
    end;
    set(gca,'visible','off'); xlabel(''); ylabel(''); title('');
    plot([0 5],-.075*[1 1],'k','linewidth',2);
    axis([-5 10 -.1 0.3]);
end;



dpb = [];
dpa = [];
tr = [];

for i=1:length(siginds),
    I = fix(totME(siginds(i)));
    c = round(10000*(totME(siginds(i))-fix(totME(siginds(i)))));
    DPB = findassociate(cellarch{I}{c},'TP Ach OT Fit Pref','',''),
	DPA = findassociate(cellarch{I}{c},'TP ME Ach OT Fit Pref','',''),
    TR = findassociate(cellarch{I}{c},'Training direction','',''),
    dpb(end+1) = DPB.data;
    dpa(end+1) = DPA.data;
    if isempty(TR), tr(end+1) = NaN; 
    else, tr(end+1) = mod(TR.data(1),180); end;
end;

for i=1:length(sigME),
    I = fix(sigME(i));
    c = round(10000*(sigME(i)-fix(sigME(i))));
    figure;
    plottpresponse(cellarch{I}{c},cellnamearch{I}{c},'Recovery OT Fit Pref',1,1);
end;



for i=1:length(sigMEori),
    I = fix(sigMEori(i));
    c = round(10000*(sigMEori(i)-fix(sigMEori(i))));
    figure;
    subplot(2,1,1);
    plottpresponse(cellarch{I}{c},cellnamearch{I}{c},'Recovery OT Fit Pref',1,1);
    [pbefore,pafterme,pafterfe,pchangeme,pchangefe,cib,cime,cife,changeorime,changeorife]=bootstrap_di(cellarch{I}{c});
end;

[dummy,indd]=setdiff(totdi{1},sigdi{1});
[dummy,inddummy,ind]=intersect(sigdi{1},totdi{1});

[Yn,Xn] = slidingwindowfunc([dis(ind) dis(indd)],[ones(size(ind)) 0*ones(size(indd))],0,0.05,1,0.1,'mean',0);

[dummy,indd1]=setdiff(g1.totdi{1},g1.sigdi{1});
[dummy,inddummy,ind1]=intersect(g1.sigdi{1},g1.totdi{1});
[dummy,indd2]=setdiff(g2.totdi{1},g2.sigdi{1});
[dummy,inddummy,ind2]=intersect(g2.sigdi{1},g2.totdi{1});

figure;
[Yn,Xn,Yerr] = slidingwindowfunc([g1.dis(ind1) g1.dis(indd1) g2.dis(ind2) g2.dis(indd2)],[ones(size(ind1)) 0*ones(size(indd1)) ones(size(ind2)) 0*ones(size(indd2))],-0.05,0.05,1.05,0.1,'mean',0);
h=myerrorbar(Xn,100*Yn,100*Yerr,'k-'); set(h,'linewidth',2); set(gca,'fontweight','bold'); posterize(gcf);
axis([-.1 1.1 0 100]);
ylabel('Significant direction selectivity (%)'); xlabel('DI');
