function table = readchr2positionstimdata2(ds, cell, cellname, varargin)
% READCHR2POSITIONSTIMDATA - Read projector position stim data into a table
%
%  TABLE = READCHR2POSITIONSTIMDATA2(DS, CELL, CELLNAME)
%
%  Loops through all of the stimuli that were shown to cell CELL and tries to find
%  those that have 'xposition' and 'yposition' as parameters that vary.
%  
%  Input: 
%     DS - a directory structure (see help DIRSTRUCT)
%     CELL - A spikedata object 
%     CELLNAME - The name of the cell
%  Output:
%     TABLE; each column contains a different stimulus entry.
%     The columns are, respectively, Xposition, Yposition, radius, individual responses
%

verbose = 0;
assign(varargin{:});

table = [];

[nameref,index,datrstr] = cellname2nameref(cellname);

T = gettests(ds,nameref.name,nameref.ref);

inds = [];

for t=1:length(T),
	hasPosStimData = 0;
	% check each directory to see if it has position stim data in it
	dirname = [getpathname(ds) filesep T{t}];
	try,
		stims = load([dirname filesep 'stims.mat']);
		varies = sswhatvaries(stims.saveScript);
		stimtype = class(get(stims.saveScript,1));
		hasPosStimData = strcmp(stimtype,'centersurroundstim') && ~isempty(intersect(varies,{'xposition','yposition'}));
	catch,
		if verbose, disp(['No stims.mat file found in ' dirname '.']); end;
	end;

	if hasPosStimData,

		inds(end+1) = t;

	end;
end;

T = T(inds),

for t=1:length(T),

	table_entry = [];

	dirname = [getpathname(ds) filesep T{t}];

	stims = load([dirname filesep 'stims.mat']);
	[mti2_,starttime_] = tpcorrectmti(stims.MTI2,[dirname filesep 'stimtimes.txt'],1);

	do = getDisplayOrder(stims.saveScript);

	for n=1:numStims(stims.saveScript),
		stim_index = find(do==n);
		mystim = get(stims.saveScript,n);
		parameters = getparameters(mystim);
        if ~isfield(parameters,'isblank'),
            table_entry(1) = parameters.xposition;
            table_entry(2) = parameters.yposition;
            table_entry(3) = parameters.radius;

            spike_counts = [];

            for i=1:length(stim_index),
                light_on = mti2_{stim_index(i)}.startStopTimes(2);
                light_off = mti2_{stim_index(i)}.startStopTimes(3)+0.030;
                spike_counts(end+1) = length ( get_data(cell,[light_on light_off]) );
            end;

            table_entry(4,4+length(spike_counts)) = spike_counts(:)';

            table(end+1,:) = table_entry(:)';
        end;
	end;
end;


