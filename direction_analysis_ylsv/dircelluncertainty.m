function unc = dircelluncertainty(cell,before)

dir_assoc='TP Ach OT Bootstrap Carandini Fit Params';

if before==0,
	dir_assoc='TP ME Ach OT Bootstrap Carandini Fit Params';
end;

if before==2,
	dir_assoc='TP FE Ach OT Bootstrap Carandini Fit Params';
end;

f=findassociate(cell,dir_assoc,'','');
if isempty(f), unc = []; return; end;

unc = dpuncertainty(f.data(:,3));