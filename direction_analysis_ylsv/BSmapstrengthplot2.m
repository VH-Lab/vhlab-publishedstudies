function BSmapstrengthplot(expname)
% mpbPTall = []; mpaPTall = []; BSlmib100PTall = []; BSlmia100PTall = [];
% mpbNTall = []; mpaNTall = []; BSlmib100NTall = []; BSlmia100NTall = [];
% mpbUNall = []; mpaUNall = []; BSlmib100UNall = []; BSlmia100UNall = [];
 mpball = []; mpaall = []; BSlbib100all = []; BSlbia100all = [];
 

for I = 1: length(expname),
         %load(['E:\yli\data\woBS5\' expname{I} '_mapstrengthNEW2.mat'],'mycellnumber','eyesopen','darkrearing',...
     load(['E:\svanhooser\woBS5\' expname{I} '_mapstrengthNEW2.mat'],'mycellnumber','eyesopen','darkrearing',...
             'di','dp','dit','dpt','mpb','mpa','ratio2b','ratio2a','dibsign','diasign','xyloc',...
             'respb1', 'respa1', 'respave1', 'respb2', 'respa2', 'respave2', 'respmaxb', 'respmaxa',...
             'mapstrength','mapstrengtht','mapstrengthMC','mapstrengthtMC',...
             'BSlbib','BSlbia','BSlmib','BSlmia','BSlbib100','BSlbib100','BSlbia100','BSlmib100','BSlmia100',...
             'TMb','TMa','mpb','mpa','expnames','stacknames','trainangle','traintime','traintype','dists');
      indPT = find(mpb>0.75&~isnan(mpa));indNT = find(mpb<0.25&~isnan(mpa));indUN = find(mpb>=0.25&mpb<=0.75&~isnan(mpa));
    
 figure;
 subplot(1,3,1);plot(BSlbib100(indPT), mpa(indPT)-mpb(indPT),'ro');axis([-1 1 -1 1]); axis square; title (expname(I));
 subplot(1,3,2);plot(BSlbib100(indNT), mpa(indNT)-mpb(indNT),'go');axis([-1 1 -1 1]); axis square; title (expname(I));
 subplot(1,3,3);plot(BSlbib100(indUN), mpa(indUN)-mpb(indUN),'ko');axis([-1 1 -1 1]); axis square; title (expname(I));


% mpbPTall = [mpbPTall mpb(indPT)]; mpaPTall = [mpaPTall mpa(indPT)]; BSlmib100PTall = [BSlmib100PTall BSlmib100(indPT)]; BSlmia100PTall = [BSlmia100PTall BSlmia100(indPT)];
% mpbNTall = [mpbNTall mpb(indNT)]; mpaNTall = [mpaNTall mpa(indNT)]; BSlmib100NTall = [BSlmib100NTall BSlmib100(indNT)]; BSlmia100NTall = [BSlmia100NTall BSlmia100(indNT)];
% mpbUNall = [mpbUNall mpb(indUN)]; mpaUNall = [mpaUNall mpa(indUN)]; BSlmib100UNall = [BSlmib100UNall BSlmib100(indUN)]; BSlmia100UNall = [BSlmia100UNall BSlmia100(indUN)];
mpball = [mpball mpb]; mpaall = [mpaall mpa]; BSlbib100all = [BSlbib100all BSlbib100]; BSlbia100all = [BSlbia100all BSlbia100];


end;
 
 indPT = [];indNT = []; indUN = [];
 indPT = find(mpball>0.75&~isnan(mpaall));indNT = find(mpball<0.25&~isnan(mpaall));indUN = find(mpball>=0.25&mpball<=0.75&~isnan(mpaall));

 
stepsize = 0.1;
figure;
subplot(1,3,1);plot(BSlbib100all(indPT), mpaall(indPT)-mpball(indPT),'ro');axis([-.6 .6 -1 1]); axis square; title('prefer')
[Yn,Xn,Yerr_p] = slidingwindowfunc(BSlbib100all(indPT), mpaall(indPT)-mpball(indPT), -1, stepsize, 1, 0.2, 'nanmean',0,'prctile(y,[50])');
hold on;
%plot(Xn-.2,Yn,'k-','linewidth',2); box off;
subplot(1,3,2);plot(BSlbib100all(indNT), mpaall(indNT)-mpball(indNT),'go','color',[0 0 1]);axis([-.6 .6 -1 1]); axis square; title('non-prefer')
[Yn,Xn,Yerr_p] = slidingwindowfunc(BSlbib100all(indNT), mpaall(indNT)-mpball(indNT), -1, stepsize, 1, 0.2, 'nanmean',0,'prctile(y,[50])');
hold on;
plot(Xn,Yn,'k-','linewidth',2); box off;
subplot(1,3,3);plot(BSlbib100all(indUN), mpaall(indUN)-mpball(indUN),'o','color',[0.5 0.5 0.5]);axis([-.6 .6 -1 1]); axis square; title('uncertain')
[Yn,Xn,Yerr_p] = slidingwindowfunc(BSlbib100all(indUN), mpaall(indUN)-mpball(indUN), -1, stepsize, 1, 0.2, 'nanmean',0,'prctile(y,[50])');
hold on;
%plot(Xn-.2,Yn,'k-','linewidth',2); box off;

clear all;