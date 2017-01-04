function plotdaceypca(g)

if nargin==0,
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]);
	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.OpNo,1),1)'-[ud.SL ud.OpNo]').^2))',0);
	if v<.2,
		if ~isempty(ud.cellnames),
			disp(['Cellname is ' ud.cellnames{ud.myinds(i)} ', index is ' int2str(ud.myinds(i)) '.']);
		end;
		figure;
		a = findassociate(ud.cells{ud.myinds(i)},'TP CEDE Response struct','','');
		str = 'Color Dacey Fig Plot';
%        subplot(2,2,1);
		plottpresponse(ud.cells{ud.myinds(i)},ud.cellnames{ud.myinds(i)},'Color Dacey Fit Fig Plot',1,1,'modelnum',4);
        figure;
        plottpresponse(ud.cells{ud.myinds(i)},ud.cellnames{ud.myinds(i)},'Orientation/Direction',1,1);
%         subplot(2,2,2);
%         plottpresponse(ud.cells{ud.myinds(i)},ud.cellnames{ud.myinds(i)},'Color Dacey Fit Fig Plot',1,1,'modelnum',1);
%         subplot(2,2,3);
%         plottpresponse(ud.cells{ud.myinds(i)},ud.cellnames{ud.myinds(i)},'Color Dacey Fit Fig Plot',1,1,'modelnum',2);
%         subplot(2,2,4);
%         plottpresponse(ud.cells{ud.myinds(i)},ud.cellnames{ud.myinds(i)},'Color Dacey Fit Fig Plot',1,1,'modelnum',4);        
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

SL2 = (g.normpcavec-repmat(SLmn',size(g.normpcavec,1),1)) * [S_];

SL = zeros(167,1);

for i=1:length(SL),
	[myl,mys] = getdaceysconeinput(g.cellarch{g.myinds(i)},'linear');
	SL(i) = abs(mys)/(abs(myl)+abs(mys));
	%OpNo(i) = (abs(myl-mys)-abs(myl+mys))./(abs(myl)+abs(mys));
end;

if 0,
	for i=1:length(OpNo),
		OpNo(i) = getdaceyopponindex(g.cellarch{g.myinds(i)},'nk');
	end;
end;

R = sum(g.normpcavec')';
R2 = sum(g.pcavec')';

P2 = prctile(R2,[0.1 0.8]*100);
g1 = find(R2<P2(1)); g2 = find(R2>=P2(1)&R2<=P2(2)); g3 = find(R2>=P2(2));

figure;

h=plot(SL(g1),OpNo(g1),'ko','markerfacecolor',[1 1 1]*0);
hold on;
h=plot(SL(g2),OpNo(g2),'ko','markerfacecolor',[1 1 1]*0);
h=plot(SL(g3),OpNo(g3),'ko','markerfacecolor',[0 0 0]+0);
xlabel('S/(S+L)'); ylabel('Summing / Opponent index');
axis([0 1 -1.05 1.05]); set(gca,'box','off');
posterize(1);
set(gca,'xtick',[0 0.5 1],'ytick',[-1 -0.5 0 0.5 1]);

set(gca,'ButtonDownFcn','plotdaceypca');
set(gcf,'userdata',...
	struct('cells',{g.cellarch},'cellnames',{g.cellnamearch},...
			'SL',SL,'OpNo',OpNo,'myinds',g.myinds));

figure;

h=plot(SL2(g1),OpNo(g1),'ko','markerfacecolor',[1 1 1]*0);
hold on;
h=plot(SL2(g2),OpNo(g2),'ko','markerfacecolor',[1 1 1]*0);
h=plot(SL2(g3),OpNo(g3),'ko','markerfacecolor',[0 0 0]+0);
xlabel('S/(S+L)'); ylabel('Summing / Opponent index');
axis([0 1 -1.05 1.05]); set(gca,'box','off');
posterize(1);
set(gca,'xtick',[0 0.5 1],'ytick',[-1 -0.5 0 0.5 1]);

set(gca,'ButtonDownFcn','plotdaceypca');
set(gcf,'userdata',...
	struct('cells',{g.cellarch},'cellnames',{g.cellnamearch},...
			'SL',SL2,'OpNo',OpNo,'myinds',g.myinds));        
        
return;

