function mp = matchingprob(dp1,dp2)
%modified from  [du,I,J,angori] = dpuncertainty(dp)

positive = 0; negative = 0;
if any(isnan(dp2))|any(isnan(dp1)), mp = NaN;
else,
    for i = 1:length(dp1),
        if angdiffwrap(dp1(i)-dp2,360)<90, 
            positive=positive+1; else negative = negative +1;
        end; 
    end;
    mp = positive/(positive+negative);
end;

