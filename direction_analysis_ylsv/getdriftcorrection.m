function [drift]=getdriftcorrection(cell,ds,before)

drift = 0;


if before==1,
    testname = 'Best orientation test'; dataname = 'Best orientation resp raw';
else,
    testname = 'Best OT recovery test'; dataname = 'Best OT recovery resp raw';
end;
fname = getpathname(ds);
A=findassociate(cell,testname,'','');

if ~isempty(A),
    myfname = [fname A.data '-001' filesep 'driftCorrect'];
    if exist(myfname),
        g=load([myfname],'-mat');
        drift = median(sqrt( (g.drift(:,1)-g.drift(1,1)).^2+(g.drift(:,2)-g.drift(1,2)).^2))*512/242;
    end;
end;