function v = dydt(y,I,W,n)
  % y is current value of y
  % I is steady state input current
  % W is connection matrix
  % n is amount of noise
 
T=0;tau=0.005;l=length(W);
v=[(-y+max([zeros(l,1) I+n*randn(l,1)+W*y-T]')')/tau];

