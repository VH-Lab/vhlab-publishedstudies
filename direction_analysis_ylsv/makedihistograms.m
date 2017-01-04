function makedihistograms

w = []; cv = []; p = []; mr = []; indshere = []; di = []; dif = []; oi=[]; tw = []; otpf=[];
otvp = []; vvp = [];


prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
expnames = {'2006-06-12','2006-07-11','2006-07-17','2006-07-18'};

figure;
for i=1:length(expnames),
	tpf = [prefix expnames{i}];
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	di = []; dif = [];
	for j=1:length(cells),

		width = findassociate(cells{j},'OT Tuning width','','');
	        circv = findassociate(cells{j},'OT Circular variance','','');
		otparams = findassociate(cells{j},'OT Carandini Fit Params','','');
		dirp= findassociate(cells{j},'OT Direction index','','');
		dirf= findassociate(cells{j},'OT Fit Direction index','','');
		oti= findassociate(cells{j},'OT Orientation index','','');
		twa= findassociate(cells{j},'OT Tuning width','','');
		otp   = findassociate(cells{j},'OT varies p','','');
		vp   = findassociate(cells{j},'OT visual response p','','');
		ot_pref = findassociate(cells{j},'OT Fit Pref','','');

		if ~isempty(width)&~isempty(circv)&~isempty(otp),
			if vp.data<0.05,
				w = [w width.data]; cv = [cv circv.data]; mr = [mr max(otparams.data([2 5]))];
	                        indshere = [indshere i]; di = [di dirp.data]; dif=[dif dirf.data];
	                        oi=[oi oti.data]; tw = [tw twa.data]; otpf = [otpf; ot_pref.data];
			end;
		end;
	end;

	subplot(2,2,i);
	bins = [-Inf 0:0.05:1 Inf]; x = [ 0:0.05:1-0.05 ] +0.05/2;
	N = histc(dif,bins);
	bar(x,N(2:end-2));
	title(expnames{i},'interp','none');
	a = axis;
	axis([0 1 a([3 4])]); 
end;
