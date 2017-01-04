function [newcell,assoc]=tpposadaptanalysis(ds,cell,cellname,display)

%  TPPOSANALYSIS
%
%  [NEWSCELL,ASSOC]=TPPOSADAPTANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the position tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%  
%  Measures gathered from the ADAPT Pos test are identical to those in the
%  TPPOSANALYSIS function.  This function repackages the responses as though
%  they were recorded during a Pos test and runs the TPPOSANALYSIS function.
%
%  A list of associate types that TPPOSADAPTANALYSIS computes is returned if
%  the function is called with no arguments.


   % strategy here will be to pull out the position test and response associates
   %   install the adaptation test and response associate values into the 
   %   original position test and response associates, re-run the 
   %   original position tests to get the adaptation values, and then
   %   to move the position result associates to be adaptation result
   %   associates and restore the original position result associates

posassociates= tpposanalysis;
if nargin==0,
	newcell = posassociates;
	for i=1:length(newcell), newcell{i} = ['Adapt ' newcell{i}]; end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpposadaptanalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

extraposassociates = {'Best X pos test','Best Y pos test','Best X pos resp','Best Y pos resp'};

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

posxtest = findassociate(newcell,'Best X pos test','',[]);
posytest = findassociate(newcell,'Best Y pos test','',[]);

adapttppostest = findassociate(newcell,'DragoiAdaptPos test','','');
adapttpposresp = findassociate(newcell,'DragoiAdaptPos resp','','');

if ~isempty(adapttppostest)&~isempty(adapttpposresp),

	
	g=load([getpathname(ds) adapttppostest.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
	s=stimscripttimestruct(g.saveScript,g.MTI2);

	% find out if we are going in x or y direction
	rects = [];
	for i=3:numStims(s.stimscript),  % stim 1 is adapting stim, stim 2 is top-off
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
	newcell=associate(newcell,[str ' test'],'',adapttppostest.data,'');
	resp = adapttpposresp.data;
	resp.curve = resp.curve(:,3:end);
	resp.ind = resp.ind(3:end);
	resp.indf = resp.indf(3:end);
	newcell = associate(newcell,[str ' resp'],'',resp,'');

	[newcell,newassocs] = tpposanalysis(ds,newcell,cellname,0);

	% now grab the associates

	for i=1:length(posassociateslist),
		[myassoc,myind] = findassociate(newcell,posassociateslist{i},'','');
		newcell = disassociate(newcell,myind);
		if ~isempty(myassoc),
			newcell = associate(newcell,['Adapt ' myassoc.type],myassoc.owner,myassoc.data,myassoc.desc);
		end;
	end;
	
	% now restore the old ones
	for i=1:length(savedassoc), newcell = associate(newcell,savedassoc(i)); end;

	if display, 
		figure;
		adapttpposfit = findassociate(newcell,'Adapt POS Fit','','');
		adapttpposresp = findassociate(newcell,'Adapt POS Response curve','','');
		adaptresp = adapttpposresp.data;
		errorbar(adaptresp(1,:),adaptresp(2,:),adaptresp(4,:),'ro'); 
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
		plot(adapttpposfit.data(1,:),adapttpposfit.data(2,:),'r');
		xlabel('Position (pixels)')
		ylabel('\Delta F/F');
		title(cellname,'interp','none');
	end % display
end;
