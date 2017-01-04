function plotconespaceopponency(g)

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

for i=1:length(g.myinds),
    R4=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4 Fit','','');
    R4R=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4R Fit','','');
    Lin=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color Fit','','');
    NK=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color NK Fit','','');
    
    CO2(i) = 0; SO2(i) = 0; CO1(i) = 0; SO1(i) = 0; CO0(i) = 0; SO0(i) = 0;
    CO2SO2(i)=0;    CO1SO1(i)=0;    CO2SO0(i)=0;    CO0SO2(i)=0;
    SigS(i) = 0; SigSR(i) = 0; SigSLin(i) = 0; SigSNK(i) = 0;

    PSNK(i) = mean(abs([NK.data.s])./(abs([NK.data.s])+abs([NK.data.l])));
    PSLin(i) = mean(abs([Lin.data.s])./(abs([Lin.data.s])+abs([Lin.data.l])));
    PS(i) = mean((abs([R4.data.se])+abs([R4.data.si]))./((abs([R4.data.se])+abs([R4.data.si]))+(abs([R4.data.le])+abs([R4.data.li]))));
    PSR(i) = mean((abs([R4R.data.se])+abs([R4R.data.si]))./(0*abs([R4R.data.re])+0*abs([R4R.data.ri])+abs([R4R.data.se])+abs([R4R.data.si])+abs([R4R.data.le])+abs([R4R.data.li])));

    SNK = [NK.data.s];
    if (prctile(SNK,5)>0&prctile(SNK,95)>0) | (prctile(SNK,5)<0&prctile(SNK,95)<0), SigSNK(i) = 1; end;
    Se_ = []; Si_ = []; SeR_ = []; SiR_ = [];
    for j=1:length(R4.data),
        CO2(i) = CO2(i) + double(sign(R4.data(j).le)~=sign(R4.data(j).se)&&(sign(R4.data(j).li)~=sign(R4.data(j).si)));
        SO2(i) = SO2(i) + double(sign(R4.data(j).le)~=sign(R4.data(j).li)&&(sign(R4.data(j).si)~=sign(R4.data(j).se)));
        CO1(i) = CO1(i)+xor((sign(R4.data(j).le)~=sign(R4.data(j).se)),(sign(R4.data(j).li)~=sign(R4.data(j).si)));
        SO1(i) = SO1(i)+xor((sign(R4.data(j).le)~=sign(R4.data(j).li)),(sign(R4.data(j).si)~=sign(R4.data(j).se)));
        CO2SO2(i) = CO2SO2(i)+double(sign(R4.data(j).le)~=sign(R4.data(j).se)&&(sign(R4.data(j).li)~=sign(R4.data(j).si)))*double(sign(R4.data(j).le)~=sign(R4.data(j).li)&&(sign(R4.data(j).si)~=sign(R4.data(j).se)));
        CO1SO1(i) = CO1SO1(i)+xor((sign(R4.data(j).le)~=sign(R4.data(j).se)),(sign(R4.data(j).li)~=sign(R4.data(j).si)))*xor((sign(R4.data(j).le)~=sign(R4.data(j).li)),(sign(R4.data(j).si)~=sign(R4.data(j).se)));
        CO2SO0(i) = CO2SO0(i)+xor((sign(R4.data(j).le)==sign(R4.data(j).li)),(sign(R4.data(j).si)==sign(R4.data(j).se)))*double(sign(R4.data(j).le)~=sign(R4.data(j).se)&&(sign(R4.data(j).li)~=sign(R4.data(j).si)));
        CO0SO2(i) = CO0SO2(i)+double(sign(R4.data(j).le)~=sign(R4.data(j).li)&&(sign(R4.data(j).si)~=sign(R4.data(j).se)))*double(sign(R4.data(j).le)==sign(R4.data(j).se)&&(sign(R4.data(j).li)==sign(R4.data(j).si)));
        if R4.data(j).le>R4.data(j).li, Se_(end+1) = R4.data(j).se; Si_(end+1)=R4.data(j).si; else, Se_(end+1) = R4.data(j).si; Si_(end+1)=R4.data(j).se; end;
        if R4R.data(j).se+0*R4R.data(j).re>R4R.data(j).si+0*R4R.data(j).ri, SeR_(end+1) = R4R.data(j).se; SiR_(end+1)=R4R.data(j).si; else, SeR_(end+1) = R4R.data(j).si; SiR_(end+1)=R4R.data(j).se; end;
    end;
    SigS(i) = (prctile(Se_,5)>0&prctile(Se_,95)>0) | (prctile(Se_,5)<0&prctile(Se_,95)<0) | (prctile(Si_,5)>0&prctile(Si_,95)>0) | (prctile(Si_,5)<0&prctile(Si_,95)<0);
    SigSR(i) = (prctile(SeR_,5)>0&prctile(SeR_,95)>0) | (prctile(SeR_,5)<0&prctile(SeR_,95)<0) | (prctile(SiR_,5)>0&prctile(SiR_,95)>0) | (prctile(SiR_,5)<0&prctile(SiR_,95)<0);
    CO2(i) = 100*CO2(i) / length(R4.data);
    SO2(i) = 100*SO2(i) / length(R4.data);
    CO1(i) = 100*CO1(i) / length(R4.data);
    SO1(i) = 100*SO1(i) / length(R4.data);
    CO2SO2(i) = 100*CO2SO2(i) / length(R4.data);
    CO1SO1(i) = 100*CO1SO1(i) / length(R4.data);
    CO2SO0(i) = 100*CO2SO0(i) / length(R4.data);
    CO0SO2(i) = CO0SO2(i)*100/length(R4.data);
