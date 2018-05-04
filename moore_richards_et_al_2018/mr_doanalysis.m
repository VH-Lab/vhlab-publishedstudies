function [cellinfo,cells,cellnames] = me_doanalysis(prefix)
% MR_DOANALYSIS - perform analysis for SR's mouse phys experiments
%
%  [CELLINFO,CELLS,CELLNAMES] = MO_DOANALYSIS(PREFIX)
%
%  Load several pieces of information about responses from cells.
%
%  PREFIX is the directory to examine. If it is not provided, 
%  '/Volumes/Data2/Columbia_mice/' is assumed
%
%  See the code for the experiment days.
% 

if nargin==0,
	prefix = '/Volumes/van-hooser-lab/Projects/Rem2Spontaneous/';
end;

expernames = { '3018-01-27', '4018-01-27', '5018-01-27', '3017-12-18', '4017-12-18', '5017-12-18' ,...
		'2018-02-12','2018-02-15','2018-03-02', ...
		'3018-02-12','3018-02-15', '3018-03-02',...
		'4018-02-12','4018-02-15',...
		'5018-02-12','5018-02-15',...
		'2018-03-16', '3018-03-16', ...
		'2018-03-17', '3018-03-17'};

[cells,cellnames,experind]=readcellsfromexperimentlist(prefix,expernames,1,10);

cellinfo = [];

prev_date = '';

for i=1:length(cells),
	% experiment date/index info
	cellinfo(i).experind = experind(i);
	cellinfo(i).experdate = expernames{experind(i)};

	if ~strcmp(prev_date,cellinfo(i).experdate),
		ds = dirstruct([prefix filesep cellinfo(i).experdate]);
		prev_date = cellinfo(i).experdate;
	end;

	% get rearing/training info
	A = findassociate(cells{i},'Rearing','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have rearing info.']); end;
	cellinfo(i).rearing = lower(A.data); % use lower case
	A = findassociate(cells{i},'Age group','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have age group info.']); end;
	cellinfo(i).agegroup = A.data;
	A = findassociate(cells{i},'Genotype','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have Genotype info.']); end;
	cellinfo(i).Genotype= A.data;
	A = findassociate(cells{i},'Animal ID','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have Animal ID.']); end;
	cellinfo(i).Animal_ID = A.data;

	cellinfo(i).ori_info = extract_oridir_indexes_struct(cells{i});
	cellinfo(i).sf_info = extract_spatial_frequency_test(cells{i},'SP F0','');
	cellinfo(i).tf_info = extract_temporal_frequency_test(cells{i},'SP F0','');

	[f1f0,rmg,c50,si,sig_ct,response_curve,blank] = extract_contrast_indexes(cells{i});
	cellinfo(i).contrast_info = var2struct('f1f0','rmg','c50','si','sig_ct','response_curve','blank');

	disp(['Done with ' int2str(i) ' of ' int2str(length(cells)) '...']);
end;

