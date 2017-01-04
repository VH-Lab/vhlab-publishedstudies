function dirtpbeforeafter(tpf, dirthresh, stackname)

myfig = figure;

%stacknames = {'site1','site1'};
labels={'Initial', 'Training'};

property = {'OT Fit Pref 2 Peak','Recovery OT Fit Pref 2 Peak'};
dirproperty = {'OT Direction index 2 peak','Recovery OT Direction index 2 peak'};
pthreshold_assoc = {'OT visual response p','Recovery OT visual response p'};

for i=1:2,
	% load cells
	ds = dirstruct(tpf);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

	plototdirstack(ds,stackname,'otdirgreenblue',1,'otgray',0,'ot_assoc',property{i},...
         'dir_assoc',dirproperty{i},'dirthresh',dirthresh,'pthreshold_assoc',pthreshold_assoc{i},'rotate',90);
    title(labels{i});
end;

