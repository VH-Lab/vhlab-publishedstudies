function intracell_strf_format_exp_dir(dirname, spike2channel, varargin)
% INTRACELL_STRF_FORMAT_EXP_DIR - format an intracell directory with reference.txt set correctly
%
% INTRACELL_STRF_FORMAT_EXP_DIR(DIRNAME, CELL1_NUMBER, SPIKE2CHANNEL, CELLNUM1, {T folders1}, ...)
%
% Examines the session in DIRNAME, performing several jobs:
%  a) it examines all T folders for each CELL, and sets the reference.txt
%     reference entry to match the cell number.
%  b) it sets the reference.txt name entry to 'intra'
%  c) it sets the reference.txt type entry to 'sharp-Vm'
%  d) it sets the vhspike2_channelgrouping.txt file appropriately
%

 
ds = dirstruct(dirname);

alltfolders = getalltests(ds);

for i=1:2:numel(varargin),
	cellnum = varargin{i};
	t_folders = varargin{i+1};
	for j=1:numel(t_folders),
		tname = [dirname filesep t_folders{j}];
		if ~exist(tname,'dir'),
			error(['Could not find directory ' tname '.']);
		end
		reftxt = [tname filesep 'reference.txt'];
		if ~exist(reftxt,'file'),
			error(['No file ' reftxt '.']);
		end
		alltfolders = setdiff(alltfolders,t_folders{j});
		z = vlt.file.loadStructArray(reftxt);
		if numel(z)~=1,
			error(['Too many entries in ' reftxt ', do not know what to do.']);
		end
		z(1).ref = cellnum;
		z(1).name = 'intra';
		z(1).type = 'sharp-Vm';
		z,
		if 1,
			vlt.file.saveStructArray(reftxt, z);
		end
		channelgroupingtxt = [tname filesep 'vhspike2_channelgrouping.txt'];
		channelgroupingstruct = struct('name',z(1).name,'ref',z(1).ref,'channel_list',spike2channel);
		if 1,
			vlt.file.saveStructArray(channelgroupingtxt,channelgroupingstruct);
		end
	end
end;

disp(['Leftover t folders: ' vlt.data.cell2str(alltfolders) ])

