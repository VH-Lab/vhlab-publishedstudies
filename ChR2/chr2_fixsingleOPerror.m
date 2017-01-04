function chr2_fixsingleOPerror(dirname)
% CHR2_FIXSINGLEOPERROR - Reclassify SingleOPs to 
%
%   CHR2_FIXSINGLEOPERROR(DIRNAME)
%
%   Given a directory name DIRNAME, this function reads in the cells
%   and 
%
%  


  docells = 1;

 % Step 1, read in data


ds =dirstruct(dirname);

if docells,
	disp(['Now reading cells from disk from directory ' dirname '.']);
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
end;

 % Step 2, for each cell, look to see if it has any of the appropriate types; if so, replace it


findlist = {'SingleOP2Hz%d test', 'SingleOP4Hz%d test', 'SingleOP1Hz%d test'};
findlist2 = {'SingleOP2Hz%d', 'SingleOP4Hz%d', 'SingleOP1Hz%d'};

replace_prefix = 'OPBr';
color = {'Wh','Bl'};
stimtype = {'Gr','Fld'};

if docells,

disp(['Now editing associates. This may take a few minutes.']);
for i=1:length(cells),
	for f=1:length(findlist),
		N = repeated_measurement_associates(cells{i},findlist{f},10);
		for n=1:length(N),
			% get the directory
			[testassoc,Index] = findassociate(cells{i},sprintf(findlist{f},N(n)),'','');
			testdir = testassoc.data;
			s=load([getpathname(ds) filesep testdir filesep 'stims.mat']);
			params = getparameters(get(s.saveScript,1));
			color_type = 1+eqlen(params.chromhigh(1:2),[0;0]);
			stimtype_type = 1+eqlen(params.imageType,0);
			assocname = [replace_prefix color{color_type} stimtype{stimtype_type} ' test'];
			cells{i} = disassociate(cells{i},Index);
			newassociate = newassoc(assocname,'chr2_fixsingleOPerror',testassoc.data,testassoc.desc);
			cells{i} = associate(cells{i},assocname,'chr2_fixsingleOPerror',testassoc.data,testassoc.desc);
		end;
	end;
end;

end;

disp(['Now examining testdirinfo.txt file...']);

if exist([getpathname(ds) filesep 'testdirinfo.txt']),
	copyfile([getpathname(ds) filesep 'testdirinfo.txt'],[getpathname(ds) filesep 'testdirinfo_bkup.txt']);
	testdirinfo = loadStructArray([getpathname(ds) filesep 'testdirinfo.txt']);
	for t=1:length(testdirinfo),
		for f=1:length(findlist2),
			for n=1:10,
				if strcmp(sprintf(findlist2{f},n),testdirinfo(t).types), % we have a match
					disp(['match'])
					s=load([getpathname(ds) filesep testdirinfo(t).testdir filesep 'stims.mat']);
					params = getparameters(get(s.saveScript,1));
					color_type = 1+eqlen(params.chromhigh(1:2),[0;0]);
					stimtype_type = 1+eqlen(params.imageType,0);
					newtestdirname = [replace_prefix color{color_type} stimtype{stimtype_type} int2str(n)];
					testdirinfo(t).types = newtestdirname;
				end;
			end;
		end;
	end;
end;

disp(['Now re-writing testdirinfo.txt file.']);
delete([getpathname(ds) filesep 'testdirinfo.txt']);
saveStructArray([getpathname(ds) filesep 'testdirinfo.txt'], testdirinfo);

if docells,
	disp(['Now saving cells back to disk.']);

	 % Step 3, save back to disk
	saveexpvar(ds,cells,cellnames,0);
end;
