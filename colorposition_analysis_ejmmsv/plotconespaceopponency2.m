function plotconespaceopponency(g)

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

OT = []; OTs = [];
OI = []; OIs = [];
CV = []; CVs = [];

SLr = [];

for i=1:length(g.myinds),
    R4=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4 Fit','','');
    R4R=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4R Fit','','');
    Lin=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color Fit','','');
    NK=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color NK Fit','','');
    RSP=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Response struct','','');
    OV = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT visual response p','','');
    OVs = findassociate(g.cellarch{g.myinds(i)},'TP S OT visual response p','','');
    myOI = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT Fit Orientation index blr','','');
    myCV = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT Circular variance','','');
    myOT = findassociate(g.cellarch{g.myinds(i)},'TP Ach OT Tuning width','','');
    myOIs = findassociate(g.cellarch{g.myinds(i)},'TP S OT Fit Orientation index blr','','');
    myCVs = findassociate(g.cellarch{g.myinds(i)},'TP S OT Circular variance','','');
    myOTs = findassociate(g.cellarch{g.myinds(i)},'TP S OT Tuning width','',''); 
    
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

    PSNK(i) = mean(abs([NK.data.s])./(abs([NK.data.s])+abs([NK.data.l])));
    PSLin(i) = mean(abs([Lin.data.s])./(abs([Lin.data.s])+abs([Lin.data.l])));
    PS(i) = mean((abs([R4.data.se])+abs([R4.data.si]))./((abs([R4.data.se])+abs([R4.data.si]))+(abs([R4.data.le])+abs([R4.data.li]))));
    PSR(i) = mean((abs([R4R.data.se])+abs([R4R.data.si]))./(0*abs([R4R.data.re])+0*abs([R4R.data.ri])+abs([R4R.data.se])+abs([R4R.data.si])+abs([R4R.data.le])+abs([R4R.data.li])));
    SLr(i) = max(RSP.data.curve(2,4),0)./(max(RSP.data.curve(2,4),0)+max(RSP.data.curve(2,10),0));
    
    SNK = [NK.data.s];
    if (prctile(SNK,5)>0&prctile(SNK,95)>0) | (prctile(SNK,5)<0&prctile(SNK,95)<0), SigSNK(i) = 1; end;
    VR4 = align2pccfits([ [R4.data.se]' [R4.data.le]' [R4.data.si]' [R4.data.li]']);
    VR4R = align2pccfits([[R4R.data.se]' [R4R.data.le]' [R4R.data.re]' [R4R.data.si]' [R4R.data.li]' [R4R.data.ri]']);
    VR4L = align2pccfits([ [R4.data.se]' [R4.data.le]' [R4.data.si]' [R4.data.li]'],1);
    Se_ = VR4(:,1); Si_ = VR4(:,3);
    SeR_ = VR4R(:,1); SiR_ = VR4R(:,4);
    Pse = prctile(VR4(:,1),[20 80]); Psed0 = all(Pse>0)|all(Pse<0);
    Psi = prctile(VR4(:,3),[20 80]); Psid0 = all(Psi>0)|all(Psi<0);
    Ple = prctile(VR4(:,2),[20 80]); Pled0 = all(Ple>0)|all(Ple<0);
    Pli = prctile(VR4(:,4),[20 80]); Plid0 = all(Pli>0)|all(Pli<0);
    Pse2 = prctile(VR4L(:,1),[5 95]); Psed02 = all(Pse2>0)|all(Pse2<0);
    Psi2 = prctile(VR4L(:,3),[5 95]); Psid02 = all(Psi2>0)|all(Psi2<0);
    Ple2 = prctile(VR4L(:,2),[20 80]); Pled02 = all(Ple2>0)|all(Ple2<0);
    Pli2 = prctile(VR4L(:,4),[20 80]); Plid02 = all(Pli2>0)|all(Pli2<0);
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
    SOs5_(i) = xor(Psed0,Psid0);
    SOl5_(i) = xor(Pled0,Plid0);
    COe5_(i) = -Psed0+Pled0;
    COi5_(i) = -Psid0+Plid0;
    SigS(i) = (prctile(Se_,5)>0&prctile(Se_,95)>0) | (prctile(Se_,5)<0&prctile(Se_,95)<0) | (prctile(Si_,5)>0&prctile(Si_,95)>0) | (prctile(Si_,5)<0&prctile(Si_,95)<0);
    SigSR(i) = (prctile(SeR_,5)>0&prctile(SeR_,95)>0) | (prctile(SeR_,5)<0&prctile(SeR_,95)<0) | (prctile(SiR_,5)>0&prctile(SiR_,95)>0) | (prctile(SiR_,5)<0&prctile(SiR_,95)<0);
end;
    inds = find(SigS);
