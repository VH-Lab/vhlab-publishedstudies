function analyzelinearnonlinear(prefix,expernames)

LINvals = [];
NLINvals = [];
LINinds = [];
NLINinds = [];
LINr2 = [];
NLINr2 = [];
LINpmn = [];
NLINpmn = [];
LINgof = [];
NLINgof = [];

for i=1:length(expernames),
    tpf = [prefix filesep expernames{i}];
    ds = dirstruct(tpf);
    [cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');
    
    for j=1:length(cells),
        P = findassociate(cells{j},'TP CEDE visual response p','','');
        if ~isempty(P)&P.data<0.05,
            [p,pmn]=isnonlinearcolor(cells{j});
            [Lin,Nlin,LINp,NLINp]=getlinearnonlinearparams(cells{j});
            cefit=findassociate(cells{j},'TP CEDE Color Fit','','');
            cefitnk=findassociate(cells{j},'TP CEDE Color NK Fit','','');
            cer = findassociate(cells{j},'TP CEDE Response struct','','');
            gf = gof([cer.data.ind{:}],cefit.data(2,:));
            if p<0.05,
                NLINinds(end+1) = j;
                NLINvals = [NLINvals; Nlin];
                NLINr2(end+1) = NLINp(8);
                NLINpmn(end+1) = pmn;
                NLINgof(end+1) = gf;
            else,
                LINinds(end+1) = j;
                LINvals = [LINvals; Lin];
                LINr2(end+1) = LINp(4);
                LINpmn(end+1) = pmn;
                LINgof(end+1) = gf;
            end; 
        end;
    end;
    
end;

keyboard;

