function makedirexpsummaryplots(cells,ds)

stacknames = findallstacks(cells);

if ~isempty(ds),
	mypwd = [fixpath(getpathname(ds)) 'analysis' filesep];
end;

for i=1:length(stacknames),
	plototdirstack(ds,stacknames{i},'rotate',90);
	title(stacknames{i});
	if ~isempty(ds),
		set(gcf,'position',[312 312 560 560]); set(gcf,'paperposition',[0.25 0.25 8 8]);
		disp([mypwd 'DIRIMG_' stacknames{i} '.jpg']);
		eval(['print -djpeg90 -r300 ' mypwd 'DIRIMG_' stacknames{i} '.jpg']);
	end; 
	close;
	plototdirstack(ds,stacknames{i},'otgray',0,'rotate',90);
	title(stacknames{i});
	if ~isempty(ds),
		set(gcf,'position',[312 312 560 560]); set(gcf,'paperposition',[0.25 0.25 8 8]);
		eval(['print -djpeg90 -r300 ' mypwd 'DIROTIMG_' stacknames{i} '.jpg']);
	end; 
	close;
	plototdirstack(ds,stacknames{i},'otgray',0,'ot_assoc','OT Fit Pref 2 Peak','dir_assoc','OT Direction index 2 peak','dirthresh',-1,'rotate',90);
	if ~isempty(ds),
		set(gcf,'position',[312 312 560 560]); set(gcf,'paperposition',[0.25 0.25 8 8]);
		eval(['print -djpeg90 -r300 ' mypwd 'DIROT_ARROW_IMG_' stacknames{i} '.jpg']);
	end; 
	close;
end;

