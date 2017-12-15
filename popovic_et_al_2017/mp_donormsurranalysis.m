function [cellinfo,cells,cellnames] = mp_donormsurranalysis(prefix,expernames)
% MP_DONORMSURRANALYSIS - perform analysis for MP's normalization/surround experiments
%
%  [CELLINFO,CELLS,CELLNAMES] = MP_DONORMSURRANALYSIS(PREFIX,EXPERMAMES)
%
%  Load several pieces of information about responses from cells.
%
%  PREFIX is the directory to examine. If it is not provided, 
%  '/Volumes/Data3/marjenap/' is assumed
%
%  EXPERNAMES is the list of experiments to be examined. If not given, then
%  Marjena's experiments for Popovic et al. 2017 are assumed.
%
%  See the code for the experiment days.
% 

if nargin==0,
	prefix = '/Volumes/van-hooser-lab/Users/marjenap/data3/';
end;

expernames = { '2015-07-22','2015-08-24','2015-08-26','2015-09-16','2015-10-12','2015-12-07','2015-12-10',...
		'2016-01-27','2016-02-08','2016-02-10','2016-02-22','2016-02-24','2016-03-02', ...
		'p60ish/2015-11-19','p60ish/2015-12-03','p60ish/2016-03-31', 'p60ish/2016-04-04', '2016-03-07','2016-03-09' , ...
		'2016-03-23','2016-04-14','2016-04-25', '2016-04-28','2016-05-16','2016-05-23','2016-05-26','2016-06-13','2016-06-15','2016-06-22'}; 
%,'2015-08-24','2015-08-26','2015-09-16',} % for later

[cells,cellnames,experind]=readcellsfromexperimentlist(prefix,expernames,1,10);

cellinfo = [];

prev_date = '';

for i=1:length(cells),
	% experiment date/index info
	cellinfo(i).experind = experind(i);
	cellinfo(i).experdate = expernames{experind(i)};
	cellinfo(i).prefix = prefix;

	if ~strcmp(prev_date,cellinfo(i).experdate),
		ds = dirstruct([prefix filesep cellinfo(i).experdate]);
		prev_date = cellinfo(i).experdate;
	end;

	% get rearing/training info
	A = findassociate(cells{i},'Rearing','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have rearing info.']); end;
	cellinfo(i).rearing = lower(A.data); % use lower case
	A = findassociate(cells{i},'Training type','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have training info.']); end;
	cellinfo(i).training_type = lower(A.data); % use lower case
	A = findassociate(cells{i},'Age group','','');
	if isempty(A), error(['Cell ' cellnames{i} ' does not have age group info.']); end;
	cellinfo(i).agegroup = A.data;

	cellinfo(i).length_info = mp_getlengthtuningcell(cells{i},cellnames{i},'ds',ds);
	cellinfo(i).lengthfit = mp_lengthfit(cellinfo(i),cellnames{i});
	cellinfo(i).ori_info = extract_oridir_indexes_struct(cells{i});
	cellinfo(i).sf_info = extract_spatial_frequency_test(cells{i},'SP F0','');
	cellinfo(i).tf_info = extract_temporal_frequency_test(cells{i},'SP F0','');
	cellinfo(i).plaid = mp_getnormalizationtuningcell(cells{i},cellnames{i});
	cellinfo(i).surrori_info = extract_oridir_indexes_struct(cells{i},'ColorType','SUR Ach');

	[f1f0,rmg,c50,si,sig_ct,response_curve,blank] = extract_contrast_indexes(cells{i});
	cellinfo(i).contrast_info = var2struct('f1f0','rmg','c50','si','sig_ct','response_curve','blank');

	disp(['Done with ' int2str(i) ' of ' int2str(length(cells)) '...']);
end;

