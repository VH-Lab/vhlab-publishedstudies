function [newcell,assoc]=tpotrecoveryanalysis(ds,cell,cellname,display)

%  TPPOSANALYSIS
%
%  [NEWSCELL,ASSOC]=TPOTRECOVERYANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%  
%  Measures gathered from the RECOVERY OT test are identical to those in the
%  TPOTANALYSIS function.  This function repackages the responses as though
%  they were recorded during a OT test and runs the TPOTANALYSIS function.
%
%  A list of associate types that TPOTRECOVERYANALYSIS computes is returned if
%  the function is called with no arguments.


   % strategy here will be to pull out the orientation test and response associates
   %   install the recoveryation test and response associate values into the 
   %   original orientation test and response associates, re-run the 
   %   original orientation tests to get the recoveryation values, and then
   %   to move the orientation result associates to be recoveryation result
   %   associates and restore the original orientation result associates

otassociates= tpotanalysis;
if nargin==0,
	newcell = otassociates;
	for i=1:length(newcell), newcell{i} = ['Recovery ' newcell{i}]; end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpotrecoveryanalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

extraotassociates = {'Best orientation test','Best orientation resp'};

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

ottest = findassociate(newcell,'Best orientation test','',[]);

recoverytpottest = findassociate(newcell,'Best OT recovery test','','');
recoverytpotresp = findassociate(newcell,'Best OT recovery resp','','');

if ~isempty(recoverytpottest)&~isempty(recoverytpotresp),

	g=load([getpathname(ds) recoverytpottest.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
	s=stimscripttimestruct(g.saveScript,g.MTI2);

	otassociateslist = union(otassociates,extraotassociates);
	savedassoc=struct('type','t','owner','t','data',0,'desc',0); savedassoc=savedassoc([]);
	INDs = [];
	for i=1:length(otassociateslist),
		[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
		if ~isempty(myassoc), 
			savedassoc(end+1)=myassoc; INDs(end+1) = myind;
		end;
	end;

	newcell=associate(newcell,['Best orientation test'],'',recoverytpottest.data,'');
	resp = recoverytpotresp.data;
	myinds = [];
	if eqlen(resp.curve(1,:),1:numStims(s.stimscript)),
		for i=1:numStims(s.stimscript),
			if ~isfield(getparameters(get(s.stimscript,i)),'isblank'),
				myinds(end+1) = i;
				resp.curve(1,i) = getfield(getparameters(get(s.stimscript,i)),'angle');
			end;
		end;
		resp.curve = resp.curve(:,myinds);
		resp.ind = resp.ind(myinds);
		resp.indf = resp.indf(myinds);
	end;
	newcell = associate(newcell,['Best orientation resp'],'',resp,'');

	[newcell,newassocs] = tpotanalysis(ds,newcell,cellname,0);

	% now grab the associates

	for i=1:length(otassociateslist),
		[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
		newcell = disassociate(newcell,myind);
		if ~isempty(myassoc),
			newcell = associate(newcell,['Recovery ' myassoc.type],myassoc.owner,myassoc.data,myassoc.desc);
		end;
	end;
	
	% now restore the old ones
	for i=1:length(savedassoc), newcell = associate(newcell,savedassoc(i)); end;

	if display, 
		recoverytpotpvalue = findassociate(newcell,'Recovery OT visual response p','','');
		tpotpvalue = findassociate(newcell,'OT visual response p','','');
		if recoverytpotpvalue.data<0.05&tpotpvalue.data<0.05,
			figure;
			recoverytpotfit = findassociate(newcell,'Recovery OT Carandini 2-peak Fit','','');
			recoverytpotresp = findassociate(newcell,'Recovery OT Response curve','','');
			adapttpotfit = findassociate(newcell,'Adapt OT Carandini 2-peak Fit','','');
			adapttpotresp = findassociate(newcell,'Adapt OT Response curve','','');
			recoveryresp = recoverytpotresp.data;
			errorbar(recoveryresp(1,:),recoveryresp(2,:),recoveryresp(4,:),'ro'); 
			hold on
			oldfit = findassociate(newcell,'OT Carandini 2-peak Fit','','');
			oldresp = findassociate(newcell,'OT Response curve','','');
			oldresp = oldresp.data;
			errorbar(oldresp(1,:),oldresp(2,:),oldresp(4,:),'bs'); 
			plot(0:359,oldfit.data,'b');
			plot(0:359,recoverytpotfit.data,'r');
			if ~isempty(adapttpotfit),
				errorbar(adapttpotresp.data(1,:),adapttpotresp.data(2,:),adapttpotresp.data(4,:),'go');
				plot(0:359,adapttpotfit.data,'g');
			end;
			xlabel('Direction (\circ)')
			ylabel('\Delta F/F');
			title(cellname,'interp','none');
		end;
	end % display
end;
