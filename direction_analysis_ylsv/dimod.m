function [di,RP,RN] = dimod(cell, before)

dir_assoc='TP Ach OT Carandini Fit Params';
ot_assoc = 'TP Ach OT Fit Pref';
dir_pref_assoc = 'TP Ach OT Fit Pref';
fit_assoc = 'TP Ach OT Carandini Fit';

if before==0,
	dir_assoc='TP ME Ach OT Carandini Fit Params';
	ot_assoc = 'TP ME Ach OT Fit Pref';
	dir_pref_assoc = 'TP ME Ach OT Fit Pref';
	fit_assoc = 'TP ME Ach OT Carandini Fit';
end;

if before==2,
	dir_assoc='TP FE Ach OT Carandini Fit Params';
	ot_assoc = 'TP FE Ach OT Fit Pref';
	dir_pref_assoc = 'TP FE Ach OT Fit Pref';
	fit_assoc = 'TP FE Ach OT Carandini Fit';
end;


f=findassociate(cell,dir_assoc,'','');
dp = findassociate(cell,dir_pref_assoc,'','');
fi=findassociate(cell,fit_assoc,'','');

if isempty(f)|isempty(dp)|isempty(fi), di = []; return; end;


fi(1).data = fi(1).data(2,:);

OtPi=findclosest(0:359,f(1).data(3)); OtNi=findclosest(0:359,mod(f(1).data(3)+180,360));
di=(fi(1).data(OtPi)-fi(1).data(OtNi))/(fi(1).data(OtPi)+fi(1).data(OtNi));

RP = fi(1).data(OtPi);
RN = fi(1).data(OtNi);
