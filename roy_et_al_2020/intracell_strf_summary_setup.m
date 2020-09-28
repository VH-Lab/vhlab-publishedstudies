function [isstudy] = intracell_strf_summary_setup(prefix)

fy = '~/tools/matlab/vhlab-intracellrfs-matlab/intracellular data index - young.tsv';

fo = '~/tools/matlab/vhlab-intracellrfs-matlab/intracellular data index - old.tsv';

zy = vlt.file.loadStructArray(fy);
zo = vlt.file.loadStructArray(fo);

expnames_young = {};
expnames_old = {};

for i=1:numel(zy),
        expnames_young{i} = datestr( datenum(zy(i).Date), 'yyyy-mm-dd');
end

for i=1:numel(zo),
        expnames_old{i} = datestr( datenum(zo(i).Date), 'yyyy-mm-dd');
end;

expnames_young = unique(expnames_young);
expnames_old = unique(expnames_old);

isstudy = vlt.data.emptystruct('prefix','expername','young','E');

E_young = {};
E_old = {};

for i=1:numel(expnames_young),
	E_young{i} = ndi_session_dir([prefix filesep expnames_young{i}]);
	isstudy(end+1) = struct('prefix',prefix,'expername',expnames_young{i},'young',1,'E',E_young{i});
end;

for i=1:numel(expnames_old),
	E_old{i} = ndi_session_dir([prefix filesep expnames_old{i}]);
	isstudy(end+1) = struct('prefix',prefix,'expername',expnames_old{i},'young',0,'E',E_old{i});
end;


