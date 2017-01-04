function fp = dircellflipprob(cell,MeorFE)

dir_assoc1 = 'TP Ach OT Bootstrap Carandini Fit Params';

if MeorFE==0,
	dir_assoc2='TP ME Ach OT Bootstrap Carandini Fit Params';
end;

if MeorFE==2,
	dir_assoc2='TP FE Ach OT Bootstrap Carandini Fit Params';
end;

f1=findassociate(cell,dir_assoc1,'','');
f2=findassociate(cell,dir_assoc2,'','');
if isempty(f1)|isempty(f2), fp = []; return; end;

fp = flippingprob(f1.data(:,3),f2.data(:,3));