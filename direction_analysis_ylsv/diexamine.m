

PV = [];
OI = [];
DI = [];
DIsp = [];
OIsp = [];

for j=1:length(cells),
    di_a = findassociate(cells{j},'OT Direction index 2 peak','','');
	ot_a = findassociate(cells{j},'OT Orientation index 2 peak','','');
    pvalasoc = findassociate(cells{j},'OT visual response p','','');
    carprefs = findassociate(cells{j},'OT Carandini 2-peak Fit Params','','');
    carfit = findassociate(cells{j},'OT Carandini 2-peak Fit','','');
    disp_a = findassociate(cells{j},'OT Direction index 2 peak sp','','');
	otsp_a = findassociate(cells{j},'OT Orientation index 2 peak sp','','');
    
    PV(end+1) = pvalasoc.data;
    OI(end+1)=ot_a.data;
    DI(end+1)=di_a.data;
    DIsp(end+1)=disp_a.data;
    OIsp(end+1)=otsp_a.data;
end;

