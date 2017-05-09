function plotdirstacks(prefix)


expnames1 = {'2006-08-17','2006-11-30','2007-02-01','2007-02-21','2007-03-01','2007-03-07','2007-05-01'};
expnames2 = {'2006-09-11','2007-06-27','2007-06-28','2007-08-30','..\spatial_freq\2007-05-29','..\spatial_freq\2007-05-31','..\spatial_freq\2007-06-05'};
% 2007-05-31 looks funny, like cells not aligned right
expnames = cat(2,expnames1,expnames2);

property = {'TP Ach OT Fit Pref','TP ME Ach OT Fit Pref','TP FE Ach OT Fit Pref'};
dirproperty = {'TP Ach OT Fit Direction index blr','TP ME Ach OT Fit Direction index blr','TP FE Ach OT Fit Direction index blr'};
pthreshold_assoc={'TP Ach OT vec varies p','TP ME Ach OT vec varies p','TP FE Ach OT vec varies p'};

condname1 = {'All cells, ', 'BA ME, ', 'BA FE, ','BA FEME, '};
condname2 = {'naive , ', 'after ME, ', 'after FE, '};
condname3 = {'DI>0.3','DI>0.05'};

condnamef1 = {'AAll_', 'ABAME_', 'ABAFE_','ABAFEME_'};
condnamef2 = {'Anaive_', 'AafterME_', 'AafterFE_'};
condnamef3 = {'ADI'};


threshold = [0.3];

for i=1:length(expnames),
	tpf = [prefix filesep expnames{i}],
	ds = dirstruct(tpf);
	
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
	
	stacknames = findallstacks(cells);
	for s=1:length(stacknames),
		[scells,inds]=selectstackcells(cells,stacknames{s});
		scellnames = cellnames(inds);
		myinds = [];
		myindsFE = [];
		myindsME = [];
		myindsMEFE = [];
		for j=1:length(scells),
			vp   = findassociate(scells{j},'TP Ach OT vec varies p','','');
			vpt   = findassociate(scells{j},'TP ME Ach OT vec varies p','','');
			vpf   = findassociate(scells{j},'TP FE Ach OT vec varies p','','');
			if ~isempty(vp) && vp.data<0.05, myinds(end+1) = j; end;
			if ~isempty(vpt) && vpt.data<0.05, myindsME(end+1) = j; end;
			if ~isempty(vpf) && vpf.data<0.05, myindsFE(end+1) = j; end;
		end;

		for c = 1:4,
			if c==1, inds = union(union(myinds,myindsME),union(myindsFE,myindsMEFE));
			elseif c==2, inds = intersect(myinds,myindsME);
			elseif c==3, inds = intersect(myinds,myindsFE);
			elseif c==4, inds = intersect(myinds,intersect(myindsME,myindsFE));
			end;
			mycells = scells(inds); mycellnames = scellnames(inds);
			if length(inds)>0,
				for k=1:3,
					for t=1:length(threshold),
						im=plototdirstack(mycells,stacknames{s},'ordirbarandarrow',1,'otdirgreenblue',0,'otgray',0,'ot_assoc',property{k},...
							 'dir_assoc',dirproperty{k},'dirthresh',threshold(t),'pthreshold_assoc',pthreshold_assoc{k},...
							 'rotate',0,'ds',ds,'cellnames',mycellnames,'line_thickness',0.2,'arrow_thickness',0.1);
						titlestr = [stacknames{s} '_' condname1{c} condname2{k} condname3{t}];
						title(titlestr,'interp','none');
						filestr = [stacknames{s} '_' condnamef1{c} condnamef2{k} condnamef3{t}],
						saveas(gcf,[getpathname(ds) filesep 'analysis' filesep filestr '.fig']);
						close(gcf);
						imwrite(im,[getpathname(ds) filesep 'analysis' filesep filestr '.tif'],'tiff','compression','none');
					end;
				end;
			end;
		end;
	end;
end;
