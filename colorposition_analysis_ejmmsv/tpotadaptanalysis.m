function [newcell,assoc]=tpotadaptanalysis(ds,cell,cellname,display)

%  TPPOSANALYSIS
%
%  [NEWSCELL,ASSOC]=TPOTADAPTANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%  
%  Measures gathered from the ADAPT OT test are identical to those in the
%  TPOTANALYSIS function.  This function repackages the responses as though
%  they were recorded during a OT test and runs the TPOTANALYSIS function.
%
%  A list of associate types that TPOTADAPTANALYSIS computes is returned if
%  the function is called with no arguments.


   % strategy here will be to pull out the orientation test and response associates
   %   install the adaptation test and response associate values into the 
   %   original orientation test and response associates, re-run the 
   %   original orientation tests to get the adaptation values, and then
   %   to move the orientation result associates to be adaptation result
   %   associates and restore the original orientation result associates

otassociates= tpotanalysis;
if nargin==0,
	newcell = otassociates;
	for i=1:length(newcell), newcell{i} = ['Adapt ' newcell{i}]; end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpotadaptanalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

extraotassociates = {'Best orientation test','Best orientation resp'};

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

ottest = findassociate(newcell,'Best orientation test','',[]);

adapttpottest = findassociate(newcell,'DragoiAdaptOri test','','');
adapttpotresp = findassociate(newcell,'DragoiAdaptOri resp','','');

if ~isempty(adapttpottest)&~isempty(adapttpotresp),

	g=load([getpathname(ds) adapttpottest.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
	s=stimscripttimestruct(g.saveScript,g.MTI2);

	% find out if we are going in x or y direction
	rects = [];
	for i=3:numStims(s.stimscript),  % stim 1 is adapting stim, stim 2 is top-off
		if ~isfield(getparameters(get(s.stimscript,i)),'isblank'),
			rects = [rects; getfield(getparameters(get(s.stimscript,i)),'rect')];
		end;
	end;
	rs = max(diff(rects));

	otassociateslist = union(otassociates,extraotassociates);
	savedassoc=struct('type','t','owner','t','data',0,'desc',0); savedassoc=savedassoc([]);
	INDs = [];
	for i=1:length(otassociateslist),
		[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
		if ~isempty(myassoc), 
			savedassoc(end+1)=myassoc; INDs(end+1) = myind;
		end;
	end;

	newcell=associate(newcell,['Best orientation test'],'',adapttpottest.data,'');
	resp = adapttpotresp.data;
	if getfield(getparameters(get(s.stimscript,numStims(s.stimscript))),'contrast')==0, o=1; else, o=0; end;
	resp.curve = resp.curve(:,3:end-o);
	resp.ind = resp.ind(3:end-o);
	resp.indf = resp.indf(3:end-o);
	for i=3:numStims(s.stimscript)-o, resp.curve(1,i-2) = getfield(getparameters(get(s.stimscript,i)),'angle'); end;
	newcell = associate(newcell,['Best orientation resp'],'',resp,'');

	[newcell,newassocs] = tpotanalysis(ds,newcell,cellname,0);

	% now grab the associates

	for i=1:length(otassociateslist),
		[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
		newcell = disassociate(newcell,myind);
		if ~isempty(myassoc),
			newcell = associate(newcell,['Adapt ' myassoc.type],myassoc.owner,myassoc.data,myassoc.desc);
		end;
	end;
	
	% now restore the old ones
	for i=1:length(savedassoc), newcell = associate(newcell,savedassoc(i)); end;

	newcell = associate(newcell,['Adapt OT angle'],'',getfield(getparameters(get(s.stimscript,1)),'angle'),'');

	if display, 
		figure;
		adapttpotfit = findassociate(newcell,'Adapt OT Carandini 2-peak Fit','','');
		adapttpotresp = findassociate(newcell,'Adapt OT Response curve','','');
		adaptresp = adapttpotresp.data;
		errorbar(adaptresp(1,:),adaptresp(2,:),adaptresp(4,:),'ro'); 
		hold on
		oldfit = findassociate(newcell,'OT Carandini 2-peak Fit','','');
		oldresp = findassociate(newcell,'OT Response curve','','');
		oldresp = oldresp.data;
		errorbar(oldresp(1,:),oldresp(2,:),oldresp(4,:),'bs'); 
		plot(0:359,oldfit.data,'b');
		plot(0:359,adapttpotfit.data,'r');
		xlabel('Direction (\circ)')
		ylabel('\Delta F/F');
		title(cellname,'interp','none');
	end % display
end;
