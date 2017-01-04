function plotf1f0OTcurve(cell,cellname, varargin)

xaxisend = 180;
assign(varargin{:});

F0=findassociate(cell,'SP F0 Ach OT Response curve','','');
F1=findassociate(cell,'SP F1 Ach OT Response curve','','');

F0f=findassociate(cell,'SP F0 Ach OT Carandini Fit','','');
F1f=findassociate(cell,'SP F1 Ach OT Carandini Fit','','');

if xaxisend==180,

[f1f0,dirpref,oiind,tunewidth,cv] = f1f0ratio(cell);

inds = mod([-90:1:89] + round(dirpref),360)+1;

closest = angdiff(dirpref-F0f.data(1,1:180))<=angdiff(dirpref-F0f.data(1,181:end));
inds = [1:180].*closest+[181:360].*(1-closest);

closest2 = angdiff(dirpref-F0.data(1,find(F0.data(1,:)<180)))<=angdiff(dirpref-F0.data(1,find(F0.data(1,:)>=180)));
inds2 = find(F0.data(1,:)<180).*closest2+find(F0.data(1,:)>=180).*(1-closest2);

hold on;
h=myerrorbar(F0.data(1,find(F0.data(1,:)<180)),F0.data(2,inds2),F0.data(4,inds2),'b');
delete(h(2));
plot([0:179],F0f.data(2,inds),'b-');

h=myerrorbar(F1.data(1,find(F0.data(1,:)<180)),F1.data(2,inds2),F1.data(4,inds2),'r');
delete(h(2));
plot([0:179],F1f.data(2,inds),'r-');

plot([-11 -11],[0 10],'k','linewidth',2);
plot([0 180],[0 0],'k--');
title(cellname,'interp','none')


else,
    hold on;
    h=myerrorbar(F0.data(1,:),F0.data(2,:),F0.data(4,:),'b');
    delete(h(2));
    plot(F0f.data(1,:),F0f.data(2,:),'b-');
    h=myerrorbar(F1.data(1,:),F1.data(2,:),F1.data(4,:),'r');
    delete(h(2));
    plot(F1f.data(1,:),F1f.data(2,:),'r-');
    plot([0 360],[0 0],'k--');
    title(cellname,'interp','none')
    plot([-11 -11],[0 10],'k','linewidth',2);

end;

A=axis; axis([-22.5 xaxisend min(A(3),-1) A(4)]);
axis off;
