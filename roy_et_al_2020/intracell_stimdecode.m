function [fr, v, timepoints] = intracell_stimdecode(app, stimprobe, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_EXAMINE_VM_SPIKE_MODEL(PROBE, ...)
%
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% displayresults (1)         | Display the results (0/1)
%

displayresults = 1;

assign(varargin{:});

E = app.session; 

sapp = ndi_app_stimulus_decoder(E);
[docs,edocs] = sapp.parse_stimuli(stimprobe,1);

rapp = ndi_app_tuning_response(E);
rapp.label_control_stimuli(stimprobe,1);