end;
SO0 = 100 - SO2 - SO1;
CO0 = 100 - CO2 - CO1;

figure;
subplot(2,2,1);
plot(CO1,CO2,'ko'); box off;


subplot(2,2,2);
plot(SO1,SO2,'ko'); box off;

subplot(2,2,3);
plot(SO2,CO2,'ko'); box off;

subplot(2,2,4);
plot(SO1,CO1,'ko'); box off;

figure;
Y = 0:0.01:100;
XCO2 = [0 prctile(CO2,Y) 100];
XCO1 = [0 prctile(CO1,Y) 100];
XSO2 = [0 prctile(SO2,Y) 100];
XSO1 = [0 prctile(SO1,Y) 100];
XSO0 = [0 prctile(SO0,Y) 100];
XCO0 = [0 prctile(CO0,Y) 100];
XCO2SO2 = [ 0 prctile(CO2SO2,Y) 100];
XCO1SO1 = [ 0 prctile(CO1SO1,Y) 100];
XCO2SO0 = [ 0 prctile(CO2SO0,Y) 100];
XCO0SO2 = [ 0 prctile(CO0SO2,Y) 100];

XS = [0  100*prctile(PS,Y) 100];
XSR = [0 100*prctile(PSR,Y) 100];
XSNK = [0 100*prctile(PSNK,Y) 100];

subplot(2,2,1);
plot(XCO2,[0 Y 100],'k-'); hold on;
plot(XCO1,[0 Y 100],'-','color',[0.8 0.8 0.8]*0.5);
plot(XCO0,[0 Y 100],'-','color',[0.8 0.8 0.8]);
plot([0 100],[50 50],'k--'); box off;

subplot(2,2,2);
plot(XSO2,[0 Y 100],'k-'); hold on;
plot(XSO1,[0 Y 100],'-','color',[0.8 0.8 0.8]);
plot(XSO0,[0 Y 100],'-','color',[0.8 0.8 0.8]);
plot([0 100],[50 50],'k--'); box off;

subplot(2,2,3);
plot(XCO2SO2,[0 Y 100],'k-'); hold on;
plot(XCO1SO1,[0 Y 100],'m-'); hold on;
%plot(XCO2SO0,[0 Y 100],'g-'); hold on;
plot(XCO0SO2,[0 Y 100],'b-'); hold on;
box off;

subplot(2,2,4);
plot(XS,[0 Y 100],'k-'); hold on;
plot(XSR,[0 Y 100],'m'); 
plot(XSNK,[0 Y 100],'b');
box off;

disp(['SigS: ' int2str(sum(SigS)) '.']);
disp(['SigSR: ' int2str(sum(SigSR)) '.']);
disp(['SigSNK: ' int2str(sum(SigSNK)) '.']);


keyboard;
