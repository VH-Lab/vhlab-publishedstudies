function [out] = araniwes_vmnospikes_rc(dirname, varargin)
% ARANIWES_VMNOSPIKES_RC - Retrieve membrane potential with spikes removed and perform reverse correlation, ARANI/WES data
%
%  [OUT] = ARANIWES_VMNOSPIKES_RC(DIRNAME, ...)
%
%  Inputs: DIRNAME the directory name of the 't0000X' directory (full path)
%          We assume that a file 'data.mat' exists that has an exported version of the 
%          Spike2 data
%          We assume further that either BLINKINGSTIM or STOCHASTICGRIDSTIM was shown in that directory
%  Outputs:
%          The output OUT is a structure with fields:
%             vm - the membrane voltage
%             t - the time values of the membrane voltage (in Spike2 units)
%             spiketimes - the spike times
%             vm_rev_corr - a structure with reverse-correlation parameters from voltage
%                rev_corr - the linear filter derived after removing the autocorrelation function of the stimulus 
%                           This 3D matrix has 1 entry (in 3rd dimension) per stimulus presentation
%                xc_stimsignal - the raw reverse correlation of the stimulus with the voltage signal
%                           This 3D matrix has 1 entry (in 3rd dimension) per stimulus presentation
%                avg_revcorr - the average linear filter derived after removing the autocorrelation function of the stimulus
%                           (Averaged over every stim presentation)
%                avg_xcstimsignal - The average raw reverse correlation of the stimulus with the voltage signal
%                           (Averaged over every stim presentation)
%                avg_xc_deconvolved - The avg_xcstimsignal, deconvolved with the autocorrelation function of the stimulus
%                        This can be less noisy than avg_revcorr 
%                gridsize - the grid size used for stimulation
%
%
%  The outputs are also saved to the file 'araniwes_output.mat' in DIRNAME.
%
%
%   The function can be modified by parameters expressed in name/value pairs:
%   Parameter (default value)     | Description
%   ---------------------------------------------------------------------------------------
%   thresh ([])                   | The spike threshold to apply, in millivolts (e.g., -0.020).
%                                 |   If empty, it will be read from the file 'araniwes_threshold.mat'.
%                                 |   If the file does not exist, the data will be plotted and the user
%                                 |   will be prompted to pick a value graphically.
%   newsi (0.001)                 | The new sampling interval (e.g., 0.005 for 5ms)
%   amp (10)                      | AMP amplification that was applied to the data (usually 10)
%   tau0 (-0.100)                 | The correlation time window early edge (e.g., -0.1 for 100ms before)
%   tau1 (0.5)                    | The correlation time window late edge (e.g., 1 for 1000ms after)
%   chanlabel ('spike2data_Ch21') | The field to read from 'data.mat', the exported spike2 data
%   plotit (0)                    | Plot the reverse correlations

thresh = [];
newsi = 0.001;
amp = 10;
tau0 = -0.1;
tau1 = 0.5;
chanlabel = 'spike2data_Ch21';
plotit = 0;

vlt.data.assign(varargin{:});

thresh_filename = 'araniwes_threshold.mat';
output_filename = 'araniwes_output.mat';
input_parameters = vlt.data.var2struct('thresh','tau0','tau1','newsi','amp');

d = load([dirname filesep 'data.mat']);
chdata = getfield(d,chanlabel); 

if isempty(thresh),
	try,
		thfile = load([dirname filesep thresh_filename],'-mat');
		thresh = thfile.thresh;
	catch,
		f=figure;
		plot(0:chdata.interval:chdata.interval*(length(chdata.values)-1),chdata.values/amp);
		title(['Click a Y location to choose a threshold']);
		drawnow;
		[x,thresh] = ginput(1);
		close(f);
		save([dirname filesep thresh_filename],'thresh','-mat');
		drawnow;
	end;
end;

[vm,t,spiketimes] = vlt.neuro.membrane.vmnospikes(chdata.values/amp, chdata.interval,'Tstart',chdata.start,...
		'newsi',newsi,'thresh',thresh,'filter_algorithm','medfilt1');

[ds_pathname,directoryname] = fileparts(dirname);
ds = dirstruct(ds_pathname);

vm_rev_corr = vm_rc(ds,directoryname,vm,t,'mnt',tau0,'mt',tau1,'step',newsi);
sp_rev_corr = spiketimes_rc(ds,directoryname,spiketimes,'mnt',tau0,'mt',tau1,'step',newsi);

if plotit,
	rc_plot(vm_rev_corr);
	rc_plot(sp_rev_corr);
end;

out = vlt.data.var2struct('vm','t','spiketimes','vm_rev_corr','sp_rev_corr');

save([dirname filesep output_filename],'out','-mat');


