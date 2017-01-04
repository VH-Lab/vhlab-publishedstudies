function plotdirpsthnull(cell,cellname,before)


plot([-100 1000],[0 0],'--','color',[0.001 0.001 .001],'linewidth',2);
hold on;
if before==1,
    testname = 'Best orientation test'; dataname = 'Best orientation resp raw';
else,
    testname = 'Best OT recovery test'; dataname = 'Best OT recovery resp raw';
end;
cn=cellname(end-9:end);
cn(find(cn=='_'))='-';
fname = ['e:\2photon\ferretdirection\' cn];
ds = dirstruct(fname);
psth = tpquickpsth(ds,testname,dataname,cell,cellname,1,1.5,0.5);
bestsum = -Inf; bestind = [];
intv = 10:19;
if 1,
bl = nanmean(psth.avg{end}(intv))*0;
for j=1:length(psth.avg),
    if sum(psth.avg{j}(intv))>bestsum,
        bestsum = sum(psth.avg{j}(intv));
        bestind = j;
    end;
end;
orth=bestind-4; if orth<1, orth=bestind+4; end;
plot(psth.bins,psth.avg{bestind}-bl,'linewidth',2);
hold on;
plot(psth.bins,psth.avg{orth}-bl,'m','linewidth',2);
plot(psth.bins,psth.avg{end}-bl,'k','linewidth',2);
else,
    for j=1:length(psth.avg),
        plot(psth.bins,psth.avg{j},'linewidth',2);                
    end;
end;
set(gca,'visible','off'); xlabel(''); ylabel(''); title('');
plot([0 5],-.075*[1 1],'k','linewidth',2);
axis([-5 10 -.1 0.3]);