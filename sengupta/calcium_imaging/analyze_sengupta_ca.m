function [output] = analyze_sengupta_ca(filename)
% ANALYZE_SENGUPTA_CA - Analyze the Sengupta lab calcium transients
%
%  OUTPUT = ANALYZE_SENGUPTA_CA(FILENAME)
%
%  Input: Filename should be the name of a .mat file with variables 
%  'events' that describe the conditions under which calcium imaging
%  occurred. Events should have a field 'BLC_raw_delta_F' which corresponds
%  to the deltaF/F measured.
%
%  The function performs several calculation. 1) It calculates the
%  Fourier transform of the DF/F signal for each cell. The average
%  fourier transform is plotted in a linear plot and a log-log plot.
%  2) It detects 'events' that are defined as transitions from 
%  below threshold (4 dF/F) to above threshold. A refractory period is
%  imposed so that that events cannot occur more frequently than 3 seconds.
%  The event rate (events per unit time) and inter-interval times (average
%  interval between events) are also calculated and plotted.
%
%  The sampling rate is assumed to be 2Hz.
%
%  Output:  'output' is a structure with the following fields:
%  field:                 | Description                       
%  ------------------------------------------------------------------
%  fft_freq               | Frequencies represented in the FFT
%  fft                    | Fourier transform for each cell (one row per cell)
%  dFFnorm                | Normalized DF/F (one row per cell, max is 1)
%  dFFraw                 | Raw DF/F (one row per cell)
%  eventtimes             | List of event times for each cell. One cell element for each cell.
%  eventrate              | The rate of events (one entry per cell)
%  inter_event_interval   | The average interval between events (one entry per cell, NaN is used for
%                         |     cells that have 1 event or fewer)
%  t                      | The time of each DF/F sample from the beginning of recording (seconds)
%  

  % constant parameters
threshold = 4; % threshold for event detection
refractory_period = 3; % in seconds
sample_rate = 2; % 2 Hz
sample_interval = 1/sample_rate; 


z = load(filename);

output.fft_freq = [];
output.fft = [];
output.dFFnorm = [];
output.dFFraw = [];
output.eventtimes = {};
output.eventrate = [];
output.inter_event_interval = [];

output.t = 0:sample_interval:sample_interval*(numel(z.events(1).BLC_raw_delta_F)-1);

fft_valid = 1:floor(length(output.t)/2);

for i=1:length(z.events),
	event_samples = find(z.events(i).BLC_raw_delta_F(1:end-1)<threshold & z.events(i).BLC_raw_delta_F(2:end)>=threshold);
	output.eventtimes{i} = refractory(output.t(event_samples),refractory_period); 
	output.eventrate(i) = length(output.eventtimes{i}) / (output.t(end)-output.t(1));
	output.inter_event_interval(i) = mean(diff(output.eventtimes{i})); 
	output.dFFraw(i,:)=z.events(i).BLC_raw_delta_F(:)'; % make sure it's a row
	output.dFFnorm(i,:) = output.dFFraw(i,:) / max(output.dFFraw(i,:)); % normalize, assuming absolute values are not important
	[output.fft(i,:),output.fft_freq] = fouriercoeffs(output.dFFnorm(i,:),sample_interval);
end;

output.absfft = abs(output.fft);

figure;

subplot(2,2,1);
plot(output.fft_freq(fft_valid),mean(output.absfft(:,fft_valid)));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
box off;
title(['Fourier transform of raw dF/F']);

subplot(2,2,2);
loglog(output.fft_freq(fft_valid),mean(output.absfft(:,fft_valid)))
xlabel('Frequency (Hz)');
ylabel('Amplitude');
box off;
title(['Fourier transform of raw dF/F']);

subplot(2,2,3);
hist(output.eventrate);
xlabel('Event rates');
ylabel('Counts');
box off;
title(['Histogram of event rates (Hz)']);

subplot(2,2,4);
hist(output.inter_event_interval);
xlabel('Inter-event intervals');
ylabel('Counts');
box off;
title(['Histogram of event intervals (s)']);

