function [di,RP,RN,BL] = newferretdi(cell, before)

dir_assoc='TP Ach OT Carandini Fit Params';
ot_assoc = 'TP Ach OT Fit Pref';
bor_assoc = 'Best orientation resp';
dir_pref_assoc = 'Tp Ach OT Fit Pref';
fit_assoc = 'TP Ach OT Carandini Fit';

if ~before,
	dir_assoc='TP ME Ach OT Carandini Fit Params';
	ot_assoc = 'TP ME Ach OT Fit Pref';
	bor_assoc = 'TP ME Ach Best orientation resp';
	dir_pref_assoc = 'TP ME Ach OT Fit Pref';
	fit_assoc = 'TP ME Ach OT Carandini Fit';
end;

f=findassociate(cell,dir_assoc,'','');
bl=findassociate(cell,bor_assoc,'','');
dp = findassociate(cell,dir_pref_assoc,'','');
fi=findassociate(cell,fit_assoc,'','');

if isempty(f)|isempty(bl)|isempty(dp)|isempty(fi), di = []; return; end;

if isfield(bl(1).data,'blankresp'),
	blankresp = min(0,bl(1).data.blankresp(1));
else, blankresp = 0;
end;

OtPi=findclosest(0:359,f(1).data(3)); OtNi=findclosest(0:359,mod(f(1).data(3)+180,360));
di=(fi(1).data(OtPi)-fi(1).data(OtNi))/(fi(1).data(OtPi)-blankresp);

RP = fi(1).data(OtPi);
RN = fi(1).data(OtNi);
BL = blankresp;