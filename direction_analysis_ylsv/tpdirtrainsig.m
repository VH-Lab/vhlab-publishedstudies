function [newcell] = tpdirtrainsig(ds,cell,cellname,plotit)


  % if zero arguments then return the associate names that are added by
  % this function
if nargin == 0, 
	newcell = {'changeDSI vec sig p', 'changeDSI vec sig'};
	return;
end;


newcell = cell;

myassocs = tpdirtrainsig; 
% remove any existing database entries so we can replace them
for I=1:length(myassocs), 
	[as,i] = findassociate(newcell,myassocs{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

otresp = findassociate(newcell,'Best orientation resp','','');
otrecovresp = findassociate(newcell,'Recovery Best orientation resp','','');

if ~isempty(otresp)&~isempty(otrecovresp),  % must have OT and recovery to proceed
	otresp = otresp(1);  % should not be more than one but just in case
	otrecovresp = otrecovresp(1); % should not be more than one but just in case

	angles = otresp.data.curve(1,:);
	
	allresps = [otresp.data.ind{:}];
	notnans = find(0==isnan(mean(allresps')));
    allresps = allresps(notnans,:);
	orig_vector = [allresps]*transpose(exp(sqrt(-1)*mod(angles*pi/180,2*pi)));

	allrespsrec = [otrecovresp.data.ind{:}];
	notnansrec = find(0==isnan(mean(allrespsrec')));
    allrespsrec = allrespsrec(notnans,:);

	recov_vector = [allrespsrec]*transpose(exp(sqrt(-1)*mod(angles*pi/180,2*pi)));

	% magnitude comparison
	recov_vector_norm = recov_vector / max(otrecovresp.data.curve(2,:));
	orig_vector_norm = orig_vector / max(otresp.data.curve(2,:));

	[h,changeDSIvec_p] = ttest2(abs(orig_vector_norm),abs(recov_vector_norm),0.05,'both');
	
	% now add our results back to the cell database
	newcell = associate(newcell,'changeDSI vec sig p','twophoton',changeDSIvec_p,'Vector test of change in DSI');
	newcell = associate(newcell,'changeDSI vec sig','twophoton',changeDSIvec_p<0.05,'Vector test of change in DSI');
end;



