function r = train_Bsequences(sequence, numtrials, filename,kernel,plotit,maxweight)
% SL_BSEQUENCES - compute responses of model to Arani's Bsequences
%
% TRAIN_BSEQUENCES(SEQUENCE_NUMBER, NUMTRIALS, FILENAME, KERNEL, PLOTIT,...
%     MAXWEIGHT)
%
%  Inputs:
%   SEQUENCE_NUMBER - The sequence number to use for training (1..12)
%   NUMTRIALS - the number of trials to use for training (try 100 to start)
%   FILENAME - the filename to use to save the output
%   Kernel - The initial to use; e.g. 0.64e-9*ones(8,8) for flat,
%            or A = eye(8);
%               Kernel = 2e-9*(A+A(end:-1:1,:)); % this is too strong probably
%               for an 'X'
%   PLOTIT - Plot each run? useful for finding a decent parameter range at the beginning
%    of work
%   MAXWEIGHT max weight synapses can take e.g., 3e-9
%

load B_sequences

sl_limitsHebbianfig;

w = kernel;
	
out=directionselectivityNcell_learning2('isi',0.025*(8),'N',8,'R',8,...
	'trials',numtrials,...
	'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},...
	'Gmax_initial',reshape(w,1,64),...
	'Gmax_initial_inhib',1.001*GsynAP_list(5)*ones(1,64),...
	'phase',B_sequences(sequence,:),...
	'classic_stdp',1,'Gmax_max',maxweight,'dt',1e-3,...
	'ISyn_change',1.01,'unidir',1,'ISyn_Gmax_initial',0.1e-9,...
	'ISyn_Max',0*4.343e-9,'nreps',1,'plotit',1);

save(filename,'-mat');
