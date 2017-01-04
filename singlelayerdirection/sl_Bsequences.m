function r = sl_Bsequences(filename, trial_to_use, plotit)
% SL_BSEQUENCES - compute responses of model to Arani's Bsequences
%
%   R = SL_BSEQUENCES(FILENAME,TRIAL_TO_USE)
%
%  FILENAME - filename with variable 'out'
%  TRIAL_TO_USE = the trial number of the model simulation to use
%  to base the weights
%  

load(filename); % has variable 'out'

load B_sequences

sl_limitsHebbianfig;

r = [];

if trial_to_use>0,
	w = reshape(out.gmaxes(:,trial_to_use),8,8);
elseif trial_to_use==-1,
	w = 0.64e-9*ones(8,8);
end;
	
for i=1:size(B_sequences,1),

	disp(['Now evaluating sequence ' mat2str(B_sequences(i,:)) '...']);

	o=directionselectivityNcell_learning2('isi',0.025*(8),'N',8,'R',8,...
	'trials',1,...
	'latency',0.025,'lag',0.025,'synapseparams',{'tau2',0.020},...
	'Gmax_initial',reshape(w,1,64),...
	'Gmax_initial_inhib',1.001*GsynAP_list(5)*ones(1,64),...
	'phase',B_sequences(i,:),...
	'classic_stdp',0,'Gmax_max',0.7*GsynMax_list(5),'dt',1e-3,...
	'ISyn_change',1.01,'unidir',1,'ISyn_Gmax_initial',0.1e-9,...
	'ISyn_Max',0*4.343e-9,'nreps',2,...
	'plotit',plotit,'initial_simdown',0);

	if plotit,
		drawnow;
		ch = get(0,'children');
		if length(ch)>=2, close(ch(2)); end;
	else,
		close(gcf);
	end;

	r(i) = 10*o.r_up / 5; % convert to Hz

end;

