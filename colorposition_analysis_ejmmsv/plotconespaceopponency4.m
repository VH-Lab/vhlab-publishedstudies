function plotconespaceopponency3(g)

if nargin==0,
    
end;

CO2 = [];
CO1 = [];
CO0 = [];
SO2 = [];
SO1 = [];
SO0 = [];

CO2SO2=[];
CO1SO1=[];
CO2SO0=[];
CO0SO2=[];

SigS = []; PS = [];
SigSR = []; PSR = [];
SigSLin = []; PSLin = [];
SigSNK = []; PSNK = [];



SigSR2 = []; SigS2 = []; SigSNK2 = [];

OT = []; OTs = [];
OI = []; OIs = [];
CV = []; CVs = [];

SLr = [];

ModType2PCC = [];ModType2PPCbs=zeros(length(g.myinds),100);
ModTypeLin = [];ModTypeLinbs=zeros(length(g.myinds),100);
ModTypeLNK = [];ModTypeLNKbs=zeros(length(g.myinds),100);

for i=1:length(g.myinds),
    R4=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4 Fit','','');
    R4R=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4R Fit','','');
    Lin=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color Fit','','');
    NK=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color NK Fit','','');
    R4fit=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Color R4 Fit','','');
    RSP=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Response struct','','');
    OV = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT visual response p','','');
    OVs = findassociate(g.cellarch{g.myinds(i)},'TP S OT visual response p','','');
    myOI = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT Fit Orientation index blr','','');
    myCV = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT Circular variance','','');
    myOT = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT Tuning width','','');
    myOIs = findassociate(g.cellarch{g.myinds(i)},'TP S OT Fit Orientation index blr','','');
    myCVs = findassociate(g.cellarch{g.myinds(i)},'TP S OT Circular variance','','');
    myOTs = findassociate(g.cellarch{g.myinds(i)},'TP S OT Tuning width','','');
    
    ModType2PPC(i) = -1;
    if ~isempty(R4fit),
        ModType2PPC(i) = Get2PCCModType(R4fit.data.se, R4fit.data.si, R4fit.data.le, R4fit.data.li);
    end;
    ModType2PPCbs(i,1:100) = -1;
    if ~isempty(R4),
        for j=1:100,
            ModType2PPCbs(i,j) = Get2PCCModType(R4.data(j).se, R4.data(j).si, R4.data(j).le, R4.data(j).li);
        end;
    end;
    
    
    [p_nlvsln, p_lnvsmn, p_rctvsln, p_nlvsrct, p_r4vsln, p_r4vsnl, linvsr4, nlvsr4, whichmodel]=isnonlinearcolor(g.cellarch{g.myinds(i)});
    if ~isempty(OV)&OV.data<0.05,
        OT(i) = myOT.data; OI(i) = myOI.data; CV(i) = myCV.data;
    else,
        OT(i)=NaN;OI(i)=NaN;CV(i)=NaN;
    end;

    if ~isempty(OVs)&OVs.data<0.05,
        OTs(i) = myOTs.data; OIs(i) = myOIs.data; CVs(i) = myCVs.data;
    else,
        OTs(i)=NaN;OIs(i)=NaN;CVs(i)=NaN;
    end;

    CO2(i) = 0; SO2(i) = 0; CO1(i) = 0; SO1(i) = 0; CO0(i) = 0; SO0(i) = 0;
    SigS(i) = 0; SigSR(i) = 0; SigSLin(i) = 0; SigSNK(i) = 0;
    SigS2(i) = 0; SigSR2(i) = 0; SigSLin2(i) = 0; SigSNK2(i) = 0;
    PSNKl=[];SNKS = [NK.data.s]; LNKS=[ NK.data.l]; SN50=[NK.data.sc50]; LN50=[NK.data.lc50]; SNNK=[NK.data.sn]; LNNK=[NK.data.ln];
    for j=1:length([NK.data.s]),
        PSNKl(j) = abs(SNKS(j).*naka_rushton_func(0.5,SN50(j),SNNK(j)))./(abs(SNKS(j).*naka_rushton_func(0.5,SN50(j),SNNK(j)))+abs(LNKS(j).*naka_rushton_func(0.5,LN50(j),LNNK(j))));
        ModTypeLNKbs(i,j) = 3*double(sign(SNKS(j))==sign(LNKS(j)))+4*double(sign(SNKS(j))~=sign(LNKS(j)));
    end;
    ModTypeLNK(i) = mode(ModTypeLNKbs(i,:));

    PSNK(i) = mean(PSNKl);
    PSLin(i) = mean(abs([Lin.data.s])./(abs([Lin.data.s])+abs([Lin.data.l])));
    PS(i) = mean((abs([R4.data.se])+abs([R4.data.si]))./((abs([R4.data.se])+abs([R4.data.si]))+(abs([R4.data.le])+abs([R4.data.li]))));
    PSR(i) = mean((abs([R4R.data.se])+abs([R4R.data.si]))./(0*abs([R4R.data.re])+0*abs([R4R.data.ri])+abs([R4R.data.se])+abs([R4R.data.si])+abs([R4R.data.le])+abs([R4R.data.li])));
    SLr(i) = max(RSP.data.curve(2,4),0)./(max(RSP.data.curve(2,4),0)+max(RSP.data.curve(2,10),0));

    SNK = [NK.data.s];LNK=[NK.data.l];
    if (prctile(SNK,5)>0&prctile(SNK,95)>0) | (prctile(SNK,5)<0&prctile(SNK,95)<0), SigSNK(i) = 1; end;
    if SigSNK(i)&PSNK(i)>.1, SigSNK2(i) = 1; end;
    SigLNK(i) = 0; SigLNK2(i) = 0;
    if (prctile(LNK,5)>0&prctile(LNK,95)>0) | (prctile(LNK,5)<0&prctile(LNK,95)<0), SigLNK(i) = 1; end;
    if SigLNK(i)&PSNK(i)<0.9, SigLNK2(i) = 1; end;
    
    GOF1(i) = colorgofmodel(g.cellarch{g.myinds(i)},1);
    GOF2(i) = colorgofmodel(g.cellarch{g.myinds(i)},2);
    GOF4(i) = colorgofmodel(g.cellarch{g.myinds(i)},4);
    
    COL(i) = 2*(prctile(double(sign([Lin.data.s])~=sign([Lin.data.l])),95)&PSLin(i)>.1&PSLin(i)<.9);
    if COL(i)==2, CAL(i) = 0;
    else, CAL(i) = 2*double(((prctile([Lin.data.s],5)>0&prctile([Lin.data.s],95)>0) & (prctile([Lin.data.l],5)>0&prctile([Lin.data.l],95)>0))&PSLin(i)>.1) + ...
        2*double(((prctile([Lin.data.s],5)<0&prctile([Lin.data.s],95)<0) & (prctile([Lin.data.l],5)<0&prctile([Lin.data.l],95)<0))&PSLin(i)>.1);
    if CAL(i)==0, CAL(i) = 1*(prctile(double(sign([Lin.data.s])==sign([Lin.data.l])),95)&PSLin(i)>.1&PSLin(i)<.9); end;end;

    SOL(i) = double(((prctile([Lin.data.s],5)>0&prctile([Lin.data.s],95)>0) | (prctile([Lin.data.s],5)<0&prctile([Lin.data.s],95)<0))&PSLin(i)>.1) + ...
        double(((prctile([Lin.data.l],5)>0&prctile([Lin.data.l],95)>0))&PSLin(i)<.9);
    if COL(i)==2, SOL(i) = 2; end;
    CONK(i) = 2*(prctile(double(sign([NK.data.s])~=sign([NK.data.l])),95)&PSNK(i)>.1&PSNK(i)<.9);
    if CONK(i)==2, CANK(i) = 0;
    else, CANK(i) = 2*double(((prctile([NK.data.s],5)>0&prctile([NK.data.s],95)>0) & (prctile([NK.data.l],5)>0&prctile([NK.data.l],95)>0))&PSNK(i)>.1) + ...
        2*double(((prctile([NK.data.s],5)<0&prctile([NK.data.s],95)<0) & (prctile([NK.data.l],5)<0&prctile([NK.data.l],95)<0))&PSNK(i)>.1);
    if CANK(i)==0, 1*(prctile(double(sign([NK.data.s])==sign([NK.data.l])),95)&PSNK(i)>.1&PSNK(i)<.9); end; end;
    SONK(i) = double((prctile([NK.data.s],5)>0&prctile([NK.data.s],95)>0) | (prctile([NK.data.s],5)<0&prctile([NK.data.s],95)<0)&PSNK(i)>.1) + ...
       double( (prctile([NK.data.l],5)>0&prctile([NK.data.l],95)>0) | (prctile([NK.data.l],5)<0&prctile([NK.data.l],95)<0)&PSNK(i)<.9);
   if CONK(i)==2, SONK(i) = 2; end;
    
    VR4 = align2pccfits([ [R4.data.se]' [R4.data.le]' [R4.data.si]' [R4.data.li]']);
    VR4R = align2pccfits([[R4R.data.se]' [R4R.data.le]' [R4R.data.re]' [R4R.data.si]' [R4R.data.li]' [R4R.data.ri]']);
    VR4L = align2pccfits([ [R4.data.se]' [R4.data.le]' [R4.data.si]' [R4.data.li]'],1);
    Se_ = VR4(:,1); Si_ = VR4(:,3);
    SeR_ = VR4R(:,1); SiR_ = VR4R(:,4);
    Le_ = VR4(:,2); Li_ = VR4(:,4);
    LeR_ = VR4R(:,2); LiR_ = VR4R(:,5);
    Pse = prctile(VR4(:,1),[20 80]); Psed0 = all(Pse>0)|all(Pse<0);
    Psi = prctile(VR4(:,3),[20 80]); Psid0 = all(Psi>0)|all(Psi<0);
    Ple = prctile(VR4(:,2),[20 80]); Pled0 = all(Ple>0)|all(Ple<0);
    Pli = prctile(VR4(:,4),[20 80]); Plid0 = all(Pli>0)|all(Pli<0);
    Pse2 = prctile(VR4L(:,1),[15 85]); Psed02 = all(Pse2>0)|all(Pse2<0);
    Psi2 = prctile(VR4L(:,3),[15 85]); Psid02 = all(Psi2>0)|all(Psi2<0);
    Ple2 = prctile(VR4L(:,2),[15 85]); Pled02 = all(Ple2>0)|all(Ple2<0);
    Pli2 = prctile(VR4L(:,4),[15 85]); Plid02 = all(Pli2>0)|all(Pli2<0);
    FSE = mean(abs(VR4L(:,1))./(abs(VR4L(:,1))+abs(VR4L(:,2))+abs(VR4L(:,3))+abs(VR4L(:,4))));
    FSI = mean(abs(VR4L(:,3))./(abs(VR4L(:,1))+abs(VR4L(:,2))+abs(VR4L(:,3))+abs(VR4L(:,4))));
    FLE = mean(abs(VR4L(:,2))./(abs(VR4L(:,1))+abs(VR4L(:,2))+abs(VR4L(:,3))+abs(VR4L(:,4))));
    FLI = mean(abs(VR4L(:,4))./(abs(VR4L(:,1))+abs(VR4L(:,2))+abs(VR4L(:,3))+abs(VR4L(:,4))));
    
    %if i==13, keyboard; end;
    for j=1:length(R4.data),
        CO2(i,j) = double(sign(R4.data(j).le)~=sign(R4.data(j).se)&&(sign(R4.data(j).li)~=sign(R4.data(j).si)));
        SO2(i,j) = double(sign(R4.data(j).le)~=sign(R4.data(j).li)&&(sign(R4.data(j).si)~=sign(R4.data(j).se)));
        CO1(i,j) = xor((sign(R4.data(j).le)~=sign(R4.data(j).se)),(sign(R4.data(j).li)~=sign(R4.data(j).si)));
        SO1(i,j) = xor((sign(R4.data(j).le)~=sign(R4.data(j).li)),(sign(R4.data(j).si)~=sign(R4.data(j).se)));
        CO0(i,j) = double(sign(R4.data(j).le)==sign(R4.data(j).se)&&(sign(R4.data(j).li)==sign(R4.data(j).si)));
        SO0(i,j) = double(sign(R4.data(j).le)==sign(R4.data(j).li)&&(sign(R4.data(j).si)==sign(R4.data(j).se)));
    end;
    SO_(i) = (Psed0&Psid0)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,3)))) + 0.5*sqrt(-1)*xor(Psed0,Psid0) + (Pled0&Plid0)*(sign(mean(VR4(:,2)))~=sign(mean(VR4(:,4)))) + 0.5*sqrt(-1)*xor(Pled0,Plid0); 
    CO_(i) = (Psed0&Pled0)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,2)))) + 0.5*sqrt(-1)*xor(Psed0,Pled0) + (Psid0&Plid0)*(sign(mean(VR4(:,3)))~=sign(mean(VR4(:,4)))) + 0.5*sqrt(-1)*xor(Plid0,Psid0); 
    SO_2(i) = (Psed02&Psid02)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,3)))) + 0.5*sqrt(-1)*xor(Psed02,Psid02) + (Pled02&Plid02)*(sign(mean(VR4(:,2)))~=sign(mean(VR4(:,4)))) + 0.5*sqrt(-1)*xor(Pled02,Plid02); 
    CO_2(i) = (Psed02&Pled02)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,2)))) + 0.5*sqrt(-1)*xor(Psed02,Pled02) + (Psid02&Plid02)*(sign(mean(VR4(:,3)))~=sign(mean(VR4(:,4)))) + 0.5*sqrt(-1)*xor(Plid02,Psid02); 

    SO_3(i) = (FSE>.05&Psed02&Psid02&FSI>.05)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,3)))) + 0.5*sqrt(-1)*xor(Psed02&FSE>.05,Psid02&FSI>.05) + (Pled02&FLE>.05&Plid02&FLI>.05)*(sign(mean(VR4(:,2)))~=sign(mean(VR4(:,4)))) + 0.5*sqrt(-1)*xor(Pled02&FLE>.05,Plid02&FLI>.05); 
    CO_3(i) = (FSE>.05&Psed02&Pled02&FLE>.05)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,2)))) + 0.5*sqrt(-1)*xor(Psed02&FSE>.05,Pled02&FLE>.05) + (Psid02&FSI>.05&Plid02&FLI>.05)*(sign(mean(VR4(:,3)))~=sign(mean(VR4(:,4)))) + 0.5*sqrt(-1)*xor(Plid02&FLI>.05,Psid02&FSI>.05); 

    SO_4(i) = (FSE>.05&Psed02&Psid02&FSI>.05)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,3)))) + (Pled02&FLE>.05&Plid02&FLI>.05)*(sign(mean(VR4(:,2)))~=sign(mean(VR4(:,4)))); 
    CO_4(i) = (FSE>.05&Psed02&Pled02&FLE>.05)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,2)))) + (Psid02&FSI>.05&Plid02&FLI>.05)*(sign(mean(VR4(:,3)))~=sign(mean(VR4(:,4)))); 
    CA_4(i) = (FSI>.05&Psid02&Pled02&FLE>.05)*(sign(mean(VR4(:,3)))~=sign(mean(VR4(:,2)))) + (Psed02&FSE>.05&Plid02&FLI>.05)*(sign(mean(VR4(:,1)))~=sign(mean(VR4(:,4)))); 

    
    SOs5_(i) = xor(Psed0,Psid0);
    SOl5_(i) = xor(Pled0,Plid0);
    COe5_(i) = -Psed0+Pled0;
    COi5_(i) = -Psid0+Plid0;
    
    SOs52_(i) = xor(Psed02,Psid02);
    SOl52_(i) = xor(Pled02,Plid02);
    COe52_(i) = -Psed02+Pled02;
    COi52_(i) = -Psid02+Plid02;
    
    SOs53_(i) = xor(Psed02&FSE>.05,Psid02&FSI>.05);
    SOl53_(i) = xor(Pled02&FLE>.05,Plid02&FLI>.05);
    COe53_(i) = -(Psed02&FSE>.05)+(Pled02&FLE>.05);
    COi53_(i) = -(Psid02&FSI>.05)+(Plid02&FLI>.05);    

    [myl,mys] = getdaceysconeinput(g.cellarch{g.myinds(i)},'linear');
	SLLIN(i) = abs(mys)/(abs(myl)+abs(mys));
    [myl,mys] = getdaceysconeinput(g.cellarch{g.myinds(i)},'nk');
	SLNK(i) = abs(mys)/(abs(myl)+abs(mys)); 
    [myl,mys] = getdaceysconeinput(g.cellarch{g.myinds(i)},'R4');
    SLR4(i) = sum(abs(mys))/(sum(abs(myl))+sum(abs(mys)));
    
    switch whichmodel,
        case 1,
            COG(i) = COL(i); SOG(i) = SOL(i);
            COGs(i) = 0; COGl(i) = 0; COGe(i) = 0; COGi(i) = 0;
            CAG(i) = CAL(i);
            SLB(i) = SLLIN(i);
        case 2,
            COG(i) = CONK(i); SOG(i) = SONK(i);
            COGs(i) = 0; COGl(i) = 0; COGe(i) = 0; COGi(i) = 0;
            CAG(i) = CANK(i);
            SLB(i) = SLNK(i);
        case 4,
