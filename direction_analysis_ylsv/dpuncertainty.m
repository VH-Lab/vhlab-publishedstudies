function [du,I,J,angori] = dpuncertainty(dp)
% DPUNCERTAINTY - Calculate the likelihood that the direction preference is opposite of the best fit
%
%   [DU,I,J,ANGDIR] = DPUNCERTAINTY(DP)
%
%   Given a vector list of direction preference angle values (in degrees)
%   derived from bootstrap simulations (or some other method), calculates the
%   likelihood DU that the cell's direction preference is actually the
%   opposite of the median direction preference. Also returns I, the
%   simulation indexes that match the majority direction, and J, the
%   simulation indexes that are more than 90 degrees away from the 
%   majority direction, and ANGDIR, the direction preference.
%
%   See also: FLIPPINGPROB
%
vec = 0;

for i=1:length(dp),
	vec = vec + exp(sqrt(-1)*2*pi*mod(dp(i),180)/180);
end;

angori = mod(angle(vec)*180/(2*pi),180);

J = find(angdiff(angori-dp')>90);
I = find(angdiff(angori-dp')<=90);

if length(J)>length(I), TJ=J; TI=I; I=TJ; J=TI; angori = angori + 180; end;

du = (length(dp) - length(I))/length(dp);

%if du>0.5, du = 1-du; end;

