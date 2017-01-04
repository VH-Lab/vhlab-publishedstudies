function plotSimMapStrength

load('e:\svanhooser\newferretmtg\mcMapSimCompute.mat');

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbbd(:,2,2), fp, -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbbd(:,2,2), fp, -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbbd(:,2,2),fp,'k.')
%[slope,offset,slope_confinterval,resid,residint,stats] = quickregression(lbbd(:,2,3),fp',0.05);
%h=myerrorbar(Xn,Yn,Yerr,'k'); set(h,'color',[0.5 0.5 0.5])
axis ([ -.6 0.6 0 1]);
ylabel('Prob of Dir Flip'); xlabel('Local bias before training');

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbbd(:,2,2), dib(:,2), -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbbd(:,2,2), dib(:,2), -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbbd(:,2,2),dib(:,2),'k.')
ylabel('DI Naive'); xlabel('Local bias naive');
axis([-1 1 0 1]);

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbad(:,2,2), dia(:,2), -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbad(:,2,2), dia(:,2), -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbad(:,2,2),dia(:,2),'k.')
ylabel('DI After'); xlabel('Local bias after');
axis([-1 1 0 1]);

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbed(:,2,2), die(:,2), -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbed(:,2,2), die(:,2), -1, 0.01, 1, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbed(:,2,2),die(:,2),'k.')
ylabel('DI Experienced'); xlabel('Local bias experienced');
axis([-1 1 0 1]);

 % similar/dissimilar v 2

 keyboard;

mnsbs = zeros(1,5);stebs = zeros(1,5);
mnsas = zeros(1,5);steas = zeros(1,5);
mnsos = zeros(1,5);steos = zeros(1,5);

mnsbo = zeros(1,5);stebo = zeros(1,5);
mnsao = zeros(1,5);steao = zeros(1,5);
mnsoo = zeros(1,5);steoo = zeros(1,5);

mnsboris = zeros(1,5); steboris = zeros(1,5);
mnsborio = zeros(1,5); steborio = zeros(1,5);

for i=1:5,
    [mnsbo(i),stebo(i)] = getmnstde(lobd(:,2,i),mapnaive);
    [mnsao(i),steao(i)] = getmnstde(load_(:,2,i),mapnaive);
    [mnsoo(i),steoo(i)] = getmnstde(loed(:,2,i),mapold);
    
    [mnsbs(i),stebs(i)] = getmnstde(lsbd(:,2,i),mapnaive);
    [mnsas(i),steas(i)] = getmnstde(lsad(:,2,i),mapnaive);
    [mnsos(i),steos(i)] = getmnstde(lsed(:,2,i),mapold);

    [mnsboris(i),steboris(i)] = getmnstde(lsoribd(:,2,i),mapnaive);
    [mnsborio(i),steborio(i)] = getmnstde(looribd(:,2,i),mapnaive);

end;


if 0,
    figure;
    h1=myerrorbar([50 100 150 200 250],100*mnsos,100*steos,'-'); hold on;
    set(h1,'color',[1 1 1]*0,'linewidth',1);
    h2=myerrorbar([50 100 150 200 250],100*mnsas,100*steas,'-');
    set(h2,'color',[1 1 1]*0.4,'linewidth',1);
    h3=myerrorbar([50 100 150 200 250],100*mnsbs,100*stebs,'-');
    set(h3,'color',[1 1 1]*0.7,'linewidth',1);
        
    h4=myerrorbar([50 100 150 200 250],-100*mnsoo,100*steoo,'-');
    set(h4,'color',[1 1 1]*0,'linewidth',1);
    h5=myerrorbar([50 100 150 200 250],-100*mnsao,100*steao,'-');
    set(h5,'color',[1 1 1]*0.4,'linewidth',1);
    h6=myerrorbar([50 100 150 200 250],-100*mnsbo,100*stebo,'-');
    set(h6,'color',[1 1 1]*0.7,'linewidth',1);

    
    %t=text(225,60,'33-66%: ','horizontalalignment','right');
    plot([50 100 150 200 250],100*mnsboris/2,'k--');
    plot([50 100 150 200 250],-100*mnsborio/2,'k--');
    
    l=legend('Experienced','Motion training','Naive');
    set(l,'box','off','position',[0.2 0.35 0.25 0.144]);
    box off;
    ch = get(gca,'children'); set(gca,'children',[ch(3:end); ch(1); ch(2)]);
    xlabel('Cell distance (\mum)');
    ylabel('Percent similar/dissimilar');
    axis([0 250 -50 80]);
end;


  % local bias index
figure;

mnsbs = zeros(1,5);stebs = zeros(1,5);
mnsas = zeros(1,5);steas = zeros(1,5);
mnsos = zeros(1,5);steos = zeros(1,5);
pvalsb = zeros(1,5);
pvalsa = zeros(1,5);
pvalso = zeros(1,5);

for i=1:5,
    [mnsbs(i),stebs(i),pvalsb(i),mydat] = getmnstde(ladbbd(:,2,i),mapnaive);
    [mnsas(i),steas(i),pvalsa(i)] = getmnstde(ladbad(:,2,i),mapnaive);
    [mnsos(i),steos(i),pvalso(i)] = getmnstde(ldabed(:,2,i),mapold);
end;


h=plot([50 100 150 200 250],100*mnsos,'-s','color',[1 1 1]*0.0,'linewidth',2);
hold on;
h=plot([50 100 150 200 250],100*mnsas,'-d','color',[1 1 1]*0.4,'linewidth',2);
h=plot([50 100 150 200 250],100*mnsbs,'-o','color',[1 1 1]*0.7,'linewidth',2);

h=plot(230*[1 1],15+1*100*mean(steos(1))*[-1 1],'-','color',[1 1 1]*0.0,'linewidth',2);
h=plot(235*[1 1],15+1*100*mean(steas(1))*[-1 1],'-','color',[1 1 1]*0.4,'linewidth',2);
h=plot(240*[1 1],15+1*100*mean(stebs(1))*[-1 1],'-','color',[1 1 1]*0.7,'linewidth',2);
t=text(225,15,'SEM (%): ','horizontalalignment','right');
plot([0 300],[0 0],'k--');

l=legend('Experienced','Motion training','Naive');
set(l,'box','off','position',[0.6116    0.7283    0.2554    0.1444]);
box off;
ch = get(gca,'children'); set(gca,'children',[ch(3:end); ch(1); ch(2)]);
xlabel('Cell distance (\mum)');
ylabel('Local bias index');
axis([25 275 -10 35]);

function [mymn,mystde,myp,mydat] = getmnstde(thevar,mapstruct)
mydat = [];

experlist = unique({mapstruct.expername});
for i=1:length(experlist),
    myinds = strmatch(experlist{i},{mapstruct.expername},'exact');
    sitelist = unique({mapstruct(myinds).stack});
    for j=1:length(sitelist),
        myinds2 = strmatch(sitelist{j},{mapstruct(myinds).stack});
        myinds2 = myinds(myinds2);
        mydat(end+1) = nanmean(thevar(myinds2));
    end;
end;

mymn = mean(mydat);
mystde = stderr(mydat');
[h,myp] = ttest(mydat,0,0.05,'right');
%myp = signtest(mydat);