%            COG(i) = CO_3(i); SOG(i) = SO_3(i);
%            COGs(i) = SOs53_(i); COGl(i) = SOl53_(i); COGe(i) = COe53_(i); COGi(i) = COi53_(i);
            COG(i) = CO_4(i); SOG(i) = SO_4(i);
            COGs(i) = SOs53_(i); COGl(i) = SOl53_(i); COGe(i) = COe53_(i); COGi(i) = COi53_(i);
            CAG(i) = CA_4(i);
            SLB(i) = SLR4(i);
        otherwise, disp(['error']);
    end;
    WM(i) = whichmodel;
    SigS(i) = (prctile(Se_,5)>0&prctile(Se_,95)>0) | (prctile(Se_,5)<0&prctile(Se_,95)<0) | (prctile(Si_,5)>0&prctile(Si_,95)>0) | (prctile(Si_,5)<0&prctile(Si_,95)<0);
    SigSR(i) = (prctile(SeR_,5)>0&prctile(SeR_,95)>0) | (prctile(SeR_,5)<0&prctile(SeR_,95)<0) | (prctile(SiR_,5)>0&prctile(SiR_,95)>0) | (prctile(SiR_,5)<0&prctile(SiR_,95)<0);
    SigL(i) = (prctile(Le_,5)>0&prctile(Le_,95)>0) | (prctile(Le_,5)<0&prctile(Le_,95)<0) | (prctile(Li_,5)>0&prctile(Li_,95)>0) | (prctile(Li_,5)<0&prctile(Li_,95)<0);
    SigLR(i) = (prctile(LeR_,5)>0&prctile(LeR_,95)>0) | (prctile(LeR_,5)<0&prctile(LeR_,95)<0) | (prctile(LiR_,5)>0&prctile(LiR_,95)>0) | (prctile(LiR_,5)<0&prctile(LiR_,95)<0);
    if SigSR(i)&PSR(i)>.1, SigSR2(i) = 1; end;
    if SigS(i)&PS(i)>.1, SigS2(i) = 1; end;
    if SigLR(i)&PSR(i)<.9, SigLR2(i) = 1; end;
    if SigL(i)&PS(i)<.9, SigL2(i) = 1; end;
        SLINS = [Lin.data.s]; LLINS = [Lin.data.l];
    if (prctile(SLINS,5)>0&prctile(SLINS,95)>0) | (prctile(SLINS,5)<0&prctile(SLINS,95)<0), SigSLin(i) = 1; end;
    ModTypeLinbs(i,:) = 3*double(sign(SLINS)==sign(LLINS))+4*double(sign(SLINS)~=sign(LLINS));
    ModTypeLin(i) = mode(ModTypeLinbs(i,:));
    
    if SigSLin(i)&SLLIN(i)>.1, SigSLin2(i) = 1; end;    
    if ~SigS(i)&0, ModType2PPC(i) = 1; end;
    if ~SigL(i)&0, ModType2PPC(i) = 2; end;
    SigSt(i) = PS(i)>.1; SigSR(i) = PSR(i)>.1; SigLt(i) = PS(i)<0.9; SigLRt(i) = PSR(i)<0.9;
    
