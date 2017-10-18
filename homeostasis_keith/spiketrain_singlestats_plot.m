function spiketrain_singlestats_plot(output)
% SPIKETRAIN_SINGLESTATS_PLOT - Plot the results of SPIKETRAIN_SINGLESTATS
%
%   SPIKETRAIN_SINGLESTATS_PLOT(OUTPUT)
%
%  Plots the output of SPIKETRAIN_SINGLESTATS to a new figure window.
%  
%  See also: SPIKETRAIN_SINGLESTATS

figure;
subplot(2,1,1);
plot(output.F,output.Pxx{1},'k');
hold on;
plot(output.F,output.Pxx{2},'r');
plot(output.F,output.Pxx{3},'b');
legend(output.BEHAVE_STATES{:});
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
box off;

subplot(2,1,2);
plot(output.ISI_bins+mean(diff(output.ISI_bins))/2,output.ISI{1},'k');
hold on;
plot(output.ISI_bins+mean(diff(output.ISI_bins))/2,output.ISI{2},'r');
plot(output.ISI_bins+mean(diff(output.ISI_bins))/2,output.ISI{3},'b');
legend(output.BEHAVE_STATES{:});
xlabel('Interspikeinterval (seconds)');
ylabel('Fraction of spikes');
box off;

