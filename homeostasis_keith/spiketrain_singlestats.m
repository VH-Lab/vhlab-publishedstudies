function [output] = spiketrain_singlestats(cellstruct, varargin)
% SPIKETRAIN_SINGLESTATS - Calculate interspikeintervals and powerspectrum from Keith's cell data
%
% OUTPUT = SPIKETRAIN_SINGLESTATS(CELLSTRUCT, ...)
%
%  Calculates the interspikeinterval distribution and powerspectrum 
%  for a neuron with spike information in CELLSTRUCT.
%
%  It is assumed that CELLSTRUCT has the following fields:
%  Field name:           | Description
%  ----------------------------------------------------------
%  times                 | Spike times in seconds
%  activeWake            | Cell array of spiketimes in every
%                        |   activeWake period
%  quietWake             | Cell array of spiketimes in every
%                        |   quiteWake period
%  sleep                 | Cell array of spiketimes in every 
%                        |   sleeping period
%
%  At this time, the onset and offset of each behavioral period
%  (activeWake, quietWake, and sleep) will be determined by the
%  first and last spike in each epoch.
%
%  OUTPUT is a cell structure with the following fields:
%  Field name:           | Description
%  -----------------------------------------------------------
%  BEHAVE_STATES         | Cell list of strings of behavioral states
%  ISI_bins              | Bin centers for interspikeinterval distribution
%  ISI                   | Cell list of counts in ISI_bins for interspike interval for
%                        |    each behavioral state in BEHAVE_STATES.
%  F                     | Frequencies in the power spectrum
%  Pxx                   | Cell list with average power spectrum for each
%                             behavioral state in BEHAVE_STATES.
%  bands                 | Matrix of power bands for constructing average bandwidths
%                             Each row indicates the start and stop for each band.
%  band_values           | Cell list with power in each band for each BEHAVE_STATE
%  autocorr              | Autocorrelation
%  autocorr_lags         | The autocorrelation lags
%    
%  
%  It is also possible to modify the parameters of the function by
%  passing name/value pairs as extra arguments.  For example:
%    OUTPUT = SPIKETRAIN_SINGLESTATS(CELLSTRUCT, 'WINDOWSIZE',30)
%  changes the sliding window size to 30 seconds.
%  Field name (default): | Description
%  -----------------------------------------------------------
%  WINDOWSIZE (30)       | Sliding window size for power spectrum
%                        |   computation (seconds)
%  WINDOWSTEP (15)       | Sliding window step size for power spectrum
%  BINSIZE (0.002)       | Spike bin size for power spectrum (seconds)
%  BEHAVE_STATES (...    | Names of behavioral states (cell list of 
%   {'activeWake',...    |   strings)
%    'quietWake' ,...    |
%    'sleep'}            |
%  ISI_bins (0:0.005:1)  | Interspike interval bins for computing interspike
%                        |   interval distribution 
%  bands = [0.1 4;       | Frequency bands to analyze [band1_start; band1stop; ...]
%      4 8;              |
%      8 12;             | 
%      12 30]            |   
%  MAXLAG (0.050)        | Max lag for computing autocorrelation
%  AUTOCORR_BIN (0.002)  | Autocorrelation bin size
%  
%  See also:  INTERSPIKEINTERVAL, SPIKETRAIN_POWERSPECTRUM
%
%
 % default parameter values

WINDOWSIZE = 30;
WINDOWSTEP = 15;
BINSIZE = 0.002;
BEHAVE_STATES = {'activeWake','quietWake','sleep'};
ISI_bins = -0.00:0.005:1;
bands = [ 0.1 4; 4 8; 8 12; 12 30];
MAXLAG = 0.050;
AUTOCORR_BIN = 0.002;


assign(varargin{:});

for b=1:length(BEHAVE_STATES),
	ISI{b} = zeros(size(ISI_bins));
	autocorr{b} = zeros(size(round(-MAXLAG/AUTOCORR_BIN):round(MAXLAG/AUTOCORR_BIN)));
	% this is a cell list of spiketimes
	spiketimes = getfield(cellstruct,BEHAVE_STATES{b});
	Pxx{b} = [];
	bandvalues{b} = [];
	disp(['Now working on BEHAVE_STATE ' BEHAVE_STATES{b} ]);
	for j=1:length(spiketimes), % for each entry in cell list

		% interspikeinterval
		
		spiketimes_here = spiketimes{j};
		ISI{b} = ISI{b} + interspikeinterval(spiketimes_here, ISI_bins);
		[autocorr_here,autocorr_lags] = spiketimes_correlation(spiketimes_here,spiketimes_here,...
			AUTOCORR_BIN, MAXLAG);
		autocorr{b} = autocorr{b} + autocorr_here;

		% powerspectrum

		start = min(spiketimes_here); % use spike times as a proxy for this info
		stop = max(spiketimes_here);  % use spike times as a proxy for this info
		[Pxx_here, F, bandvalues_here] = spiketrain_powerspectrum_window(spiketimes_here, ...
			[start WINDOWSIZE WINDOWSTEP stop], 'bands',bands,'BINSIZE', BINSIZE);
		Pxx{b}(:,j) = Pxx_here(:);
		bandvalues{b} = [bandvalues{b} bandvalues_here];
	end;
	ISI{b} = ISI{b} / sum(ISI{b}); % normalize to probabilities
	Pxx{b} = mean(Pxx{b}');
end;

clear b j cellstruct spiketimes_here spiketimes start stop Pxx_here bandvalues_here autocorr_here

output = workspace2struct; % save all variables

