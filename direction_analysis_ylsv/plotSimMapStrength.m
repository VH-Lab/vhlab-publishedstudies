function plotSimMapStrength

load('e:\svanhooser\newferretmtg\mcMapSimCompute.mat');

figure;

[Yn,Xn,Yerr] = slidingwindowfunc(lbbd(:,2,2), fp, -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbbd(:,2,2),fp,'k.')
%[slope,offset,slope_confinterval,resid,residint,stats] = quickregression(lbbd(:,2,3),fp',0.05);
%h=myerrorbar(Xn,Yn,Yerr,'k'); set(h,'color',[0.5 0.5 0.5])
axis ([ -.6 0.6 0 1]);
ylabel('Prob of Dir Flip'); xlabel('Local bias before training');

% figure;
% 
% [Yn,Xn,Yerr] = slidingwindowfunc(ldsbbd(:,2,2), fp, -.1, 0.01, .1, 0.05, 'nanmedian',0,'diff(prctile(y,[33 66]))');
% p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
% set(p,'edgecolor',[1 1 1]*0.8);
% 
% hold on;
% plot(ldsbbd(:,2,2),fp,'k.')
% %[slope,offset,slope_confinterval,resid,residint,stats] = quickregression(lbbd(:,2,3),fp',0.05);
% %h=myerrorbar(Xn,Yn,Yerr,'k'); set(h,'color',[0.5 0.5 0.5])
% axis ([ -1 1 0 1]);
% ylabel('Prob of Dir Flip'); xlabel('Local strength bias before training');
% 

figure;

[Yn,Xn,Yerr] = slidingwindowfunc(lbbd(:,2,2), dib(:,2), -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbbd(:,2,2),dib(:,2),'k.')
ylabel('DI Naive'); xlabel('Local bias naive');
axis([-1 1 0 1]);

figure;

[Yn,Xn,Yerr] = slidingwindowfunc(lbad(:,2,2), dia(:,2), -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbad(:,2,2),dia(:,2),'k.')
ylabel('DI After'); xlabel('Local bias after');
axis([-1 1 0 1]);

figure;

[Yn,Xn,Yerr] = slidingwindowfunc(lbed(:,2,2), die(:,2), -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbed(:,2,2),die(:,2),'k.')
ylabel('DI Experienced'); xlabel('Local bias experienced');
axis([-1 1 0 1]);


figure;

[Yn,Xn,Yerr] = slidingwindowfunc(ldsbbd(:,2,2), dib(:,2), -1, 0.02, 1, 0.1, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(ldsbbd(:,2,2),dib(:,2),'k.')
ylabel('DI Naive'); xlabel('Local bias strength naive');
axis([-1 1 0 1]);

figure;

[Yn,Xn,Yerr] = slidingwindowfunc(ldsbad(:,2,2), dia(:,2), -1, 0.02, 1, 0.1, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(ldsbad(:,2,2),dia(:,2),'k.')
ylabel('DI After'); xlabel('Local bias strength after');
axis([-1 1 0 1]);

figure;

[Yn,Xn,Yerr] = slidingwindowfunc(ldsbed(:,2,2), die(:,2), -1, 0.02, 1, 0.1, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(ldsbed(:,2,2),die(:,2),'k.')
ylabel('DI Experienced'); xlabel('Local bias strength experienced');
axis([-1 1 0 1]);

figure;
[Yn,Xn,Yerr] = slidingwindowfunc(lbed(:,2,2), ldsbed(:,2,2), -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbed(:,2,2),ldsbed(:,2,2),'k.')
ylabel('Local strength bias experienced'); xlabel('Local bias experienced');
axis([-1 1 -0.8 0.8]);

figure;
[Yn,Xn,Yerr] = slidingwindowfunc(lbbd(:,2,2), ldsbbd(:,2,2), -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbbd(:,2,2),ldsbbd(:,2,2),'k.')
ylabel('Local strength bias naive'); xlabel('Local bias naive');
axis([-1 1 -0.2 0.2]);

figure;
[Yn,Xn,Yerr] = slidingwindowfunc(lbad(:,2,2), ldsbad(:,2,2), -1, 0.1, 1, 0.2, 'nanmedian',0,'diff(prctile(y,[33 66]))');
p=patch([Xn(1:end) Xn(end:-1:1)]',[Yn+Yerr*0.5 Yn(end:-1:1)-Yerr(end:-1:1)*0.5]',[1 1 1]*0.8);
set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(lbad(:,2,2),ldsbad(:,2,2),'k.')
ylabel('Local strength bias trained'); xlabel('Local bias trained');
axis([-1 1 -0.6 0.6]);


figure;
mnsbs = zeros(1,5);stebs = zeros(1,5);
mnsas = zeros(1,5);steas = zeros(1,5);
mnsos = zeros(1,5);steos = zeros(1,5);

mnsbo = zeros(1,5);stebo = zeros(1,5);
mnsao = zeros(1,5);steao = zeros(1,5);
mnsoo = zeros(1,5);steoo = zeros(1,5);

mnsbas = zeros(1,5);stebas = zeros(1,5);
mnsbao = zeros(1,5);stebao = zeros(1,5);

for i=1:5,
    mnsbo(i) = nanmedian(lobd(:,2,i));
    stebo(i) = nanmedian(lobd(:,3,i)-lobd(:,1,i));
    mnsao(i) = nanmedian(load_(:,2,i));
    steao(i) = nanmedian(load_(:,3,i)-load_(:,1,i));
    mnsoo(i) = nanmedian(loed(:,2,i));
    steoo(i) = nanmedian(loed(:,3,i)-loed(:,1,i));
    mnsbs(i) = nanmean(lsbd(:,2,i));
    stebs(i) = nanmedian(lsbd(:,3,i)-lsbd(:,1,i));
    mnsas(i) = nanmedian(lsad(:,2,i));
    steas(i) = nanmedian(lsad(:,3,i)-lsad(:,1,i));
    mnsos(i) = nanmedian(lsed(:,2,i));
    steos(i) = nanmedian(lsed(:,3,i)-lsed(:,1,i));
    mnsbas(i) = nanmedian(lsbad(:,2,i));
    stebas(i) = nanmedian(lsbad(:,3,i)-lsbad(:,1,i));
    mnsbao(i) = nanmedian(lobad(:,2,i));
    stebao(i) = nanmedian(lobad(:,3,i)-lsbad(:,1,i));    
end;

useerror = 0;

if useerror,
    h=myerrorbar(-25+[50 100 150 200 250],mnsbs,stebs);
    set(h,'color',[1 1 1]*0.7);
    hold on;
    h=myerrorbar(-25+[50 100 150 200 250],mnsas,steas);
    set(h,'color',[1 1 1]*0.4);
    h=myerrorbar(-25+[50 100 150 200 250],mnsos,steos);
    set(h,'color',[1 1 1]*0.0);
    h=myerrorbar(-25+[50 100 150 200 250],mnsbas,stebas,'--');
    set(h,'color',[1 1 1]*0.7);

    h=myerrorbar(-25+[50 100 150 200 250],-mnsbo,stebo);
    set(h,'color',[1 1 1]*0.7);
    h=myerrorbar(-25+[50 100 150 200 250],-mnsao,steao);
    set(h,'color',[1 1 1]*0.4);
    h=myerrorbar(-25+[50 100 150 200 250],-mnsoo,steoo);
    set(h,'color',[1 1 1]*0.0);
    %h=myerrorbar(-25+[50 100 150 200 250],-mnsbao,stebao,'--');
    %set(h,'color',[1 1 1]*0.7);
else,
    h=plot(-25+[50 100 150 200 250],100*mnsos,'-s','color',[1 1 1]*0.0,'linewidth',2);
    hold on;
    h=plot(-25+[50 100 150 200 250],100*mnsas,'-d','color',[1 1 1]*0.4,'linewidth',2);
    h=plot(-25+[50 100 150 200 250],100*mnsbs,'-o','color',[1 1 1]*0.7,'linewidth',2);

    %h=plot(-25+[50 100 150 200 250],100*mnsbas,'--','color',[1 1 1]*0.7);
    h=plot(-25+[50 100 150 200 250],-100*mnsbo,'-o','color',[1 1 1]*0.7,'linewidth',2);
    h=plot(-25+[50 100 150 200 250],-100*mnsao,'-d','color',[1 1 1]*0.4,'linewidth',2);
    h=plot(-25+[50 100 150 200 250],-100*mnsoo,'-s','color',[1 1 1]*0.0,'linewidth',2);
    %h=plot(-25+[50 100 150 200 250],-100*mnsbao,'--','color',[1 1 1]*0.7);
    
    h=plot(230*[1 1],60+100*mean(steos)*[-1 1],'-','color',[1 1 1]*0.0,'linewidth',2);
    h=plot(235*[1 1],60+100*mean(steas)*[-1 1],'-','color',[1 1 1]*0.4,'linewidth',2);
    h=plot(240*[1 1],60+100*mean(stebs)*[-1 1],'-','color',[1 1 1]*0.7,'linewidth',2);
    t=text(225,60,'33-66%: ','horizontalalignment','right');
    plot([0 300],100*[0.25 0.25],'k--');
    plot([0 300],100*[-0.25 -0.25],'k--');
end;

l=legend('Experienced','Motion training','Naive');
set(l,'box','off','position',[0.2 0.35 0.25 0.144]);
box off;
ch = get(gca,'children'); set(gca,'children',[ch(3:end); ch(1); ch(2)]);
xlabel('Cell distance (\mum)');
ylabel('Percent similar/dissimilar');
axis([0 250 -50 80]);

 % similar/dissimilar v 2

figure;
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


if 1,
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
end;

l=legend('Experienced','Motion training','Naive');
set(l,'box','off','position',[0.2 0.35 0.25 0.144]);
box off;
ch = get(gca,'children'); set(gca,'children',[ch(3:end); ch(1); ch(2)]);
xlabel('Cell distance (\mum)');
ylabel('Percent similar/dissimilar');
axis([0 250 -50 80]);


  % local bias index
figure;
mnsbs = zeros(1,5);stebs = zeros(1,5);
mnsas = zeros(1,5);steas = zeros(1,5);
mnsos = zeros(1,5);steos = zeros(1,5);

for i=1:5,
    mnsbs(i) = nanmean(ladbbd(:,2,i));
    stebs(i) = nanmean(ladbbd(:,3,i)-ladbbd(:,1,i));
    mnsas(i) = nanmean(ladbad(:,2,i));
    steas(i) = nanmean(ladbad(:,3,i)-ladbad(:,1,i));
    mnsos(i) = nanmean(ldabed(:,2,i));
    steos(i) = nanmean(ldabed(:,3,i)-ldabed(:,1,i));
end;

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

  % local bias strength index
figure;
mnsbs = zeros(1,5);stebs = zeros(1,5);
mnsas = zeros(1,5);steas = zeros(1,5);
mnsos = zeros(1,5);steos = zeros(1,5);
pvalsb = zeros(1,5);
pvalsa = zeros(1,5);
pvalso = zeros(1,5);

for i=1:5,
    [mnsbs(i),stebs(i),pvalsb(i)] = getmnstde(ladsbbd(:,2,i),mapnaive);
    [mnsas(i),steas(i),pvalsa(i)] = getmnstde(ladsbad(:,2,i),mapnaive);
    [mnsos(i),steos(i),pvalso(i)] = getmnstde(ldasbed(:,2,i),mapold);
end;

h=myerrorbar([50 100 150 200 250],100*mnsos,100*steos,'-');
hold on; set(h,'color',[1 1 1]*0.0);
h=myerrorbar([50 100 150 200 250],100*mnsas,100*steas,'-'); set(h,'color',[1 1 1]*0.4);
h=myerrorbar([50 100 150 200 250],100*mnsbs,100*stebs,'-'); set(h,'color',[1 1 1]*0.7);

% h=plot(230*[1 1],60+0.5*100*mean(steos(1))*[-1 1],'-','color',[1 1 1]*0.0,'linewidth',2);
% h=plot(235*[1 1],60+0.5*100*mean(steas(1))*[-1 1],'-','color',[1 1 1]*0.4,'linewidth',2);
% h=plot(240*[1 1],60+0.5*100*mean(stebs(1))*[-1 1],'-','color',[1 1 1]*0.7,'linewidth',2);
% t=text(225,60,'33-66%: ','horizontalalignment','right');
 plot([0 300],[0 0],'k--');

l=legend('Experienced','Motion training','Naive');
set(l,'box','off','position',[0.2 0.35 0.25 0.144]);
box off;
ch = get(gca,'children'); set(gca,'children',[ch(3:end); ch(1); ch(2)]);
xlabel('Cell distance (\mum)');
ylabel('Local bias strength index');
axis([0 250 0 80]);

keyboard;

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
