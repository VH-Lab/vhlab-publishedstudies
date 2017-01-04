function statsSimMapStrength

load('e:\svanhooser\newferretmtg\mcMapSimCompute_shuffle.mat');

M = []; G = [];
experlist = cat(2,unique({mapnaive.expername}),unique({mapold.expername}));
for k=1:length(experlist),
    myinds = strmatch(experlist{k},{mapnaive.expername},'exact');
    if isempty(myinds),
        myinds = strmatch(experlist{k},{mapold.expername},'exact');
        sitelist = unique({mapold(myinds).stack});
        mapstruct = mapold;
        mapname = 'old';
    else,
        sitelist = unique({mapnaive(myinds).stack});
        mapstruct = mapnaive;
        mapname = 'new';
    end;
    for j=1:length(sitelist),
        myinds2 = strmatch(sitelist{j},{mapstruct(myinds).stack});
        myinds2 = myinds(myinds2);
        for dist=1:5, % number of distances,
            if strcmp(mapname,'new'),
                inds = find(~isnan(ladbbd(myinds2,2,dist))); inds = myinds2(inds);
                M = [M; reshape(100*ladbbd(inds,2,dist),length(inds),1)];
                G = [G; dist*ones(length(inds),1) ones(length(inds),1) k*ones(length(inds),1)];
                
                inds = find(~isnan(ladbad(myinds2,2,dist)));inds = myinds2(inds);
                M = [M; reshape(100*ladbad(inds,2,dist),length(inds),1)];
                G = [G; dist*ones(length(inds),1) 2*ones(length(inds),1) k*ones(length(inds),1)];
                
                inds = find(~isnan(ladbadf(myinds2,2,dist))); inds = myinds2(inds);
                M = [M; reshape(100*ladbadf(inds,2,dist),length(inds),1)];
                G = [G; dist*ones(length(inds),1) 4*ones(length(inds),1) k*ones(length(inds),1)];
            elseif strcmp(mapname,'old'),
                inds = find(~isnan(ldabed(myinds2,2,dist))); inds = myinds2(inds);
                M = [M; reshape(100*ldabed(inds,2,dist),length(inds),1)];
                G = [G; dist*ones(length(inds),1) 3*ones(length(inds),1) k*ones(length(inds),1)];
            end;
        end;
    end;
end;
    
[p,atab] = anovan(M,G,'model',2,'sstype',2,'display','off','varnames',strvcat('Dist', 'Group','Animal'));

atab,

dist = 2;

inds1 = find(~isnan(lbbd(:,2,dist)));
inds2 = find(~isnan(lbad(:,2,dist)));

pkw=kruskal_wallis_test(lbbd(inds1,2,dist),lbad(inds2,2,dist),lbed(:,2,dist)),


dist = 2;

inds1 = find(~isnan(lbbd(:,2,dist)));
inds2 = find(~isnan(lbadf(:,2,dist)));

pkw=kruskal_wallis_test(lbbd(inds1,2,dist),lbadf(inds2,2,dist)),



keyboard;
figure; 
unc = cat(2,unclistb,unclista,unclistf,unclisto);
% mcsim = resigndi(mcsim);
% mcsimt = resigndi(mcsimt);
% mcsimf=resigndi(mcsimf);
% mcsimo=resigndi(mcsimo);
di = cat(2,mean(mcsim(1,:,:),3),mean(mcsimt(1,:,:),3),mean(mcsimf(1,:,:),3),mean(mcsimo(1,:,:),3));
distd = cat(2,std(squeeze(mcsim(1,:,:))'),std(squeeze(mcsimt(1,:,:))'),std(squeeze(mcsimf(1,:,:))'),std(squeeze(mcsimo(1,:,:))'));
ginds = cat(2,1+0*std(squeeze(mcsim(1,:,:))'),2+0*std(squeeze(mcsimt(1,:,:))'),3+0*std(squeeze(mcsimf(1,:,:))'),4+0*std(squeeze(mcsimo(1,:,:))'));

cv = distd./di;
goodinds = find((~isnan(unc)&~isnan(cv)&~isnan(di))&abs(cv)<1000);
[Pcv,Scv]=polyfit(unc(goodinds),cv(goodinds),2);
[Pdi,Sdi]=polyfit(unc(goodinds),di(goodinds),2);
X = 0:0.01:0.5;
subplot(2,2,1); hold off;
plot(unc(goodinds),cv(goodinds),'k.'); hold on;
plot(X,Pcv(1)*(X.^2)+Pcv(2)*X+Pcv(3),'k--');
xlabel('uncertainty'); ylabel('CV');
subplot(2,2,2); hold off;
plot(unc(goodinds),di(goodinds),'k.'); hold on;
plot(X,Pdi(1)*(X.^2)+Pdi(2)*X+Pdi(3),'k--');
xlabel('uncertainty'); ylabel('DI');
subplot(2,2,3); hold off;
plot(di(goodinds),cv(goodinds),'k.'); hold on;
[Pcvdi] = polyfit(di(goodinds),cv(goodinds),1);
G1=find(ginds(goodinds)==1);
G2=find(ginds(goodinds)==2);
G3=find(ginds(goodinds)==3);
G4=find(ginds(goodinds)==4);
plot(di(goodinds(G1)),cv(goodinds(G1)),'g.');
plot(di(goodinds(G2)),cv(goodinds(G2)),'r.'); 
plot(di(goodinds(G3)),cv(goodinds(G3)),'b.'); 
plot(di(goodinds(G4)),cv(goodinds(G4)),'c.'); 
xlabel('DI'); ylabel('CV');

subplot(2,2,4); hold off;
plot(di(goodinds),distd(goodinds),'k.');
xlabel('DI'); ylabel('CV');


[p,atab] = anovan(cv(goodinds)-(di(goodinds)*Pcvdi(1)+Pcvdi(2)),{ginds(goodinds)},'model',2,'sstype',3,'display','off','varnames',{'Group'});
atab,

function newmat = resigndi(mcsim)

for i=1:size(mcsim,2),
    [du,I,J]=dpuncertainty(squeeze(mcsim(2,i,:)));
    mcsim(1,i,J) = -mcsim(1,i,J);
end;

newmat = mcsim;