function plotSimMapStrength

load('e:\svanhooser\newferretmtg\mcMapSimCompute.mat');

usepatches = 0;

DIcol = [1 0 0] * 1;
LBcol = [0 1 0] * 1;

stepsize = 0.1;
dist = 2;

keyboard;

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbbd(:,2,dist), fpf, -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbbd(:,2,dist), fpf, -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
%p=patch(100*[Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
%set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(100*lbbd(:,2,2),fpf,'k.')
[slope,offset,slope_confinterval,resid,residint,stats] = quickregression(100*lbbd(:,2,3),fpf',0.05);
slope_confinterval,stats,
h=plot([-100 100],[-100 100]*slope+offset,'k--'); set(h,'color',[1 1 1]*0)
axis ([ -60 60 0 1.0]);
ylabel('Prob of Dir Flip'); xlabel('Local bias before training');
box off;

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbbd(:,2,dist), ddiLBdf, -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbbd(:,2,dist), ddiLBdf, -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
%p=patch(100*[Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
%set(p,'edgecolor',[1 1 1]*0.8);

hold on;
plot(100*lbbd(:,2,2),ddiLBdf,'k.')
[slope,offset,slope_confinterval,resid,residint,stats] = quickregression(lbbd(:,2,2),ddiLBdf',0.05);
slope_confinterval,
h=plot([-100 100],[-100 100]*slope+offset,'k--'); set(h,'color',[1 1 1]*0)
axis ([ -60 60 -0.5 1.0]);
ylabel('Change in DI'); xlabel('Local bias before training');
box off;

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbbd(:,2,dist), dib(:,2), -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbbd(:,2,dist), dib(:,2), -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
[Yn2,Xn2,Yerr2_n] = slidingwindowfunc(dib(:,dist), lbbd(:,2,2), 0-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn2,Xn2,Yerr2_p] = slidingwindowfunc(dib(:,dist), lbbd(:,2,2), 0-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
if usepatches,
    p=patch(100*[Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
    set(p,'edgecolor',[1 1 1]*0.8);
else,
    plot(100*Xn,Yn,'color',DIcol,'linewidth',4);hold on;
    plot(100*Yn2,Xn2,'color',LBcol, 'linewidth',4);
end;

hold on;
plot(100*lbbd(:,2,dist),dib(:,2),'k.')
ylabel('DI Naive'); xlabel('Local bias naive');
axis([-100 100 0 1.05]);
box off;
text(100,median(dib(:,2)),'<','horizontalalignment','center','VerticalAlignment','middle');
text(median(100*lbbd(:,2,dist)),1.05,'v','horizontalalignment','center','VerticalAlignment','middle');

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbad(:,2,dist), dia(:,2), -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbad(:,2,dist), dia(:,2), -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
[Yn2,Xn2,Yerr2_n] = slidingwindowfunc(dia(:,2), lbad(:,2,dist), 0-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn2,Xn2,Yerr2_p] = slidingwindowfunc(dia(:,2), lbad(:,2,dist), 0-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
if usepatches,
    p=patch(100*[Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
    set(p,'edgecolor',[1 1 1]*0.8);
else,
    plot(100*Xn,Yn,'color',DIcol,'linewidth',4); hold on;
    plot(100*Yn2,Xn2,'color',LBcol, 'linewidth',4);
end;

hold on;
plot(100*lbad(:,2,dist),dia(:,2),'k.')
ylabel('DI After'); xlabel('Local bias after');
axis([-100 100 0 1.05]);
box off;
text(100,nanmedian(dia(:,2)),'<','horizontalalignment','center','VerticalAlignment','middle');
text(nanmedian(100*lbad(:,2,dist)),1.05,'v','horizontalalignment','center','VerticalAlignment','middle');

figure;

[Yn,Xn,Yerr_n] = slidingwindowfunc(lbed(:,2,dist), die(:,2), -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn,Xn,Yerr_p] = slidingwindowfunc(lbed(:,2,dist), die(:,2), -1-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
[Yn2,Xn2,Yerr2_n] = slidingwindowfunc(die(:,dist), lbed(:,2,dist), 0-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[33.333])');
[Yn2,Xn2,Yerr2_p] = slidingwindowfunc(die(:,dist), lbed(:,2,dist), 0-0.2, stepsize, 1+0.2, 0.2, 'nanmedian',0,'prctile(y,[66.667])');
if usepatches,
    p=patch(100*[Xn(1:end) Xn(end:-1:1)]',[Yerr_n Yerr_p(end:-1:1)]',[1 1 1]*0.8);
    set(p,'edgecolor',[1 1 1]*0.8);
else,
    Yn(find(Yn==1)) = 1.025;
    plot(100*Xn,Yn,'color',DIcol,'linewidth',4); hold on;
    plot(100*Yn2,Xn2,'color',LBcol, 'linewidth',4);
end;

mymed = median(die(:,2));
myones = find(die(:,2)>0.999); length(myones);
die(myones,2) = 1 + 0.05*rand(size(lbed(myones,2)));

hold on;
plot(100*lbed(:,2,dist),die(:,2),'k.')
ylabel('DI Experienced'); xlabel('Local bias experienced');
axis([-100 100 0 1.05]);
box off;
text(100,mymed,'<','horizontalalignment','center','VerticalAlignment','middle');
text(median(100*lbed(:,2,dist)),1.05,'v','horizontalalignment','center','VerticalAlignment','middle');


  % local bias index
figure;

mnsbs = zeros(1,5);stebs = zeros(1,5);
mnsas = zeros(1,5);steas = zeros(1,5);
mnsos = zeros(1,5);steos = zeros(1,5);
mnsfs = zeros(1,5);stefs = zeros(1,5);
pvalsb = zeros(1,5);
pvalsa = zeros(1,5);
pvalso = zeros(1,5);
pvalsf = zeros(1,5);

for i=1:5,
    [mnsbs(i),stebs(i),pvalsb(i),mydat] = getmnstde(ladbbd(:,2,i),mapnaive);
    [mnsas(i),steas(i),pvalsa(i)] = getmnstde(ladbad(:,2,i),mapnaive);
    [mnsos(i),steos(i),pvalso(i)] = getmnstde(ldabed(:,2,i),mapold);
    [mnsfs(i),stefs(i),pvalsf(i)] = getmnstde(ladbadf(:,2,i),mapnaive);
end;

h=plot([50 100 150 200 250],100*mnsos,'-s','color',[1 1 1]*0.0,'linewidth',2);
hold on;
h=plot([50 100 150 200 250],100*mnsas,'-d','color',[1 1 1]*0.4,'linewidth',2);
h=plot([50 100 150 200 250],100*mnsbs,'-o','color',[1 1 1]*0.7,'linewidth',2);
h=plot([50 100 150 200 250],100*mnsfs,'-^','color',[1 1 1]*0.2,'linewidth',2);


h=plot(230*[1 1],15+1*100*mean(steos(1))*[-1 1],'-','color',[1 1 1]*0.0,'linewidth',2);
h=plot(235*[1 1],15+1*100*mean(steas(1))*[-1 1],'-','color',[1 1 1]*0.4,'linewidth',2);
h=plot(240*[1 1],15+1*100*mean(stebs(1))*[-1 1],'-','color',[1 1 1]*0.7,'linewidth',2);
h=plot(245*[1 1],15+1*100*mean(stefs(1))*[-1 1],'-','color',[1 1 1]*0.2,'linewidth',2);
t=text(225,15,'SEM (%): ','horizontalalignment','right');
plot([0 300],[0 0],'k--');

l=legend('Experienced','Motion training','Naive','Flash training');
set(l,'box','off','position',[0.6116    0.7283    0.2554    0.1444]);
box off;
ch = get(gca,'children'); set(gca,'children',[ch(3:end); ch(1); ch(2)]);
xlabel('Cell distance (\mum)');
ylabel('Local bias index');
axis([25 275 -10 35]);

figure;
%bins=[-Inf -101:2:100+1 Inf]; X = -100:2:100;
Y = 0:.01:100;
X1=[-100 prctile(100*lbbd(:,2,dist),Y) 100];
X2=[-100 prctile(100*lbad(:,2,dist),Y) 100];
X3=[-100 prctile(100*lbed(:,2,dist),Y) 100];
X4=[-100 prctile(100*lbadf(:,2,dist),Y) 100];
plot(X1,[0 Y 100],'k','color',[1 1 1]*0.7,'linewidth',1); hold on;
plot(X2,[0 Y 100],'k','color',[1 1 1]*0.4,'linewidth',1);
plot(X3,[0 Y 100],'k','color',[1 1 1]*0,'linewidth',1);
plot(X4,[0 Y 100],'k','color',[1 1 1]*0.2,'linewidth',1);
plot([-100 100],[50 50],'k--','linewidth',1);
box off;
ylabel('Percent');
xlabel('Local bias index');
set(gca,'xtick',[-100 -50 0 50 100],'ytick',[0 20 40 60 80 100]);
axis([-100 100 0 100]);

return;

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

X = fminsearch(@(x) mythreecurveerror(x,mnsos,mnsbs,mnsas), [1; 1]);


h=plot([50 100 150 200 250],100*mnsos,'-s','color',[1 1 1]*0.0,'linewidth',2);
hold on;
h=plot([50 100 150 200 250],100*mnsas*X(2),'-d','color',[1 1 1]*0.4,'linewidth',2);
h=plot([50 100 150 200 250],100*mnsbs*X(1),'-o','color',[1 1 1]*0.7,'linewidth',2);

h=plot(230*[1 1],15+1*100*mean(steos(1))*[-1 1],'-','color',[1 1 1]*0.0,'linewidth',2);
h=plot(235*[1 1],15+1*100*mean(X(2)*steas(1))*[-1 1],'-','color',[1 1 1]*0.4,'linewidth',2);
h=plot(240*[1 1],15+1*100*mean(X(1)*stebs(1))*[-1 1],'-','color',[1 1 1]*0.7,'linewidth',2);
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

mymn = nanmean(mydat);
mystde = nanstderr(mydat');
[h,myp] = ttest(mydat,0,0.05,'right');
%myp = signtest(mydat);
