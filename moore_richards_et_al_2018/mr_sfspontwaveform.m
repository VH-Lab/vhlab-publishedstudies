function [t,wv] = mr_sfspontwaveform(cellinfo, cell, cellnames, prefix)
% MR_SFSPONTWAVEFORM - return a spontaneous voltage waveform
%
% MR_SFSPONTWAVEFORM(CELL, CELLNAMES, PREFIX)
%
% 

ds = dirstruct([prefix filesep cellinfo.experdate]);

SF = findassociate(cell, 'SpatFreq test','','');

[stimids, stimtimes, frametimes] = read_stimtimes_txt([getpathname(ds) filesep SF.data]);
blankstim = max(stimids); % assumption but should be true for this study

rhdfile = dir([getpathname(ds) filesep SF.data filesep '*.rhd']);
rhdfile = rhdfile(1).name;


stimspacing = median(diff(stimtimes));

artificial_spacing = 1+stimspacing;

if 0,
raw_data = read_Intan_RHD2000_datafile([getpathname(ds) filesep SF.data filesep rhdfile],...
	[],'amp',1,0,Inf);
raw_time = read_Intan_RHD2000_datafile([getpathname(ds) filesep SF.data filesep rhdfile],...
	[],'time',1,0,Inf);
end

[Bf,Af] = cheby1(4,0.8,[300/(25000*0.5)],'high');
%[raw_data] = filtfilt(Bf,Af,raw_data);

[shift,scale] = vhintan_sync2spike2([getpathname(ds) filesep SF.data]);

B = find(stimids==blankstim);

wv = [];
t = [];

channel = 1;

for b=1:numel(B),
	t0_spike2 = stimtimes(B(b));
	t1_spike2 = t0_spike2 + stimspacing;
	t0_intan = (t0_spike2 - shift)/scale;
	t1_intan = (t1_spike2 - shift)/scale;

	%s0 = findclosest(raw_time, t0_intan);
	%s1 = findclosest(raw_time, t1_intan);
	
	%wv_here = raw_data(s0:s1);
	wv_here= read_Intan_RHD2000_datafile([getpathname(ds) filesep SF.data filesep rhdfile],...
		[],'amp',1,t0_intan-1,t1_intan+1);
	wv_here = filtfilt(Bf,Af,wv_here);
	t_here = read_Intan_RHD2000_datafile([getpathname(ds) filesep SF.data filesep rhdfile],...
		[],'time',1,t0_intan-1,t1_intan+1);

	s0 = findclosest(t_here,t0_intan);
	s1 = findclosest(t_here,t1_intan);
		
	wv_here = wv_here(s0:s1);
	t_here = t_here(s0:s1);

	t = [t; t_here(:)-t_here(1) + (b-1)*artificial_spacing;NaN];
	wv = [wv; wv_here(:); NaN];
end

