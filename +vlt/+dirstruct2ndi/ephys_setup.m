function ephys_setup(pathname, channel_list)
% EPHYS_SETUP - this sets up ephys data from 2008 - 2017
%
%
%
%

 % for Van Hooser et al. 2013, channel_list = [11 12 13 14]

  
ds = dirstruct(pathname);

nr = getallnamerefs(ds);

for n = 1:numel(nr),
	TT = gettests(ds,nr(n).name,nr(n).ref)
	for t = 1:numel(TT),
		fname = [pathname filesep TT{t} filesep 'vhspike2_channelgrouping.txt']
		fname2 = [pathname filesep TT{t} filesep 'reference.txt']
		fname3 = [pathname filesep TT{t} filesep 'verticalblanking.txt']
		struct_here = struct('name',nr(n).name,'ref',nr(n).ref,'channel_list',channel_list)
		saveStructArray(fname, struct_here);
		ref_struct = struct('name',nr(n).name,'ref',nr(n).ref,'type','n-trode');
		saveStructArray(fname2,ref_struct);
		if ~isfile(fname3),
			vlt.file.cellstr2text(fname3,{' '});
		end;
		
	end;
end;

