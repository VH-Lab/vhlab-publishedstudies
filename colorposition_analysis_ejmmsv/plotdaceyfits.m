function plotdaceyfits(g)

if nargin==0,
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]);
    if ud.flag==1,
    	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.OpNo,1),1)'-[ud.SL ud.OpNo]').^2))',0);
    elseif ud.flag==0, 
    	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.SO,1),1)'-[ud.SO ud.CO]').^2))',0);
    elseif ud.flag==3,
        [i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.X,1),1)'-[ud.X ud.Y]').^2))',0);
    end;
	if v<.2,
		if ~isempty(ud.cellnames),
			disp(['Cellname is ' ud.cellnames{ud.myinds(i)} ', index is ' int2str(ud.myinds(i)) '.']);
		end;
		figure;
		a = findassociate(ud.cells{ud.myinds(i)},'TP CEDE Response struct','','');
		str = 'Color Dacey Fit Fig Plot';
		%if isempty(a), str = 'Color Dacey Fit Fig Plot'; else, str = 'Color Dacey Fit Fig Plot'; end;
		plottpresponse(ud.cells{ud.myinds(i)},ud.cellnames{ud.myinds(i)},str,1,1);
	end;
	return;
end;

Op = (g.Sc-g.Lc)'; No = abs(g.Sc+g.Lc)'; %Op(13:16) = 0; No(13:16)=0;
Op = Op./max(Op); No=No./max(No);
Opmn = mean([Op No]')';
Op_ = (Op-Opmn); No_ = (No-Opmn);
Op_ = Op_./(Op_'*Op_); No_ = No_./(No_'*No_);
OpNo = (g.normpcavec-repmat(Opmn',size(g.normpcavec,1),1)) * Op_;

S = abs(g.Sc)'; L = abs(g.Lc)';   S=S./max(S); L=L./max(L);
SLmn = mean([S L]')';
S_ = (S-SLmn); L_ = (L-SLmn);
S_ = S_./(S_'*S_); L_ = L_./(L_'*L_);

SL = (g.normpcavec-repmat(SLmn',size(g.normpcavec,1),1)) * [S_];
R4p = [];
CO = [];
SO = [];

R4SL = [];
R4RSL = [];

for i=1:length(SL),
	[myl,mys] = getdaceysconeinput(g.cellarch{g.myinds(i)},'NK');
	SL(i) = sum(abs(mys))/sum(abs(myl)+abs(mys));
	[myl4,mys4] = getdaceysconeinput(g.cellarch{g.myinds(i)},'R4');
	%[myl4R,mys4R,myR4R] = getdaceysconeinput(g.cellarch{g.myinds(i)},'R4R');
    R4SL(i,:) = sum(abs(mys4))/sum(abs(myl4)+abs(mys4));
    %R4RSL(i,:) = sum(abs(mys4R))/sum(abs(myl4R)+abs(mys4R)+abs(myR4R));
    CO(i) = -(abs(myl4(1))+abs(mys4(1)))*sign(myl4(1))*sign(mys4(1)) -(abs(myl4(2))+abs(mys4(2)))*sign(myl4(2))*sign(mys4(2));
    CO(i) = sign(CO(i)) * abs(sqrt(CO(i)));
    SO(i) = -(abs(myl4(1))+abs(myl4(2)))*sign(myl4(1))*sign(myl4(2)) - (abs(mys4(1))+abs(mys4(2)))*sign(mys4(1))*sign(mys4(2));
    SO(i) = sign(SO(i)) * abs(sqrt(SO(i)));
end;
SL = max((g.normpcavec(:,4)./(g.normpcavec(:,4)+g.normpcavec(:,10))),0);
CO = CO'; SO = SO';

CG1 = []; CG2 = []; CG4 = [];

CG = []; Vres = []; Vexpl = []; Vnoise = []; colormod = [];
for i=1:length(SL),
	%[CG(i),Vres(i),Vexpl(i),Vnoise(i),colormod(i)] = colorgof(g.cellarch{g.myinds(i)});
	[CG(i),colormod(i)] = colorgof2(g.cellarch{g.myinds(i)});
    CG1(i) = colorgofmodel(g.cellarch{g.myinds(i)},1);
    CG2(i) = colorgofmodel(g.cellarch{g.myinds(i)},2);
    CG4(i) = colorgofmodel(g.cellarch{g.myinds(i)},4);
end;

g1 = find(colormod==1&CG>=0.7); g2 = find(colormod==2&CG>=0.7); g3 = find(colormod==3&CG>=0.07); g4 = find(CG<0.7);

g1 = find(colormod==4);
g2 = find(colormod==5);

figure;

h=plot(SL(g1),OpNo(g1),'ko','markerfacecolor',[1 1 1]*0);
hold on;
h=plot(SL(g2),OpNo(g2),'ks','markerfacecolor',[1 1 1]*0);
h=plot(SL(g3),OpNo(g3),'k*','markerfacecolor',[1 1 1]*0);
%h=plot(SL(g4),OpNo(g4),'k^','markerfacecolor',[0 0 0]+0);
xlabel('S/(S+L)'); ylabel('Summing / Opponent index');
axis([0 1 -1.05 1.05]); set(gca,'box','off');
posterize(gcf);
set(gca,'xtick',[0 0.5 1],'ytick',[-1 -0.5 0 0.5 1]);

set(gca,'ButtonDownFcn','plotdaceyfits');


ud = struct('cells',{g.cellarch},'cellnames',{g.cellnamearch},...
			'SL',SL,'OpNo',OpNo,'myinds',g.myinds,'CG',CG,'Vres',Vres,'Vexpl',Vexpl,'Vnoise',Vnoise,...
			'colormod',colormod,'SO',SO,'CO',CO,'flag',1);
set(gcf,'userdata',ud);
        
figure;

plot(SO(g1),CO(g1),'ko','markerfacecolor',[1 1 1]*0);
plot(SO(g2),CO(g2),'ks','markerfacecolor',[1 1 1]*0);

xlabel('Spatial opponency index'); ylabel('Cone opponency index');
posterize(gcf);
set(gca,'ButtonDownFcn','plotdaceyfits');
ud.flag = 2;
set(gcf,'userdata',ud);


figure;
Y = 0:1:100;
X1 = [0 prctile(100*CG1,Y) 100];
X2 = [0 prctile(100*CG2,Y) 100];
X4 = [0 prctile(100*CG4,Y) 100];
plot(X1,[0 Y 100],'-','color',[1 1 1]*0.4); hold on;
plot(X2,[0 Y 100],'-','color',[1 1 1]*0.7); hold on;
plot(X4,[0 Y 100],'k-'); hold on;
xlabel('Response explained (%)');
ylabel('Percent');
legend({'CC (P=2)','CC mod (P=6)','2PCC (P=4)'}); box off;
disp(['CG1 vs. GC2 vs. GC4: ' num2str(kruskal_wallis_test(CG1,CG2,CG4)) '.']);
disp(['CG1 vs. GC2: ' num2str(kruskal_wallis_test(CG1,CG2)) '.']);
disp(['CG1 vs. GC4: ' num2str(kruskal_wallis_test(CG1,CG4)) '.']);
disp(['CG2 vs. GC4: ' num2str(kruskal_wallis_test(CG2,CG4)) '.']);

figure;
Y = 0:1:100;
X1 = [0 prctile(100*R4SL,Y) 100];
X2 = [0 prctile(100*R4RSL,Y) 100];
plot(X1,[0 Y 100],'k-'); hold on;
plot(X2,[0 Y 100],'k--'); hold on;
xlabel('S input (%)');
ylabel('Percent');
legend({'Cones only','Cones + Rods'});
box off; 


figure;
Y = 0:1:100;
X1 = [0 prctile(OpNo,Y) 1];
plot(X1,[0 Y 100],'k-'); hold on;
xlabel('OpNo (%)');
ylabel('Percent');
box off; 
