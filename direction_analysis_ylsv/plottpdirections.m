function plottpdirections(cell, cellname)

figure;
plottpresponse(cell,cellname,'Direction Bootstrap Angles',1,1);
subplot(2,2,4);
plottpresponse(cell,cellname,'TP Ach OT Fit Pref',1,1);

A=findassociate(cell,'TP Ach OT vec varies p','',''),
B=findassociate(cell,'TP Ach OT visual response p','',''),
C=findassociate(cell,'TP Ach OT Fit Direction index blr','',''),
D=findassociate(cell,'TP Ach OT Fit Orientation index blr','',''),


subplot(2,2,3);
cv = cell2circular_variance(cell,'TP Ach'),
