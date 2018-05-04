function mr_redoanalysiswithstddevthreshold(prefix, expernames)
if nargin==0,
        prefix = '/Volumes/van-hooser-lab/Projects/Rem2Spontaneous/';
end;

%expernames = { '3018-01-27', '4018-01-27', '5018-01-27', '3017-12-18', '4017-12-18', '5017-12-18' ,...
%                '2018-02-12','2018-02-15','2018-03-02', ...
%                '3018-02-12','3018-02-15', '3018-03-02',...
%                '4018-02-12','4018-02-15',...
%                '5018-02-12','5018-02-15'};

expernames = { '3018-01-27', '4018-01-27', '5018-01-27', '3017-12-18', '4017-12-18', '5017-12-18' ,...
                '2018-02-12','2018-02-15','2018-03-02', ...
                '3018-02-12','3018-02-15', '3018-03-02',...
                '4018-02-12','4018-02-15',...
                '5018-02-12','5018-02-15'};

expernames = { '2018-03-16', '2018-03-17', '3018-03-16','3018-03-17'};

for i=1:numel(expernames),

	ds = dirstruct([prefix filesep expernames{i}]);

	vhintan_autothreshold_all(ds);

	% step 2 - extract all spikes
	T = getalltests(ds);

	for t=1:numel(T),
		vhintan_extractwaveforms([prefix filesep expernames{i} filesep T{t}],[-10 25],15,'MEDIAN_FILTER_ACROSS_CHANNELS',0);
	end

	nr = getallnamerefs(ds);

	for j=1:numel(nr),
		vhintan_clusternamerefauto(ds, nr(j).name, nr(j).ref);
	end
end

