function neuter_empty_dirs(dirname, n, doit)
% NEUTER_EMPTY_DIRS - rename reference.txt files to reference0.txt in nearly empty folders
%
% NEUTER_EMPTY_DIRS(DIRNAME, N, DOIT)
%
% Given a DIRNAME that has a vhlab experiment in it, checks each directory to make sure
% it has at least N files. If not, then any reference.txt file is renamed to 
% reference0.txt so it is not considered an actual epoch of data.
% 
% If DOIT is 1, then the operation is carried out. If it is 0, then the function merely
% displays what it would do but does not actually neuter the directories.
%

arguments
	dirname (1,:) char
	n (1,1) double {mustBeInteger}
	doit (1,1) logical 
end

ds = dirstruct(dirname);

T = getalltests(ds);

for t=1:numel(T),
	D = dir(fullfile(dirname,T{t}));
	if numel(D) - 2 < n,
		disp(['Directory ' T{t} ' has fewer than ' int2str(n) ' files.']);
		if doit,
			neuter(ds,T{t});
		end;
	end;
end;


