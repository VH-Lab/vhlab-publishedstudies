function makedensityplots(prefix,expernames,stacknames)

 % prefix = 'e:\2photon\ferretdirection\';
 % expernames = {'2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07'};

for i=1:length(expernames),
	tpf = [prefix expernames{i}];
	ds = dirstruct(tpf);
	mycells = selectstackcells(ds,stacknames{i});
	densityimgbeforeafter(mycells,1);
	saveas(gcf,[fixpath(getpathname(ds)) 'analysis' filesep 'density_after.fig']);
	close(gcf);
	saveas(gcf,[fixpath(getpathname(ds)) 'analysis' filesep 'density_before.fig']);
	close(gcf);	
end;