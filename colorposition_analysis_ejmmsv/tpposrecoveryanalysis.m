function [newcell,assoc]=tpposrecoveryanalysis(ds,cell,cellname,display)

%  TPPOSANALYSIS
%
%  [NEWSCELL,ASSOC]=TPPOSRECOVERYANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the position tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%  
%  Measures gathered from the RECOVERY Pos test are identical to those in the
%  TPPOSANALYSIS function.  This function repackages the responses as though
%  they were recorded during a Pos test and runs the TPPOSANALYSIS function.
%
%  A list of associate types that TPPOSRECOVERYANALYSIS computes is returned if
%  the function is called with no arguments.


   % strategy here will be to pull out the position test and response associates
   %   install the recoveryation test and response associate values into the 
   %   original position test and response associates, re-run the 
   %   original position tests to get the recoveryation values, and then
   %   to move the position result associates to be recoveryation result
   %   associates and restore the original position result associates

posassociates= tpposanalysis;
if nargin==0,
	newcell = posassociates;
	for i=1:length(newcell), newcell{i} = ['Recovery ' newcell{i}]; end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpposrecoveryanalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

extraposassociates = {'Best X pos test','Best Y pos test','Best X pos resp','Best Y pos resp'};

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

posxtest = findassociate(newcell,'Best X pos test','',[]);
posytest = findassociate(newcell,'Best Y pos test','',[]);

for i=1:2,

if i==1, 
	recoverytppostest = findassociate(newcell,'Best X pos recovery test','','');
	recoverytpposresp = findassociate(newcell,'Best X pos recovery resp','','');
else,
	recoverytppostest = findassociate(newcell,'Best Y pos recovery test','','');
	recoverytpposresp = findassociate(newcell,'Best Y pos recovery resp','','');
end;

if ~isempty(recoverytppostest)&~isempty(recoverytpposresp),

	g=load([getpathname(ds) recoverytppostest.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
	s=stimscripttimestruct(g.saveScript,g.MTI2);

	% find out if we are going in x or y direction
	rects = [];
	for i=1:numStims(s.stimscript),  
		if ~isfield(getparameters(get(s.stimscript,i)),'isblank'),
			rects = [rects; getfield(getparameters(get(s.stimscript,i)),'rect')];
		end;
	end;
	rs = max(diff(rects));

	Ymode = 1;
	if rs(2)==rs(4)&rs(4)==0&rs(1)>0&rs(3)>0&rs(1)<70&rs(3)<70, % going in x direction
		Ymode = 0;
	elseif rs(1)==rs(3)&rs(1)==0&rs(2)>0&rs(4)>0&rs(2)<70&rs(4)<70, % going in y direction
		Ymode = 1; % not necessary
	end;

	posassociateslist = cat(2,posassociates,extraposassociates);
	savedassoc=struct('type','t','owner','t','data',0,'desc',0); savedassoc=savedassoc([]);
	INDs = [];
	for i=1:length(posassociateslist),
		[myassoc,myind] = findassociate(newcell,posassociateslist{i},'','');
		if ~isempty(myassoc), 
			savedassoc(end+1)=myassoc; INDs(end+1) = myind;
		end;
	end;

	if Ymode, str = 'Best Y pos', else, str = 'Best X pos'; end;
	newcell=associate(newcell,[str ' test'],'',recoverytppostest.data,'');
	resp = recoverytpposresp.data;
	resp.curve = resp.curve(:,1:end);
	resp.ind = resp.ind(1:end);
	resp.indf = resp.indf(1:end);
	newcell = associate(newcell,[str ' resp'],'',resp,'');

	[newcell,newassocs] = tpposanalysis(ds,newcell,cellname,0);

	% now grab the associates

	for i=1:length(posassociateslist),
		[myassoc,myind] = findassociate(newcell,posassociateslist{i},'','');
		newcell = disassociate(newcell,myind);
		if ~isempty(myassoc),
			newcell = associate(newcell,['Recovery ' myassoc.type],myassoc.owner,myassoc.data,myassoc.desc);
		end;
	end;
	
	% now restore the old ones
	for i=1:length(savedassoc), newcell = associate(newcell,savedassoc(i)); end;

	if display, 
		figure;
		recoverytpposfit = findassociate(newcell,'Recovery POS Fit','','');
		recoverytpposresp = findassociate(newcell,'Recovery POS Response curve','','');
		recoveryresp = recoverytpposresp.data;
		errorbar(recoveryresp(1,:),recoveryresp(2,:),recoveryresp(4,:),'ro'); 
		hold on
		if Ymode,
			oldfit = findassociate(newcell,'POS Y Fit','','');
			oldresp = findassociate(newcell,'POS Y Response curve','','');
		else,
			oldfit = findassociate(newcell,'POS X Fit','','');
			oldresp = findassociate(newcell,'POS X Response curve','','');
		end;
		oldresp = oldresp.data;
		errorbar(oldresp(1,:),oldresp(2,:),oldresp(4,:),'bs'); 
		plot(oldfit.data(1,:),oldfit.data(2,:),'b');
		plot(recoverytpposfit.data(1,:),recoverytpposfit.data(2,:),'r');
		xlabel('Position (pixels)')
		ylabel('\Delta F/F');
		title(cellname,'interp','none');
	end % display
end;

end; % for i=1:2
