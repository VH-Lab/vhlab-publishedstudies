function countsconecells(prefix,expernames)

cesconepos = [];
cesconeneg = [];
ce = [];

cesconeposotvisp = [];
cesconenegotvisp = [];
cesconeposotvecp = [];
cesconenegotvecp = [];
cesconeposotblr = [];
cesconenegotblr = [];
cesconeposotind = [];
cesconenegotind = [];
cesconeposotflank = [];
cesconenegotflank = [];

cesconeposotsvisp = [];
cesconenegotsvisp = [];
cesconeposotsvecp = [];
cesconenegotsvecp = [];
cesconeposotsblr = [];
cesconenegotsblr = [];
cesconeposotsind = [];
cesconenegotsind = [];
cesconeposotsflank = [];
cesconenegotsflank = [];


for j=1:length(expernames),
    tpf = [fixpath(prefix) expernames{j}];
    ds = dirstruct(tpf);
    [cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
    
    for i=1:length(cells),
        otvisp = findassociate(cells{i},'TP Ach OT visual response p','','');
        otvecp = findassociate(cells{i},'TP Ach OT vec varies p','','');
        otbl = findassociate(cells{i},'TP Ach OT Blank Response','','');
        otfitpa = findassociate(cells{i},'TP Ach OT Carandini Fit Params','','');
        otfita = findassociate(cells{i},'TP Ach OT Carandini Fit','','');
        otinda = findassociate(cells{i},'TP Ach OT Fit Orientation index blr','','');
        
        cep = findassociate(cells{i},'TP CE visual response p','','');
        ceps = findassociate(cells{i},'TP sig S cone','','');
        
        otsvisp = findassociate(cells{i},'TP S OT visual response p','','');
        otsvecp = findassociate(cells{i},'TP S OT vec varies p','','');
        otsbl = findassociate(cells{i},'TP S OT Blank Response','','');
        otsfitpa = findassociate(cells{i},'TP S OT Carandini Fit Params','','');
        otsfita = findassociate(cells{i},'TP S OT Carandini Fit','','');
        otsinda = findassociate(cells{i},'TP S OT Fit Orientation index blr','','');

        
        if ~isempty(cep)&cep.data<0.05&ceps.data==1,
            cesconepos = [cesconepos; j i ];
        elseif ~isempty(cep)&cep.data<0.05,
            cesconeneg = [cesconeneg; j i];
        end;

        if ~isempty(otvisp),
            Ot = otfitpa.data(3);
            fitcurve = otfita.data(2,:);
            OtPi = findclosest(0:359,Ot); OtNi = findclosest(0:359,mod(Ot+180,360));
            OtO1i = findclosest(0:359,mod(Ot+90,360)); OtO2i = findclosest(0:359,mod(Ot-90,360));
            flank=mean([fitcurve(OtO1i) fitcurve(OtO2i)]);
        end;
        if ~isempty(otsvisp),
            Ot = otsfitpa.data(3);
            fitcurve = otsfita.data(2,:);
            OtPi = findclosest(0:359,Ot); OtNi = findclosest(0:359,mod(Ot+180,360));
            OtO1i = findclosest(0:359,mod(Ot+90,360)); OtO2i = findclosest(0:359,mod(Ot-90,360));
            flanks=mean([fitcurve(OtO1i) fitcurve(OtO2i)]);
        end;
        
        if ~isempty(cep)&cep.data<0.05&~isempty(otvisp)&otvisp.data<0.05, 
            if ceps.data==1,
                cesconeposotvisp = [cesconeposotvisp; j i];
                if otvecp.data<0.05,
                    cesconeposotvecp = [cesconeposotvecp; j i];
                    cesconeposotblr(end+1) = otbl.data(1);
                    cesconeposotind(end+1) = otinda.data;                   
                    cesconeposotflank(end+1) = flank;
                end;
            else,
                cesconenegotvisp = [cesconenegotvisp; j i];
                if otvecp.data<0.05,
                    cesconenegotvecp = [cesconenegotvecp; j i];
                    cesconenegotblr(end+1) = otbl.data(1);
                    cesconenegotind(end+1) = otinda.data;
                    cesconenegotflank(end+1) = flank;
                end;                
            end;
        end;
        
        if ~isempty(cep)&cep.data<0.05&~isempty(otsvisp)&otsvisp.data<0.05, 
            if ceps.data==1,
                cesconeposotsvisp = [cesconeposotsvisp; j i];
                if otsvecp.data<0.05,
                   cesconeposotsvecp = [cesconeposotsvecp; j i];
                   cesconeposotsblr(end+1) = otsbl.data(1);
                   cesconeposotsind(end+1) = otsinda.data;
                   cesconeposotsflank(end+1) = flanks;
                end;
            else,
                cesconenegotsvisp = [cesconenegotsvisp; j i];
                if otsvecp.data<0.05,
                    cesconenegotsvecp = [cesconenegotsvecp; j i];
                    cesconenegotsblr(end+1) = otsbl.data(1);
                    cesconenegotsind(end+1) = otsinda.data;
                   cesconenegotsflank(end+1) = flanks;
                end;
            end;
        end;        
    end;
end;

SCP = size(cesconepos,1); SCN = size(cesconeneg,1);

disp(['Detectable S-cone input: ' int2str(SCP) ' of ' int2str(SCN+SCP) ' (' num2str(100*SCP/(SCN+SCP)) '%)']);

SCPOTVISP = size(cesconeposotvisp,1);
SCPOTVECP = size(cesconeposotvecp,1);

disp(['Detectable S-cone + ori responses: ' int2str(SCPOTVECP) ' of ' int2str(SCPOTVISP) ' (' num2str(100*SCPOTVECP/SCPOTVISP) '%)']);

SCNOTVISP = size(cesconenegotvisp,1);
SCNOTVECP = size(cesconenegotvecp,1);

disp(['No detectable S-cone + ori responses: ' int2str(SCNOTVECP) ' of ' int2str(SCNOTVISP) ' (' num2str(100*SCNOTVECP/SCNOTVISP) '%)']);

SCPOTSVISP = size(cesconeposotsvisp,1);
SCPOTSVECP = size(cesconeposotsvecp,1);

disp(['Detectible S-cone + Sori responses: ' int2str(SCPOTSVECP) ' of ' int2str(SCPOTSVISP) ' (' num2str(100*SCPOTSVECP/SCPOTSVISP) '%)']);

SCNOTSVISP = size(cesconenegotsvisp,1);
SCNOTSVECP = size(cesconenegotsvecp,1);

disp(['No detectable S-cone + Sori responses: ' int2str(SCNOTSVECP) ' of ' int2str(SCNOTSVISP) ' (' num2str(100*SCNOTSVECP/SCNOTSVISP) '%)']);

disp(['Detectable S-cone ori blanks: ' num2str(mean(cesconeposotblr)) ' +/- ' num2str(stderr(cesconeposotblr')) '.']);
disp(['No detectable S-cone ori blanks: ' num2str(mean(cesconenegotblr)) ' +/- ' num2str(stderr(cesconenegotblr')) '.']);

disp(['Detectable S-cone Sori blanks: ' num2str(mean(cesconeposotsblr)) ' +/- ' num2str(stderr(cesconeposotsblr')) '.']);
disp(['No detectable S-cone Sori blanks: ' num2str(mean(cesconenegotsblr)) ' +/- ' num2str(stderr(cesconenegotsblr')) '.']);

disp(['Detectable S-cone ori ind: ' num2str(mean(cesconeposotind)) ' +/- ' num2str(stderr(cesconeposotind')) '.']);
disp(['No detectable S-cone ori ind: ' num2str(mean(cesconenegotind)) ' +/- ' num2str(stderr(cesconenegotind')) '.']);

disp(['Detectable S-cone Sori ind: ' num2str(mean(cesconeposotsind)) ' +/- ' num2str(stderr(cesconeposotsind')) '.']);
disp(['No detectable S-cone Sori ind: ' num2str(mean(cesconenegotsind)) ' +/- ' num2str(stderr(cesconenegotsind')) '.']);

disp(['Detectable S-cone ori flank: ' num2str(mean(cesconeposotflank)) ' +/- ' num2str(stderr(cesconeposotflank')) '.']);
disp(['No detectable S-cone ori flank: ' num2str(mean(cesconenegotflank)) ' +/- ' num2str(stderr(cesconenegotflank')) '.']);

disp(['Detectable S-cone Sori flank: ' num2str(mean(cesconeposotsflank)) ' +/- ' num2str(stderr(cesconeposotsflank')) '.']);
disp(['No detectable S-cone Sori flank: ' num2str(mean(cesconenegotsflank)) ' +/- ' num2str(stderr(cesconenegotsflank')) '.']);
