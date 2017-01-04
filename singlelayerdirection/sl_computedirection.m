function [rup, rdown, di, dsi] = sl_computedirection(D, alpha, threshold)
% SL_COMPUTEDIRECTION - Compute direction selectivity for a single layer "neuron"
%
%   [RUP, RDOWN, DI, DIS] = SL_COMPUTEDIRECTION(D, ALPHA, THRESHOLD)
%  
%  Compute direction responses for a single layer "neuron" with input
%  matrix D. D(i,j) is the weight of the connection at position i and 
%  lag j. A stimulus is assumed to move from D(end,:) to D(1,:) to
%  compute Rup and then from D(1,:) to D(end,:) to compute Rdown. The stimulus 
%  moves 1 position each time step; the "lag" of the response to position
%  i between D(i,j) and D(i,j+1) is considered to be 1 time step.
%
%  The neuron's output is assumed to be a rectified linear with
%  gain ALPHA.  R = ALPHA*RECTIFY(INPUT - THRESHOLD)
%

rup = 0;
rdown = 0;

D_ = D(end:-1:1,:);
N = size(D,1);

for i=-(N-1):1:(N-1),
	rup = rup + alpha * rectify(-threshold+sum(diag(D_,i)));
	rdown = rdown + alpha * rectify(-threshold+sum(diag(D,i)));
end;

di = (rup-rdown)/(rup);
dsi = (rup-rdown)/(rup+rdown);
