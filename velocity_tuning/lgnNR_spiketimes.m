function T = lgnNR_spiketimes(N, R, dx, dt, velocity, repeats)
% LGNNR_SPIKETIMES - Compute spike times of simple LGN with position and latency
%
%  T = LGNNR_SPIKETIMES(N,R,DX,DT,VELOCITY,REPEATS)
%
%  Calculates the spike times of a model LGN responding to a bar moving at constant
%  velocity. The LGN has 1 spatial dimension of size N with cell position preference spacing
%  of DX between cells. At each spatial location, there are cells that respond with a range of
%  latencies from 0 to (R-1)*DT, in steps of DT.  The stimulus moves at velocity VELOCITY and
%  repeats REPEATS times.
%
%  T is a 3-D matrix with response times for each cell. T(i,j,k) is the kth spike time of 
%  the cell at spatial position i and latency position j.
%

T = [];

for k=1:repeats,
	T(:,:,k) = (k-1)*(N*dx/velocity) + ...
		[repmat((1/velocity)*[0:dx:((N-1)*dx)]',1,R) + repmat([0:dt:((R-1)*dt)],N,1)];
end;


