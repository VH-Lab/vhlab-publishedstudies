function [n,factor] = neiltf_norm(responses, blank)
% NEILTF_NORM - normalize responses by subtracting blank response and dividing by maximum
%
%   [N,FACTOR] = NEILTF_NORM(RESPONSES, BLANK)
%
%   Normalizes the responses by subtracting blank, and then dividing by the maximum absolute
%   response. The factor that is used to divide is returned in FACTOR.

n = responses - blank;

factor = max(abs(n));

n = n / factor;

