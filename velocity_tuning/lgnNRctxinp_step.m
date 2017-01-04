function I = lgnNRctxinp_step(T0, T1, dT, spiketimes, amp, durr)
% LGNNRCTXINP_STEP - Compute input to cortical cell from LGNNR spike trains w/step function synapses
%
%  I = LGNNRCTXINP_STEP(T0, T1, DT, SPIKETIMES, AMP, DURR)
%
%  Compute the input response from each LGN cells from time T0 to time T1 in steps of DT.
%  SPIKETIMES is an NxRxK matrix that has the K spike times for input neuron n,r .
%  SPIKETIMES(n,r,k) is the kth spike time for neuron at LGN position n,r. If NaN is passed for any
%  spiketime it is assumed to correspond to no spike.
%  AMP is the amplitude of the response to a single spike, that persists for 
%  duration DURR.
%
%  The function STEPFUNC is used to calculate the responses.
%
%  I(i,j,t) is the input to the cortical cell at timestep sample t, which corresponds in real time
%  to T0 + DT * (t-1)
%

T = T0:dT:T1;

[N,R,K] = size(spiketimes);

I = zeros(N,R,length(T));

for n=1:N,
	for r=1:R,
		spikes = spiketimes(n,r,:);
		spikes = squeeze(spikes); % convert to 1-D
		spikes = spikes(find(~isnan(spikes))); % get rid of any NaNs
		for s = 1:length(spikes),
			s_ = [0 amp 0]; % steps for step function
			t_ = [-10000 spikes(s) spikes(s)+durr];
			I(n,r,:) = I(n,r,:) + reshape(stepfunc(t_,s_,T,0),1,1,length(T));
		end;
	end;
end;


