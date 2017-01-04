function b = ssn_simpleorcomplex(cell,cellname,varargin)
% SSN_SIMPLEORCOMPLEX Determines if a cell that has undergone sharp vs. gauss window analysis is simple or complex.
%
%  B = SSN_SIMPLEORCOMPLEX(CELL, CELLNAME)
%  
%  Determines if a cell that has undergone sharp vs. gauss window analysis is simple or complex.
%
%  B = 1 if a cell is simple (sum of sharp and gauss F0 responses greater than F1), 0 if complex,
%  and NaN if the responses to all stimuli are not significant.


prefix = {'SP F0 ','SP F1 '};
names = {'gauss ','sharp '};

maxresps = [];

sig = [];

for k=1:length(prefix),
	for j=1:length(names),
		pvalue = findassociate(cell,[prefix{k} names{j} 'SZ response p'],'','');
		sig(k,j) = pvalue.data<0.05;
		responses = findassociate(cell,[prefix{k} names{j} 'SZ Response curve'],'','');
		maxresps(k,j) = mean(responses.data(2,:));
	end;
end;

b = sum(maxresps(2,:)) > sum(maxresps(1,:)); 

if ~any(sig(:,1)) | ~any(sig(:,2)),
	b = NaN; % crappy responses
end; 

