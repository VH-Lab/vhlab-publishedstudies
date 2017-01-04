function makedihistograms

w = []; cv = []; p = []; mr = []; indshere = []; di = []; dif = []; oi=[]; tw = []; otpf=[];
otvp = []; vvp = [];


prefix = '/Volumes/VHbackup2/fitzdata/twophoton/ferret/';
expnames = {'2006-06-12','2006-07-11','2006-07-17','2006-07-18','2006-08-02'};

figure;
for i=1:length(expnames),
	tpf = [prefix expnames{i}];
	ds = dirstruct(tpf);

	analyzedirtpexperauto(tpf,1);
end;