end;
 %   inds = find(SigS);
inds = 1:167;



disp(['SigS: ' int2str(sum(SigS)) '.']);
disp(['SigSR: ' int2str(sum(SigSR)) '.']);
disp(['SigSNK: ' int2str(sum(SigSNK)) '.']);

disp(['SigS2: ' int2str(sum(SigS2)) '.']);
disp(['SigSR2: ' int2str(sum(SigSR2)) '.']);
disp(['SigSNK2: ' int2str(sum(SigSNK2)) '.']);

WM1guys = find(WM==1);
WM2guys = find(WM==2);
ModType2PCC(WM1guys) = ModTypeLin(WM1guys);
ModType2PCCbs(WM1guys,:) = ModTypeLinbs(WM1guys,:);
ModType2PCC(WM2guys) = ModTypeLNK(WM2guys);
ModType2PCCbs(WM2guys,:) = ModTypeLNKbs(WM2guys,:);


nosigsguys = find( (WM==1&~SigSLin) | (WM==2&~SigSNK));
ModType2PPC(nosigsguys) = 1;
ModType2PPCbs(nosigsguys,:) = 1;
ModType2PCC(find(ModType2PCC==9)) = 4;
ModType2PPCbs(find(ModType2PPCbs==9)) =4;
[N2,X2] = histc(ModType2PPC(:),-0.5:1:10);
[N,X] = histc(ModType2PPCbs(:),-0.5:1:10);
bar(0:10,[N./sum(N) N2./sum(N2)])
hold on;
plot([0 0],[0.1 0.3],'k');



