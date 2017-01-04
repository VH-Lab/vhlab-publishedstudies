function [newcell]=tpotcoloranalysis(ds,cell,cellname,display)

%  TPOTCOLORANALYSIS
%
%  [NEWSCELL,ASSOC]=TPOTCOLORANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%  
%  Measures gathered from the COLOR OT test are identical to those in the
%  TPOTANALYSIS function.  For each cone type and achromatic, this function
%  loops through all available orientation curves and chooses the tuning
%  curve with the largest response.  The results are then repackaged as though
%  they were recorded during a OT test and runs the TPOTANALYSIS function,.
%  except that 'L ', 'Ach ', or 'S ' are appended to the beginning.
%
%  A list of associate types that TPOTCOLORANALYSIS computes is returned if
%  the function is called with no arguments.


   % strategy here will be to pull out the orientation test and response associates
   %   install the recoveryation test and response associate values into
   %   the 
   %   original orientation test and response associates, re-run the 
   %   original orientation tests to get the recoveryation values, and then
   %   to move the orientation result associates to be recoveryation result
   %   associates and restore the original orientation result associates

  % get names of all known colors
[allids,begStrs,plotcolors,longnames] = FitzColorID;
   
otassociates= tpotanalysis;
if nargin==0,
	mylist = otassociates;
	newcell = {};
	for i=1:length(mylist),
		for k=1:length(begStrs), % add all colors as beginning strings to names; e.g., ['L ' mylist{i}]
			newcell{end+1} = [begStrs{k} ' ' mylist{i}];
		end;
	end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpotcoloranalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

extraotassociates = {'Best orientation test','Best orientation resp'};

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

ottest = findassociate(newcell,'Best orientation test','',[]);
otresp = findassociate(newcell,'Best orientation resp','',[]);

otherottests = findassociate(newcell,'orientation test','',''),
otherotresps = findassociate(newcell,'orientation resp','',''),

if ~isempty(ottest)|~isempty(otherottests),
	bottestname = '';
	stims = {}; stimid = []; resps = {}; dirnames = {};
	if ~isempty(ottest),
		bottestname = ottest.data;
		g=load([getpathname(ds) ottest.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
		s=stimscripttimestruct(g.saveScript,g.MTI2);
		stims = cat(2,stims,s.stimscript); resps = cat(2,resps,otresp.data); dirnames=cat(2,dirnames,ottest.data);
		stimid(end+1) = FitzColorID(getparameters(get(s.stimscript,1)));
	end;
	if ~isempty(otherottests),
		if strcmp(class(otherottests),'char'),
			if ~strcmp(bottestname, otherottests.data), % make sure we didn't already get it
				g=load([getpathname(ds) otherottests.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
				s=stimscripttimestruct(g.saveScript,g.MTI2);
				stims = cat(2,stims,s.stimscript); resps = cat(2,resps,otherotresps.data);
				dirnames = cat(2,dirnames,otherottests.data);
				p=getparameters(get(s.stimscript,1));
				stimid(end+1) = FitzColorID(p.chromhigh,p.chromlow,10);
			end;
		else,
			for j=1:length(otherottests.data),
				if ~strcmp(bottestname, otherottests.data{j}), % make sure we didn't already get it
					g=load([getpathname(ds) otherottests.data{j} filesep 'stims.mat'],'saveScript','MTI2','-mat');
					s=stimscripttimestruct(g.saveScript,g.MTI2);
					stims = cat(2,stims,s.stimscript); resps = cat(2,resps,otherotresps.data{j});
					dirnames = cat(2,dirnames,otherottests.data{j});
					p=getparameters(get(s.stimscript,1));
					stimid(end+1) = FitzColorID(p.chromhigh,p.chromlow,10);
				end;
			end;
		end;
	end;
	stimid,
	% now save the original orientation analysis
	otassociateslist = union(otassociates,extraotassociates);
	savedassoc=struct('type','t','owner','t','data',0,'desc',0); savedassoc=savedassoc([]);
	INDs = [];
	for i=1:length(otassociateslist),
		[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
		if ~isempty(myassoc), 
			savedassoc(end+1)=myassoc; INDs(end+1) = myind;
		end;
	end;
	
	% now find the best orientation for each case, and send it to the ot
	% analyzer
	
	for k = 1 : max(stimid),

		bestR = -Inf; bestRi = 0;
		poten = find(stimid==k);
		for i=1:length(poten),
			mx=max(resps{poten(i)}.curve(2,:));
			if bestR<mx, bestR = mx; bestRi = poten(i); end;
		end;
		if bestRi~=0,
			newcell=associate(newcell,['Best orientation test'],'',dirnames{bestRi},'');
			resp = resps{bestRi};
			myinds = [];
			if eqlen(resp.curve(1,:),1:numStims(s.stimscript)),
				for i=1:numStims(stims{bestRi}.stimscript),
					if ~isfield(getparameters(get(stims{bestRi}.stimscript,i)),'isblank'),
						myinds(end+1) = i;
						resp.curve(1,i) = getfield(getparameters(get(stims{bestRi}.stimscript,i)),'angle');
					end;
				end;
			else, myinds = 1:length(resp.curve(1,:));
			end;
			resp.curve = resp.curve(:,myinds);
			resp.ind = resp.ind(myinds);
			resp.indf = resp.indf(myinds);
			newcell = associate(newcell,['Best orientation resp'],'',resp,'');
			
			[newcell,newassocs] = tpotanalysis(ds,newcell,cellname,0);

			% now grab the associates and attach them with their new names
			for i=1:length(otassociateslist),
				[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
				newcell = disassociate(newcell,myind);
				if ~isempty(myassoc),
					newcell = associate(newcell,[begStrs{k} myassoc.type],myassoc.owner,myassoc.data,myassoc.desc);
				end;
			end;
		end;
	end;
	
	% now restore the old values
	for i=1:length(savedassoc), newcell = associate(newcell,savedassoc(i)); end;

	if display,
		cols = ['kgb'];
		Lpvalue = findassociate(newcell,'L OT visual response p','','');
		Achpvalue = findassociate(newcell,'Ach OT visual response p','','');		
		Spvalue = findassociate(newcell,'S OT visual response p','','');		
		good = 0;
		if ~isempty(Lpvalue), if Lpvalue.data<0.05, good = 1; end; end;
		if ~isempty(Achpvalue), if Achpvalue.data<0.05, good = 1; end; end;		
		if ~isempty(Spvalue), if Spvalue.data<0.05, good = 1; end; end;
		if good,
			figure;
			hold on;
			for k=1:3,
				fitc = findassociate(newcell,[begStr{k} 'OT Carandini Fit'],'','');
				respc = findassociate(newcell,[begStr{k} 'OT Response curve'],'','');
				if ~isempty(fitc)&~isempty(respc),
					myerrorbar(respc.data(1,:),respc.data(2,:),respc.data(4,:),respc.data(4,:),[cols(k) 'o']);
					plot(0:359,fitc.data,cols(k));
				end;
			end;
			A=axis; axis([0 max([180 respc.data(1,:)]) A([3 4])]);
			xlabel('Direction (\circ)')
			ylabel('\Delta F/F');
			title([cellname],'interp','none');
		end;
	end % display
end;

