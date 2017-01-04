function dirtpsummary(cells,cellnames)

w = []; cv = []; p = []; mr = []; indshere = []; di = []; dif = []; oi=[]; tw = []; otpf=[];

otvp = []; vvp = [];

for i=1:length(cells),

	width = findassociate(cells{i},'OT Tuning width','','');
	circv = findassociate(cells{i},'OT Circular variance','','');
	otparams = findassociate(cells{i},'OT Carandini Fit Params','','');
	dirp= findassociate(cells{i},'OT Direction index','','');
	dirf= findassociate(cells{i},'OT Fit Direction index','','');
	oti= findassociate(cells{i},'OT Orientation index','','');
	twa= findassociate(cells{i},'OT Tuning width','','');
	otp   = findassociate(cells{i},'OT varies p','','');
	vp   = findassociate(cells{i},'OT visual response p','','');
	ot_pref = findassociate(cells{i},'OT Fit Pref','','');

	if ~isempty(otp), otvp(end+1) = otp.data; end;
	if ~isempty(vp), vvp(end+1) = vp.data; end;

	if ~isempty(width)&~isempty(circv)&~isempty(otp),
		if vp.data<0.05,
			w = [w width.data]; cv = [cv circv.data]; mr = [mr max(otparams.data([2 5]))];
			indshere = [indshere i]; di = [di dirp.data]; dif=[dif dirf.data];
			oi=[oi oti.data]; tw = [tw twa.data]; otpf = [otpf; ot_pref.data];
		end;
	end;
end;

disp([int2str(length(find(otvp<0.05))) ' of ' int2str(length(otvp)) ' cells show variation across orientation (P<0.05)']);
disp([int2str(length(find(vvp<0.05))) ' of ' int2str(length(vvp)) ' cells show variation across stims and blank (P<0.05)']);

disp([int2str(length(find(tw<65))) ' of ' int2str(length(tw)) ' cells have tuning width < 65 deg']);
disp(['Median tuning of these tuned cells is ' num2str(median(mod(otpf(find(tw<65)),180))) '/' num2str(180+median(mod(otpf(find(tw<65)),180))) '.']);
disp([int2str(length(find(tw<90))) ' of ' int2str(length(tw)) ' cells have tuning width < 90 deg']);
disp(['Median tuning of these tuned cells is ' num2str(median(mod(otpf(find(tw<90)),180))) '/' num2str(180+median(mod(otpf(find(tw<90)),180))) '.']);

disp([int2str(length(find(dif>0.5))) ' of ' int2str(length(dif)) ' cells have DI fit >0.5']);
disp([int2str(length(find(di>0.5))) ' of ' int2str(length(di)) ' cells have DI (no fit) >0.5']);

otpf,

indshere,