O = {}; Os={};
V2 = [ 0 0 1 3 4 5 7];
for I=[3 4 5 6 7], 
    %myinds = find(CO_(inds)==V(I)&SO_(inds)==V(I));
    myinds = find(ModType2PPC==V2(I));
    O{1,I-2} = 1-OI(inds(myinds)); Os{1,I-2} = 1-OIs(inds(myinds));
    O{2,I-2} = OT(inds(myinds)); Os{2,I-2} = OTs(inds(myinds));
    O{3,I-2} = CV(inds(myinds)); Os{3,I-2} = CVs(inds(myinds));
    O,
end;


for j=1:5, for i=1:3, O{i,j} = O{i,j}(find(~isnan(O{i,j}))); Os{i,j} = Os{i,j}(find(~isnan(Os{i,j}))); end; end;

Of = figure; Osf = figure;
X = [1 2 3 4 5 6 7]; OFF = [0 0 -1];
xc = [ 0 1; 10 90; 0 1];
yc = [ 0 1; 1.5 3; 3.5 4.5];
X_ = [];
Y_ = [];
for k=1:2,
    if k==1, figure(Of); theO=O; else, figure(Osf); theO=Os; end;
    for i=1:3,
        for j=1:5,
            Xh = X(j)+0.2*(rand(size(theO{i,j}))-0.5)
            X_ = [X_ Xh];
            
            Y_ = [Y_; rescale(theO{i,j}',xc(i,:),yc(i,:))];
            plot(Xh,rescale(theO{i,j}',xc(i,:),yc(i,:)),'k.'); hold on; 
            plot(X(j)+[-.2 .2],[0 0]+median(rescale(theO{i,j}',xc(i,:),yc(i,:))),'k--');
        end;
    end;
end;

keyboard;

 
% 			'SL',SL,'OpNo',OpNo,'myinds',g.myinds,'CG',CG,'Vres',Vres,'Vexpl',Vexpl,'Vnoise',Vnoise,...
% 			'colormod',colormod,'SO',SO,'CO',CO,'flag',3,'X_',X_,'Y_',Y_);
% set(gcf,'userdata',ud);

return;
