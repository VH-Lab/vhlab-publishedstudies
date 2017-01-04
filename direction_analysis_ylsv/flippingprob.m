function fp = flippingprob(dp1,dp2)
% FLIPPINGPROB - The likelihood that a cell underwent a direction reversal
%
%  FP = FLIPPINGPROB(DP1, DP2)
%
%  Calculates the likelihood that a direction-selective cell underwent a 
%  direction preferent reversal from time 1 to time 2.
%
%  DP1 should be a vector list of direction preference angle values
%  (in degrees) from bootstrap simulations.  DP2 should be a vector
%  list of direction preference values from a second measurement.
%  The length of DP1 and DP2 should be the same.
%
%  The FP is the fraction of simulations where the difference between the
%  angle in DP1 and DP2 is greater than 90 degrees.
%
%  Keywords: reversal, preference reversal, direction preference reversal

if any(isnan(dp2)), fp = NaN;
else,
    fp = sum(angdiff(dp1'-dp2')>90)/length(dp1);
end;
