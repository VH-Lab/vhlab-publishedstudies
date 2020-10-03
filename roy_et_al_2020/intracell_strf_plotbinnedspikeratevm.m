function [firingrate_observations, voltage_observations, timepoints] = intracell_strf_plotbinnedspikeratevm(app, sharpprobe, stimprobe, varargin)
% INTRACELL_STRF_BINNEDSPIKERATEVM - compute binned spike rate, vm
%
% [FR, V, TIMEPOINTS] = INTRACELL_STRF_BINNEDSPIKERATEVM(PROBE, ...)
%
% Does NOT open new figure.
% 
% This function also takes parameters as name/value pairs that modify its behavior.
% Parameter (default)        | Description
% --------------------------------------------------------------
% epochid ([])               | epochid to plot. If empty, loops over all epochids.
%

epochid = [];

vlt.data.assign(varargin{:});

firingrate_observations = [];
voltage_observations = [];
timepoints = [];

E = app.session;
iapp = ndi.app(E,'vhlab_voltage2firingrate');

if isempty(epochid),
	et = epochtable(sharpprobe);
	N = numel(et);
	for n=1:N,
		[fr,v,timepoints]=intracell_strf_plotbinnedspikeratevm(app,sharpprobe,...
			stimprobe,'epochid',et(n).epoch_id,varargin{:});
	end;
	return;
end;

mydoc =E.database_search(ndi.query('','isa','binnedspikeratevm.json','') & ...
	ndi.query('epochid','exact_string',epochid,'') & ndi.query('','depends_on','element_id',sharpprobe.id()));

if numel(mydoc)>1, error(['More than a single match.']); end; 

if numel(mydoc)==0, return; end;

mydoc = vlt.data.celloritem(mydoc,1);

vlt.data.struct2var(mydoc.document_properties.binnedspikeratevm);

plot(voltage_observations, firingrate_observations,'bo');
xlabel('Voltage (Vm-rest)');
ylabel('Firing rate (spikes/sec)');
title('V - Fr');

Yn = [];
Xn = [];
Yint = [];

if ~isempty(firingrate_observations),
	[Yn,Xn,Yint] = vlt.math.slidingwindowfunc(voltage_observations, firingrate_observations, ...
		min(voltage_observations), 0.001, max(voltage_observations), 0.002, 'mean',0);
	[Nn] = vlt.math.slidingwindowfunc(voltage_observations, firingrate_observations, ...
		min(voltage_observations), 0.001, max(voltage_observations), 0.002, 'numel',0);

	hold on
	h=vlt.plot.myerrorbar(Xn,Yn,Yint,Yint,'r');
	set(h,'linewidth',2);
end

thetitle = get(get(gca,'title'),'string');
thetitle = { [sharpprobe.elementstring() '@' epochid], thetitle};
title(thetitle);

box off;

