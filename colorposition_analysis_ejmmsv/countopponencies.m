function [c, s]=countopponencies(cell)

c = []; s = [];
m=sconebestmodel(cell);

R4=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4 Fit','','');
R4R=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color R4R Fit','','');
Lin=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color Fit','','');
NK=findassociate(g.cellarch{g.myinds(i)},'TP CEDE Bootstrap Color NK Fit','','');

VR4 = align2pccfits([ [R4.data.se]' [R4.data.le]' [R4.data.si]' [R4.data.li]']);
VR4R = align2pccfits([[R4R.data.se]' [R4R.data.le]' [R4R.data.re]' [R4R.data.si]' [R4R.data.li]' [R4R.data.ri]']);
VR4L = align2pccfits([ [R4.data.se]' [R4.data.le]' [R4.data.si]' [R4.data.li]'],1);

SNK = [NK.data.s];
if (prctile(SNK,5)>0&prctile(SNK,95)>0) | (prctile(SNK,5)<0&prctile(SNK,95)<0), SigSNK(i) = 1; end;

[L,S]=getdaceysconeinput(cell,m);

tot = sum(L)+sum(S);

if strcmp(m,'NK'),
    if sigInp(tot,S,[NK.data.s])&sigInp(tot,L,[NK.data.l]),
        s=2; c=2*(s<0);
    elseif sigInp(tot,S,[NK.data.s])|sigInp(tot,L,[NK.data.l]),
        s=1;c=0;
    end;
elseif strcmp(m,'linear'),
    if sigInp(tot,S,[Lin.data.s])&sigInp(tot,L,[Lin.data.l]),
        s=2; c=2*(s<0);
    elseif sigInp(tot,S,[Lin.data.s])|sigInp(tot,L,[Lin.data.l]),
        s=1;c=0;
    end    
elseif strcmp(m,'R4'),
    s=0;c=0;
    if sigInp(tot,S(1),VR4L(1,:))
        (abs(S(1)>=th)&(L(1)>=th)&(sign(S(1))~=sign(L(1))), c=c+1; end;
    if (S(2)>=th)&(L(2)>=th)&(sign(S(2))~=sign(L(2))), c=c+1; end;
    if (S(1)>=th)&(S(2)    
        
end;

function b=sigInp(tot, val, dist)

CONF=[5 95];
TH=0.05;

d=prctile(dist,CONF);

b=all(d>0)|all(d<0)&abs(val)>=TH*tot;