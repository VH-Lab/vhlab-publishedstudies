function [bestparams,bestsqrerr, fitvalues_ssm] = ssm_fit(x, r)
% SSM_FIT Perform sinusoidal surround modulation model fit
% 
%   [PARAMS, SSM_SSE, FITVALUE_SSM] = SSM_FIT(X,R)
%
%   Performs a fit of the responses in R as a function of X
%   to the SSM function (see help ssm).
%
%   The function begins from several starting points in order to
%   find what is hopefully a global maximum.
%
%   Note that X is normalized so that max(X) is 300.  This will impact
%   the parameters that are returned (note to self: can we remove this 
%   condition?)
%


x = 300 * x/max(x); % convert so 300 is max

normalize = 0;
if normalize,
	r = r./max(r);
end;

maxR = max(r);


abovethresh= find(r > 0.5*maxR);         
halfpoint = x(abovethresh(1));  % estimate the first time the response goes to half maximum
        
abovebigthresh = find(r > 0.6*maxR);
surroundstart = 0.7*x(abovebigthresh(1)) + 51;  % estimate where surround begins
      
SPn = 0;  % start to make a list of starting parameter values
                     
for a = 2 * maxR,
	for b = [1/10 1/50], % could normalize by x, probably should
		for c = halfpoint,
			for d = 1,
				for e = [1/10 1/50], % could normalize by x, probably should
					for f = surroundstart,
						for g = 0,
							for h = [(2*pi)/50 (2*pi)/75 (2*pi)/100 (2*pi)/125 (2*pi)/150], % probably need to normalize by x
								for k = [-pi -pi/2 0 pi/2 pi],
									for m = [0.5 2],
										SPn =  SPn+1;
										SSM_SP{SPn} = [a b c d e f g h k m];  % start point
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

options = optimset('lsqcurvefit');
options.Display = 'off';

 % upper and lower bounds
ub = [Inf 1  Inf  Inf   1    Inf    0.1   (2*pi)/20   2*pi   Inf];  % not sure if 0.1 is good..might need to divide by maxR
lb = [0   0 -Inf  0     0   -Inf   -0.1     0        -2*pi  -Inf];

bestparams = [];
bestsqrerr = Inf;

for j = 1:SPn  
	[params, err] = lsqcurvefit(@ssm,SSM_SP{j},x,r,lb,ub,options);
	if err<bestsqrerr,
		bestparams = params;
		bestsqrerr = err;
	end;
end   

fitvalues_ssm = ssm(bestparams,x);
