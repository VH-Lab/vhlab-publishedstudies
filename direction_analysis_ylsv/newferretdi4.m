%function [di,dp,BSdi,BSdp,Rp,Rn,Ro,Rt1,Rt2,x,y] = newferretdi4(cell, before, motion, traindir)
function [Rp,Rt1,Rt2] = newferretdi4(cell, before, motion, traindir,r)

dir_assoc='TP Ach OT Fit Direction index blr';
loc_assoc = 'pixellocs';
bor_assoc = 'Best orientation resp';
dir_pref_assoc = 'TP Ach OT Fit Pref';
ot_assoc = 'TP Ach OT Carandini Fit Params';
fit_assoc = 'TP Ach OT Carandini Fit';
BSf_assoc = 'TP Ach OT Bootstrap Carandini Fit Params';
BSrs_assoc = 'TP Ach OT Response struct';

if ~before && motion,
	dir_assoc='TP ME Ach OT Fit Direction index blr';
	bor_assoc = 'Best OT recovery resp';
	dir_pref_assoc = 'TP ME Ach OT Fit Pref';
	fit_assoc = 'TP ME Ach OT Carandini Fit';
    ot_assoc = 'TP ME Ach OT Carandini Fit Params';
    BSf_assoc = 'TP ME Ach OT Bootstrap Carandini Fit Params';
    BSrs_assoc = 'TP ME Ach OT Response struct';
end;

if ~before && ~motion,
	dir_assoc='TP FE Ach OT Fit Direction index blr';
	bor_assoc = 'Best Flash OT recovery resp';
	dir_pref_assoc = 'TP FE Ach OT Fit Pref';
	fit_assoc = 'TP FE Ach OT Carandini Fit';
    ot_assoc = 'TP FE Ach OT Carandini Fit Params';
    BSf_assoc = 'TP FE Ach OT Bootstrap Carandini Fit Params';
    BSrs_assoc = 'TP FE Ach OT Response struct';
end;


di=findassociate(cell,dir_assoc,'','');
loc=findassociate(cell,loc_assoc,'','');
bl=findassociate(cell,bor_assoc,'','');
dp = findassociate(cell,dir_pref_assoc,'','');
f=findassociate(cell,ot_assoc,'','');
fi=findassociate(cell,fit_assoc,'','');
BSf = findassociate(cell,BSf_assoc,'','');
BSrs = findassociate(cell,BSrs_assoc,'','');

if isempty(di)|isempty(loc)|isempty(dp)|isempty(fi), 
    di = []; dp = []; BSdi = []; BSdp = []; Rp = []; Rn = []; Ro = []; Rt = []; x = []; y = [];return; 
end;

if isfield(bl(1).data,'blankresp'),
	blankresp = min(0,bl(1).data.blankresp(1));
else, blankresp = 0;
end;

OtPi=findclosest(0:359,f(1).data(3)); OtNi=findclosest(0:359,mod(f(1).data(3)+180,360));
OtO1i = findclosest(0:359,mod(f(1).data(3)+90,360)); OtO2i = findclosest(0:359,mod(f(1).data(3)-90,360));

%keyboard;
di= di.data;
dp = dp.data;
x = mean(loc.data.x);
y = mean(loc.data.y);
BSdp = BSf.data(:,3);
BSdi = calc_bootstrap_di(BSf.data,BSrs.data.blankind,r);
Rp = fi.data(2,OtPi)-min(fi.data(2,OtNi),blankresp);
Rn = fi.data(2,OtNi)-min(fi.data(2,OtNi),blankresp);
Ro = max(0,mean([fi.data(2,OtO1i) fi.data(2,OtO2i)])-blankresp);

if isempty(traindir), Rt = [];return;end;
base = 180; mydiff = mod(angdiff(dp-traindir),base);
if mydiff<45, Rt1 = Rp; else Rt1 = Rn; end;

%another way to calculate Rt
Otti = findclosest (0:359,traindir);
Rt2 = fi.data(2,Otti)-min(fi.data(2,OtNi),blankresp);



