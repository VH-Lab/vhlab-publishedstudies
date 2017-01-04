function multipledianalysis(prefix,expernames) 

cvs = [];
cvfs = [];
cvsme = [];
cvsfe = [];
cvso = [];

fpsme = [];
fpsfe = [];

uncs = [];
uncfs = [];
uncme = [];
uncfe = [];
uncso = [];

for i=1:5,
    dis{i} = [];
    disf{i} = [];
    disme{i} = [];
    disfe{i} = [];
    dismeall{i} = [];
    disfeall{i} = [];
end;

distr = {'OT Fit Direction index blr', 'OT Fit Direction index bl', 'OT Dir Ind Vec', 'OT Direction index'};

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
        
        if ~isempty(P)&P.data<0.05&isempty(PME)&isempty(PFE),
            cvso(end+1) = cvdirection(cells{j},1);
            uncso(end+1) = dircelluncertainty(cells{j},1);
        end;
        
        if ~isempty(P)&P.data<.05&~isempty(PME)&PME.data<0.05,
            for k=1:4,
                DIA = findassociate(cells{j},['TP Ach ' distr{k}],'','');
                DIAME = findassociate(cells{j},['TP ME Ach ' distr{k}],'','');
                dis{k}(end+1) = DIA.data;
                disme{k}(end+1) = DIAME.data;
            end;
            dis{5}(end+1) = dimod(cells{j},1);
            disme{5}(end+1) = dimod(cells{j},0);
            cvs(end+1) = cvdirection(cells{j},1);
            cvsme(end+1) = cvdirection(cells{j},0);
            uncs(end+1) = dircelluncertainty(cells{j},1);
            uncme(end+1) = dircelluncertainty(cells{j},0);
            fpsme(end+1) = dircellflipprob(cells{j},0);            
        end;

        if ~isempty(PME)&PME.data<0.05,
            for k=1:4,
                DIA = findassociate(cells{j},['TP Ach ' distr{k}],'','');
                DIAME = findassociate(cells{j},['TP ME Ach ' distr{k}],'','');
                dismeall{k}(end+1) = DIAME.data;
            end;
            dismeall{5}(end+1) = dimod(cells{j},0);
        end;
        
        if ~isempty(P)&P.data<0.05&~isempty(PFE)&PFE.data<0.05,
             for k=1:4,
                DIA = findassociate(cells{j},['TP Ach ' distr{k}],'','');
                DIAFE = findassociate(cells{j},['TP FE Ach ' distr{k}],'','');
                disf{k}(end+1) = DIA.data;
                disfe{k}(end+1) = DIAFE.data;
            end;
            disf{5}(end+1) = dimod(cells{j},1);
            disfe{5}(end+1) = dimod(cells{j},2);
            cvfs(end+1) = cvdirection(cells{j},1);
            cvsfe(end+1) = cvdirection(cells{j},2);
            uncfs(end+1) = dircelluncertainty(cells{j},1);
            uncfe(end+1) = dircelluncertainty(cells{j},2);
            fpsfe(end+1) = dircellflipprob(cells{j},2);            
        end;
        if ~isempty(PFE)&PFE.data<0.05,
             for k=1:4,
                DIA = findassociate(cells{j},['TP Ach ' distr{k}],'','');
                DIAFE = findassociate(cells{j},['TP FE Ach ' distr{k}],'','');
                disfeall{k}(end+1) = DIAFE.data;
            end;
            disfeall{5}(end+1) = dimod(cells{j},2);
        end;
    end;
end;
keyboard;