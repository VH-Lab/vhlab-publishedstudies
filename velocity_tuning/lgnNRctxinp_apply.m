function C = lgnNRctxinp_apply(W,I)
% LGNNRCTXINP_APPLY - Apply weighted input to a model cortical cell from LGN 
%
%  C = LGNNRCTXINP_APPLY(W, I)
%
%  Given an NxRxT matrix I, compute the input at each timestep onto a cortical
%  cell C, weighted by the weights W, which must be NxR. C has the value of
%  the weighted input for each time step and will be 1xT.
%

[N,R,T]=size(I);

C = [];

for t=1:T,
	C(t) = sum(sum(W .* I(:,:,t)));
end;
  
