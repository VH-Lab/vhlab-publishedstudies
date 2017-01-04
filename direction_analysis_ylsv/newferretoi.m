function oi = newferretoi(cell, before)

dir_assoc='TP Ach OT Carandini Fit Params';
ot_assoc = 'TP Ach OT Fit Pref';
bor_assoc = 'Best orientation resp';
dir_pref_assoc = 'TP Ach OT Fit Pref';
fit_assoc = 'TP Ach OT Carandini Fit';

if ~before,
	dir_assoc='TP ME Ach OT Carandini Fit Params';
	ot_assoc = 'TP ME Ach OT Fit Pref';
	bor_assoc = 'Best OT recovery resp';
	dir_pref_assoc = 'TP ME Ach OT Fit Pref';
	fit_assoc = 'TP ME Ach OT Carandini Fit';
end;

diassoc=findassociate(cell,dir_assoc,'','');
bl=findassociate(cell,bor_assoc,'','');
dp = findassociate(cell,dir_pref_assoc,'','');
fitcurve=findassociate(cell,fit_assoc,'','');

if isempty(diassoc)|isempty(bl)|isempty(dp)|isempty(fitcurve), oi = []; return; end;

fitcurve.data = fitcurve.data(2,:);

if isfield(bl(1).data,'blankresp'),
	blankresp = min(0,bl(1).data.blankresp(1));
else, blankresp = 0;
end;

OtPi = findclosest(0:359,diassoc.data(3)); OtNi = findclosest(0:359,mod(diassoc.data(3)+180,360));
OtO1i = findclosest(0:359,mod(diassoc.data(3)+90,360)); OtO2i = findclosest(0:359,mod(diassoc.data(3)-90,360));
oi = (fitcurve.data(OtPi)+fitcurve.data(OtNi)-fitcurve.data(OtO1i)-fitcurve.data(OtO2i))/(fitcurve.data(OtPi)+fitcurve.data(OtNi)-blankresp-blankresp);
