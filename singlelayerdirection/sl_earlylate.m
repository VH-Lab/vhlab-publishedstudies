function [early,late] = sl_earlylate(N)
% SL_EARLYLATE - Return synapses that fire before or after the main diagonal
%
%  [EARLY,LATE] = SL_EARLYLATE(N)
% 
%  For a feedforward network of NxN neurons that comprise input to a direction
%  selective cells, returns the neurons that fire "before" the inputs on 
%  the main diagonal and those that fire "after" the inputs on the main 
%  diagonal.  
%

inds = reshape(1:(N*N),N,N);

inds_ = inds(end:-1:1,:);

early = [];
late = [];

for i=1:N-1,
	early = cat(1,early, diag(inds_,-i));
	late= cat(1,late, diag(inds_,i));
end;
