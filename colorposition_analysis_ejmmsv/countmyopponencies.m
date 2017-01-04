function [COG,CAG,SOG,WM] = countmyopponencies(cell)

R4=findassociate(cell,'TP CEDE Bootstrap Color R4 Fit','','');
R4R=findassociate(cell,'TP CEDE Bootstrap Color R4R Fit','','');
Lin=findassociate(cell,'TP CEDE Bootstrap Color Fit','','');
NK=findassociate(cell,'TP CEDE Bootstrap Color NK Fit','','');
RSP=findassociate(cell,'TP CEDE Response struct','','');
OV = findassociate(cell,'TP Ach OT visual response p','','');
OVs = findassociate(cell,'TP S OT visual response p','','');
myOI = findassociate(cell,'TP Ach OT Fit Orientation index blr','','');
myCV = findassociate(cell,'TP Ach OT Circular variance','','');
myOT = findassociate(cell,'TP Ach OT Tuning width','','');
myOIs = findassociate(cell,'TP S OT Fit Orientation index blr','','');
myCVs = findassociate(cell,'TP S OT Circular variance','','');
myOTs = findassociate(cell,'TP S OT Tuning width','',''); 
i=1;

[p_nlvsln, p_lnvsmn, p_rctvsln, p_nlvsrct, p_r4vsln, p_r4vsnl, linvsr4, nlvsr4, whichmodel]=isnonlinearcolor(cell);

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
    end;



    PSNK(i) = mean(PSNKl);
    PSLin(i) = mean(abs([Lin.data.s])./(abs([Lin.data.s])+abs([Lin.data.l])));
    PS(i) = mean((abs([R4.data.se])+abs([R4.data.si]))./((abs([R4.data.se])+abs([R4.data.si]))+(abs([R4.data.le])+abs([R4.data.li]))));
    PSR(i) = mean((abs([R4R.data.se])+abs([R4R.data.si]))./(0*abs([R4R.data.re])+0*abs([R4R.data.ri])+abs([R4R.data.se])+abs([R4R.data.si])+abs([R4R.data.le])+abs([R4R.data.li])));
    SLr(i) = max(RSP.data.curve(2,4),0)./(max(RSP.data.curve(2,4),0)+max(RSP.data.curve(2,10),0));

    SNK = [NK.data.s];
    if (prctile(SNK,5)>0&prctile(SNK,95)>0) | (prctile(SNK,5)<0&prctile(SNK,95)<0), SigSNK(i) = 1; end;
    if SigSNK(i)&PSNK(i)>.1, SigSNK2(i) = 1; end;
    
    GOF1(i) = colorgofmodel(cell,1);
    GOF2(i) = colorgofmodel(cell,2);
    GOF4(i) = colorgofmodel(cell,4);
    
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

[myl,mys] = getdaceysconeinput(cell,'linear');
SLLIN(i) = abs(mys)/(abs(myl)+abs(mys));
[myl,mys] = getdaceysconeinput(cell,'nk');
SLNK(i) = abs(mys)/(abs(myl)+abs(mys)); 
[myl,mys] = getdaceysconeinput(cell,'R4');
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
        COG(i) = CO_4(i); SOG(i) = SO_4(i);
        COGs(i) = SOs53_(i); COGl(i) = SOl53_(i); COGe(i) = COe53_(i); COGi(i) = COi53_(i);
        CAG(i) = CA_4(i);
        SLB(i) = SLR4(i);
    otherwise, disp(['error']);
end;
WM(i) = whichmodel;
SigS(i) = (prctile(Se_,5)>0&prctile(Se_,95)>0) | (prctile(Se_,5)<0&prctile(Se_,95)<0) | (prctile(Si_,5)>0&prctile(Si_,95)>0) | (prctile(Si_,5)<0&prctile(Si_,95)<0);
SigSR(i) = (prctile(SeR_,5)>0&prctile(SeR_,95)>0) | (prctile(SeR_,5)<0&prctile(SeR_,95)<0) | (prctile(SiR_,5)>0&prctile(SiR_,95)>0) | (prctile(SiR_,5)<0&prctile(SiR_,95)<0);
if SigSR(i)&PSR(i)>.1, SigSR2(i) = 1; end;
if SigS(i)&PS(i)>.1, SigS2(i) = 1; end;
    SLINS = [Lin.data.s];
if (prctile(SLINS,5)>0&prctile(SLINS,95)>0) | (prctile(SLINS,5)<0&prctile(SLINS,95)<0), SigSLin(i) = 1; end;
if SigSLin(i)&SLLIN(i)>.1, SigSLin2(i) = 1; end;    

