function makenullhypothesishistbidir(mapnaive)

trainors = [90 270; 135 315; 0 180; 90 270; 45 180+45]; 

traindirs = [ 2 ; 2 ; 1; 2 ; 1;];

expernames = {'2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07'};

DI = [mapnaive.DI];
DIme = [];
for i=1:length(DI), if ~isempty(mapnaive(i).DIme), DIme(i) = mapnaive(i).DIme; else, DIme(i)=NaN; end; end;

mpb = [];
mpb2 = [];
mpa = [];
mpa2 = [];

for i=1:length(mapnaive),
    mytraindir = find(strcmp(mapnaive(i).expername,expernames)),
    if ~isnan(DI(i))&~isempty(mytraindir),
        mpb(i) = matchingprob(mapnaive(i).BSf.data(:,3),trainors(mytraindir,traindirs(mytraindir)));
        mpb2(i) = matchingprob(mapnaive(i).BSf.data(:,3),trainors(mytraindir,1+mod(traindirs(mytraindir),2)));
    else, mpb(i) = NaN; mpb2(i) = NaN;
    end;
    if ~isempty(mapnaive(i).DIme),
        mpa(i) = matchingprob(mapnaive(i).BSfme.data(:,3),trainors(mytraindir,traindirs(mytraindir)));
        mpa2(i) = matchingprob(mapnaive(i).BSfme.data(:,3),trainors(mytraindir,1+mod(traindirs(mytraindir),2)));
    else, mpa(i) = NaN; mpa2(i) = NaN;
    end;
end;


for i=1:5,
    inds = strcmp(expernames{i},{mapnaive.expername});
    figure;
    [X1,Y1]=cumhist(mpb(inds),[0 1],1);
    [X2,Y2]=cumhist(mpb2(inds),[0 1],1);
    plot(X1,Y1,'g'); hold on; plot(X2,Y2,'k');
    axis([0 1 0 100]);
    title(expernames{i},'interp','none');
end;

figure;
inds = find(~isnan(DI)&~isnan(DIme));
[X1,Y1]=cumhist(mpb(inds),[0 1],1);
[X2,Y2]=cumhist(mpa(inds),[0 1],1);
plot(X1,Y1,'g'); hold on; plot(X2,Y2,'r');
axis([0 1 0 100]);
title(['Null hypothesis for single direction']);
    
figure;
inds = find(~isnan(DI)&~isnan(DIme));
[X1,Y1]=cumhist(mpb2(inds),[0 1],1);
[X2,Y2]=cumhist(mpa2(inds),[0 1],1);
plot(X1,Y1,'g'); hold on; plot(X2,Y2,'r');
axis([0 1 0 100]);
title(['Null hypothesis for single direction2']);
