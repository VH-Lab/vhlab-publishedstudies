function intracell_strf_format_all(filename, prefix)
% INTRACELL_STRF_FORMAT_ALL - use the index file to properly format all intracellular recording sessions from Arani
%
% INTRACELL_STRF_FORMAT_ALL(FILENAME, PREFIX)
%
% FILENAME is a tab-delimited file with fields 'Date' (indicating session date), 'cellNo' (indicating cell number),
% 'tuningCurve' (indicating the t folders to use for tuning curve data), 'revCorr' (indicating the t folders to use for reverse correlation data)
%
% Calls INTRACELL_STRF_FORMAT_EXP_DIR for each session.
%
% By default, PREFIX is '/Volumes/van-hooser-lab/Users/steve/araniintracellular/'

if nargin<2,
	prefix = '/Volumes/van-hooser-lab/Users/steve/araniintracellular/';
end

z = loadStructArray(filename);

for i=1:numel(z),
	expdatenum = datenum(z(i).Date);
	expname = datestr(expdatenum,'yyyy-mm-dd');

	tfolders_here = {};

	if ~isnan(z(i).tuningCurve),
		tfoldernum = sscanf(z(i).tuningCurve,'t%d');
		tfolders_here = cat(1,tfolders_here,sprintf(['t%.5d'],tfoldernum));
	end

	if ~isnan(z(i).revCorr),
		tfoldernum = sscanf(z(i).revCorr,'t%d');
		tfolders_here = cat(1,tfolders_here,sprintf(['t%.5d'],tfoldernum));
	end

	disp(['Info for session ' int2str(i) ': expname is ' expname ', cellNo is ' int2str(z(i).cellNo) ' and tfolders are ' cell2str(tfolders_here) '.']);

	if 1,
		intracell_strf_format_exp_dir([prefix filesep expname], z(i).spike2channel, z(i).cellNo, tfolders_here);
	end

end


