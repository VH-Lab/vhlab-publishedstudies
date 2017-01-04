
% part 1: without limiting synapses, you don't get strong direction selectivity

GsynAP_20 = 0.00000000713888861239;

% part 2: with limiting synapses and with non-overlapping inputs, you don't get strong direction selectivity
%   synapses are limited so that the 

% part 3: with overlapping input, how much learning takes place?

% 3.1) we need to begin each simulation with initial conditions that cause 1 spike in both directions

% tau_syn is 0.020, explore different lags; no need to go below 0.020 since that's the synapatic time constant

 % what is minimum input that gives 1 spike for optimal lag for 5x5 network?

lag_list = [ 0.200 0.150 0.100 0.050 0.025 ];
GsynAP_list = [];

re_run_GsynAP = 0;

if re_run_GsynAP,
	for i=1:length(lag_list),
		duration = lag_list(i) + 5*lag_list(i) + 5*lag_list(i);
		GsynAP_list(i) = directionselectivityNcell_GsynAP([0 10e-9 30],[5 5],[1],[],[0],'N',5,'R',5,'isi',duration,'latency',lag_list(i),'lag',lag_list(i),...
			'synapseparams',{'tau2',0.020});
		i,
		sprintf('%5.20f',GsynAP_list(i))
	end;
else,
	GsynAP_list(1) = 0.0000000014276746;
	GsynAP_list(2) = 0.000000001426525;
	GsynAP_list(3) = 0.0000000014127756;
	GsynAP_list(4) = 0.00000000126236097275;
	GsynAP_list(5) = 0.00000000094088639477;

	%load('sl_GsynAPdirectionselectivityNcell.mat');
end;

% 3.2 now, search for the Gmax that such that when all of those synapses are strengthened, we get exactly 2 spikes in the non-preferred direction

GsynMax_list = [];

re_run_GsynMax = 0;

if re_run_GsynMax,
	for i=1:length(lag_list),
		duration = lag_list(i) + 5*lag_list(i) + 5*lag_list(i);
		T = triu(ones(5,5));
		T2 = T(:,end:-1:1);
		GsynMax_list(i) = directionselectivityNcell_GsynAP([0 10e-9 30],[5 5],[2],[T2],[1],'N',5,'R',5,'isi',duration,'latency',lag_list(i),'lag',lag_list(i),...
			'synapseparams',{'tau2',0.020});
		sprintf('%5.20f',GsynMax_list(i))
	end;
else,
	% resolution: 50 binary search steps
	GsynMax_list(1) = 0.00000000321804543583;
	GsynMax_list(2) = 0.00000000321342579738;
	GsynMax_list(3) = 0.00000000318991965878;
	GsynMax_list(4) = 0.00000000287477551408;
	GsynMax_list(5) = 0.0000000018524888;

end;


