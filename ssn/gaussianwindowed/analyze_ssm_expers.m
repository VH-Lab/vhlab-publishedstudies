
prefix = '/Volumes/Data1/Ameya/';

dirnames = {'2012-06-27'};
dirnames = {'2012-06-27','2012-07-10','2012-07-24','2012-08-08','2012-08-14','2012-08-23'};

[cells,cellnames] = readcellsfromexperimentlist(prefix,dirnames,1,5);

for i=1:length(cells),

	figure;
	plot_sharpgauss(cells{i},cellnames{i});

end;