if 0,
    figure;
    subplot(2,1,1);

    eb=myerrorbar([1 2 3],[mean(CO2(inds,j)) mean(CO1(inds,j)) mean(CO0(inds,j))],[stderr(CO2(inds,j)) stderr(CO1(inds,j)) stderr(CO0(inds,j))],'k-');
    delete(eb(2));
    hold on;
    b=bar([1 2 3],[mean(CO2(inds,j)) mean(CO1(inds,j)) mean(CO0(inds,j))]);
    set(b,'facecolor',[0 0 0]); box off;
    set(gca,'xticklabel',{'CO2','CO1','CO0'});

    eb=myerrorbar([4 5 6],[mean(SO2(inds,j)) mean(SO1(inds,j)) mean(SO0(inds,j))],[stderr(SO2(inds,j)) stderr(SO1(inds,j)) stderr(SO0(inds,j))],'k-');
    delete(eb(2));
    hold on;
    b=bar([4 5 6],[mean(SO2(inds,j)) mean(SO1(inds,j)) mean(SO0(inds,j))]);
    set(b,'facecolor',[0 0 0]); box off;
    set(gca,'xtick',[1:6],'xticklabel',{'CO2','CO1','CO0','SO2','SO1','SO0','CO2S02','CO1S01','CO0S02'});

    eb=myerrorbar([7 8 9],[mean(CO2(inds,j).*SO2(inds,j)) mean(CO1(inds,j).*SO1(inds,j)) mean(CO0(inds,j).*SO2(inds,j))],[stderr(CO2(inds,j).*SO2(inds,j)) stderr(CO1(inds,j).*SO1(inds,j)) stderr(CO0(inds,j).*SO2(inds,j))],'k-');
    delete(eb(2));
    hold on;
    b=bar([7 8 9],[mean(CO2(inds,j).*SO2(inds,j)) mean(CO1(inds,j).*SO1(inds,j)) mean(CO0(inds,j).*SO2(inds,j))]);
    set(b,'facecolor',[0 0 0]); box off;
    set(gca,'xtick',[1:9],'xticklabel',{'CO2','CO1','CO0','SO2','SO1','SO0','CO2S02','CO1S01','CO0S02'});
end;




disp(['SigS: ' int2str(sum(SigS)) '.']);
disp(['SigSR: ' int2str(sum(SigSR)) '.']);
disp(['SigSNK: ' int2str(sum(SigSNK)) '.']);


MAT = zeros(5);

V = [0 0.5*sqrt(-1) 1*sqrt(-1) 1 1+0.5*sqrt(-1) 2];

for I=1:length(V),
    for J=1:length(V),
        MAT(I,J) = length(find(CO_(inds)==V(I)&SO_(inds)==V(J)));
    end;
end;
100*MAT/length(inds),

(sum(COe5_(inds)<0)+sum(COi5_(inds)<0))/sum(2*imag(CO_(inds)));
(sum(COe5_(inds)>0)+sum(COi5_(inds)>0))/sum(2*imag(CO_(inds)));
sum(SOs5_(inds))/sum(2*imag(SO_(inds)));
sum(SOl5_(inds))/sum(2*imag(SO_(inds)));

figure;
plot(SLr,PS,'k.')
xlabel('Response S/S+L'); ylabel('Putative input S/S+L');
axis([0 1 0 1]); axis square; box off; set(gca,'xtick',[0 0.2 0.4 0.6 0.8 1],'ytick',[0 0.2 0.4 0.6 0.8 1.0]);
[slope,offset,slope_conf] = quickregression(SLr',PS',0.05); slope_conf,
hold on;
plot([0 1],slope*[0 1]+offset);

V = [0 0.5*sqrt(-1) 1*sqrt(-1) 1 1+0.5*sqrt(-1) 2];
O = {}; Os={};
for I=[3:6], 
    myinds = find(CO_(inds)==V(I)&SO_(inds)==V(I));
    O{1,I-2} = OI(inds(myinds)); Os{1,I-2} = OIs(inds(myinds));
    O{2,I-2} = OT(inds(myinds)); Os{2,I-2} = OTs(inds(myinds));
    O{3,I-2} = CV(inds(myinds)); Os{3,I-2} = CVs(inds(myinds));
end;

myinds2=setdiff(1:length(CO_),inds);
myinds3 = find(SO_2(myinds2)==1|SO_2(myinds2)==0);
myinds4 = find(imag(SO_2(myinds2))>0);
O{1,5} = OI(myinds2); Os{1,5} = OIs(myinds2);
O{2,5} = OT(myinds2); Os{2,5} = OTs(myinds2);
O{3,5} = CV(myinds2); Os{3,5} = CVs(myinds2);
O{1,6} = OI(myinds2(myinds3)); Os{1,6} = OIs(myinds2(myinds3));
O{2,6} = OT(myinds2(myinds3)); Os{2,6} = OTs(myinds2(myinds3));
O{3,6} = CV(myinds2(myinds3)); Os{3,6} = CVs(myinds2(myinds3));
O{1,7} = OI(myinds2(myinds3)); Os{1,6} = OIs(myinds2(myinds3));
O{2,7} = OT(myinds2(myinds3)); Os{2,7} = OTs(myinds2(myinds4));
O{3,7} = CV(myinds2(myinds3)); Os{3,7} = CVs(myinds2(myinds4));



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
        end;
    end;
end;

% set(gca,'ButtonDownFcn','plotdaceyfits');

% ud = struct('cells',{g.cellarch},'cellnames',{g.cellnamearch},...
% 			'SL',SL,'OpNo',OpNo,'myinds',g.myinds,'CG',CG,'Vres',Vres,'Vexpl',Vexpl,'Vnoise',Vnoise,...
% 			'colormod',colormod,'SO',SO,'CO',CO,'flag',3,'X_',X_,'Y_',Y_);
% set(gcf,'userdata',ud);

keyboard;

return;
