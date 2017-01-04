function printstackinfo(prefix)

%expnames = {'2006-08-17','2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07','2007-05-01'};
%expnames = {'2007-06-27','2007-06-28','2007-08-30'};
%expnames = {'2007-05-29','2007-05-31','2007-06-05'};
expnames = {'2006-09-11'};%,'2007-05-31','2007-06-05'}; % 2007-05-31 looks funny, like cells not aligned right

for i=1:length(expnames),
	tpf = [prefix filesep expnames{i}];
	ds = dirstruct(tpf);
	
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	
	stacknames = findallstacks(cells);
	for s=1:length(stacknames),
        depths = [];
		[scells,inds]=selectstackcells(cells,stacknames{s});
		scellnames = cellnames(inds);
        eya = findassociate(scells{1},'Eyes open','','');
        agea = findassociate(scells{1},'Age','','');
		for j=1:length(scells),
            xyz = tpgetcellposition(scells{j});
            depths(end+1) = xyz(3);
		end;
        depths = unique(depths);
        disp([expnames{i} ', stack ' stacknames{s} ', PND=' int2str(agea.data) ', EO=' int2str(eya.data) ', depths = ' mat2str(depths) '.']); 
	end;
end;