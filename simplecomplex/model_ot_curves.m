function model_ot_curves

 % distance units are in degrees of visual space, not mm of cortex
numPts = 200;
stimulus = zeros(numPts);

ONguys = stimulus>0;
OFFguys = stimulus<0;

xi=linspace(-10,10,numPts);
yi=linspace(-10,10,numPts);

[stimspacex,stimspacey] = meshgrid(xi,yi);

 % input current from layer 4 cells

 

  % how to do model?

  % each cell is a point, network is a vector
  
  
  

function resp = layer23_response(stimulus,layer4conns);
%resps = (ONguys + OFFguys).*layer4conns
resp = sum(sum(((stimulus>0)+(stimulus<0)).*layer4conns));


