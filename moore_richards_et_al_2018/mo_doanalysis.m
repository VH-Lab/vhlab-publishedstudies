function [cellinfo,cells,cellnames] = mo_doanalysis(prefix)
% MO_DOANALYSIS - perform analysis for SR's mouse phys experiments
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
	prefix = '/Volumes/Data2/Columbia_mice/';
end;

expernames = { '2016-02-09', '2016-02-23', '2016-03-18', '2016-07-06', '2016-07-07', '2016-07-11', '2016-07-13', '2016-07-15'};
		
	


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

	cellinfo(i).ori_info = extract_oridir_indexes_struct(cells{i});
	cellinfo(i).sf_info = extract_spatial_frequency_test(cells{i},'SP F0','');
	cellinfo(i).tf_info = extract_temporal_frequency_test(cells{i},'SP F0','');

	[f1f0,rmg,c50,si,sig_ct,response_curve,blank] = extract_contrast_indexes(cells{i});
	cellinfo(i).contrast_info = var2struct('f1f0','rmg','c50','si','sig_ct','response_curve','blank');

	disp(['Done with ' int2str(i) ' of ' int2str(length(cells)) '...']);
end;

