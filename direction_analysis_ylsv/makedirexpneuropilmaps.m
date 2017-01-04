function makedirexpneuropilmaps(ds)

  % for now, assume all angles are 0:45:360-45
angles = 0:45:360-45;

T  = getalltests(ds);
mypwd = fixpath(getpathname(ds));
scratchname = fixpath(getscratchdirectory(ds,1));
for i=1:length(T),
	T{i},
	%try,
		d = dir([scratchname '*_' T{i} '_SC']);
		if length(d)==0,
			disp(['Calculating single condition maps.']);
			dirname = [mypwd T{i}];
			[r,indimages]=prairieviewsinglecondition(dirname,[],[],[],1,T{i});
			save([scratchname 'neuropil_' T{i} '_SC'],'r','indimages','-mat');
			d = dir([scratchname '*_' T{i} '_SC']);
		end;
		load([scratchname d(1).name],'indimages','-mat');
		[or90,di90]=tporidirvectorsum(indimages(1:8),angles,ones(25),90,1);
		set(gcf,'position',[312 312 560 560]); set(gcf,'paperposition',[0.25 0.25 8 8]);
		eval(['print -djpeg90 -r300 ' mypwd filesep 'analysis' filesep 'NEUROPILMAP_' T{i} '.jpg']);
	%end;
end;

if ~isempty(ds),
	mypwd = [getpathname(ds) filesep 'analysis' filesep];
end;

