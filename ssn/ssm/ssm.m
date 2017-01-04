function [ y ] = ssm( params, x)
%SSM Sinusoidal surround modulation fit function, from Rubin et al. 2013
%   
%   Y = SSM(PARAMS, X)
%
%   Returns the results of the sinusoidal suround modulation fit from
%   Dan Rubin's thesis (Ken Miller lab, Columbia, 2011), and from
%   Rubin et al. 2013 (in submission). This function is essentially a difference of
%   gaussians (DOG) fit with a sinusoidal modulation.
%
%   Y = a*((erf((X - c)*b) + 1)/2) + d*((erf((X - f)*e) + 1)/2).*...
%        real((exp((g + h*sqrt(-1))*X - k*sqrt(-1)) + m));
%
%   where a = PARAMS(1), b=PARAMS(2), etc.
%
%   See also: DOG8

a = params(1);
b = params(2);
c = params(3);
d = params(4);
e = params(5);
f = params(6);
g = params(7);
h = params(8);
k = params(9);
m = params(10);

y = a*((erf((x - c)*b) + 1)/2) + d*((erf((x - f)*e) + 1)/2).*real((exp((g + h*sqrt(-1))*x - k*sqrt(-1)) + m));

