function [newcell,assoc]=tpiontophoresisotanalysis(ds,cell,cellname,display)

%  TPOTIONTOPHORESISOTANALYSIS
%
%  [NEWSCELL,ASSOC]=TPIONTOPHORESISOTANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes orientation tuning tests with iontophoresis.
%  DS is a valid DIRSTRUCT experiment record.  CELL is a list of
%  MEASUREDDATA objects, CELLNAME is a string list containing the
%  names of the cells, and DISPLAY is 0/1 depending upon whether
%  or not output should be displayed graphically.
%  
%  This function analyzes directories that are indicated by 
%  'Best GLUT orientation test' or 'Best GABA orientation test'.
%
%  Measures gathered from the test are identical to
%  those in the TPOTANALYSIS function.  This function repackages
%  the responses as though they were recorded during a OT test and
%  runs the TPOTANALYSIS function.
%  In addition, the following associates are returned:
%     'Iont sig'            |  For each current level, 0/1 if
%                           |      differences among blanks is significant
%     'Iont p value'        |  For each current level, t-test p value between
%                           |      blanks
%     'Iont currents'       |  Current levels used
%     'Iont vis blank'      |  Responses to visual blanks
%                           |  [curr1 mean1 stddev1 stderr1; ...]
%     'Iont vis blank ind'  |  Individual trial responses to visual blanks
%                           |    (cell list for each current)
%
%  A list of associate types that TPIONTOPHORESISOTANALYSIS computes is
%  returned if the function is called with no arguments.
   
   % strategy here will be to pull out the orientation data and create response
   %   associates that can be run with TPOTANALYSIS.
   %   install the iontophoresis orientation test and response associate values into the 
   %   original orientation test and response associates, re-run the 
   %   original orientation tests to get the recoveryation values, and then
   %   to move the orientation result associates to be iontophoresis result
   %   associates and restore the original orientation result associates

otassociates= tpotanalysis;
if nargin==0,
	newcell = otassociates;
	for i=1:length(newcell), newcell{i} = ['Iont ' newcell{i}]; end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpiontophoresisotanalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

  % we can read either 'Best GLUT orientation' or 'Best GABA orientation'

glutottest = findassociate(newcell,'Best GLUT orientation test','','');
glutotresp = findassociate(newcell,'Best GLUT orientation resp','','');
gabaottest = findassociate(newcell,'Best GABA orientation test','','');
gabaotresp = findassociate(newcell,'Best GABA orientation resp','','');

if (~isempty(glutottest)&~isempty(glutotresp))|(~isempty(gabaottest)&~isempty(gabaotresp)), % make sure we have something to analyze
	% first, let's save the associates from orientation
	extraotassociates = {'Best orientation test','Best orientation resp'};
	otassociateslist = cat(2,otassociates,extraotassociates);
	savedassoc=struct('type','t','owner','t','data',0,'desc',0); savedassoc=savedassoc([]);
	INDs = []; 
	for i=1:length(otassociateslist),
		[myassoc,myind] = findassociate(newcell,otassociateslist{i},'','');
		if ~isempty(myassoc), 
			savedassoc(end+1)=myassoc; INDs(end+1) = myind;
		end;
		if i<=length(otassociates), accumdata{i} = {}; end;
	end;

	currs_p_values = [];
	currs_h_values = [];
    currs_blank_values = [];
    blankinds = {};

	currlist = [];

	% step through conditions

	testlist = {}; resplist = {};
	if ~isempty(glutottest), testlist{end+1} = glutottest; resplist{end+1} = glutotresp;  end;
	if ~isempty(gabaottest), testlist{end+1} = gabaottest; resplist{end+1} = gabaotresp;  end;

	% doesn't really matter where the data are
	for i=1:length(testlist),
		
		g=load([getpathname(ds) testlist{i}.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
		script=stimscripttimestruct(g.saveScript,g.MTI2);

        anglesCurr = [];  shift = 0;
        for k=1:numStims(script.stimscript),
            p = getparameters(get(script.stimscript,k));
            if ~isfield(p,'isblank'),
                anglesCurr = [anglesCurr; p.angle p.iontophor_curr k+shift ];
            else,
                if p.iontophor_curr==0,
                    shift = -1;
                    anglesCurr = [anglesCurr; Inf p.iontophor_curr NaN];
                else,
                    anglesCurr = [anglesCurr; Inf p.iontophor_curr k+shift];
                end;
            end;
        end;

		currsi0 = find(anglesCurr(:,2)==0);
		angs0 = sort(anglesCurr(currsi0,1));

		currs = unique(anglesCurr(:,2));

		for j=1:length(currs),
			currsind = find(anglesCurr(:,2)==currs(j));
			if eqlen(sort(anglesCurr(currsind,1)),angs0),
				% for this current level, we have a complete representation of angles, so include it
				currlist(end+1) = currs(j);
				% now, for the blank, do a t-test
                %anglesCurr(currsind(find(isinf(anglesCurr(currsind,1)))),3),
                
                if ~isnan(anglesCurr(currsind(find(isinf(anglesCurr(currsind,1)))),3)),
                    blankinds{j} = resplist{i}.data.ind{anglesCurr(currsind(find(isinf(anglesCurr(currsind,1)))),3)};
                else, blankinds{j} = resplist{i}.data.blankind;
                end;
                if currs(j)<0, teststr = 'left'; elseif currs(j)>0, teststr = 'right'; else, teststr = 'both'; end;
                [h,pvalue] = ttest2(resplist{i}.data.blankind, blankinds{end}, 0.05,teststr);
				currs_h_values(end+1,1:2) = [ currs(j) h      ];
				currs_p_values(end+1,1:2) = [ currs(j) pvalue ];
                currs_blank_values(end+1,1:4) = [ currs(j) mean(blankinds{end}) std(blankinds{end}) stderr(blankinds{end}) ];

				% now build an orientation response curve

				theinds = find(anglesCurr(:,2)==currs(j)&~isinf(anglesCurr(:,1)));
				[angssorted,theindssorted] = sort(anglesCurr(theinds,1));
                
				clear myresp;
				myresp.curve(1,:) = anglesCurr(theinds(theindssorted),1);
				myresp.curve(2:4,:) = resplist{i}.data.curve(2:4,anglesCurr(theinds(theindssorted),3));
				myresp.ind = resplist{i}.data.ind(anglesCurr(theinds(theindssorted),3))';
				myresp.indf = resplist{i}.data.indf(anglesCurr(theinds(theindssorted),3))';
                if ~isnan(anglesCurr(currsind(find(isinf(anglesCurr(currsind,1)))),3)),
                    myresp.blankind = resplist{i}.data.ind{anglesCurr(currsind(find(isinf(anglesCurr(currsind,1)))),3)};
                else, myresp.blankind = resplist{i}.data.blankind;
                end;
                myresp.blank = [nanmean(myresp.blankind) nanstd(myresp.blankind) nanstderr(myresp.blankind)];
                mnl = Inf;
                for k=1:length(myresp.ind), mnl = min([mnl length(myresp.ind{k})]); end;
                for k=1:length(myresp.ind), myresp.ind{k} = myresp.ind{k}(1:mnl); end;
                    
                newcell = associate(newcell,'Best orientation resp','',myresp,'');
				newcell = associate(newcell,'Best orientation test','',testlist{i}.data,'');
				[newcell,newassocs] = tpotanalysis(ds,newcell,cellname,0);

				for k=1:length(otassociateslist),
					[myassoc,myind] = findassociate(newcell,otassociateslist{k},'','');
					newcell = disassociate(newcell,myind);
                    %if strcmp('OT Carandini Fit',otassociateslist{k}), disp('here'); length(myassoc.data), end;
					if k<=length(otassociates),
                       if ~isempty(myassoc),
                           accumdata{k}{end+1} = myassoc.data;
                       else, accumdata{k}{end+1} = [];
                       end;
                    end;
				end;
			end;
		end;
	end;

	% add the new associates
	for i=1:length(otassociates),
		newcell = associate(newcell,['Iont ' otassociates{i}],'',accumdata{i},'');
	end;

	newcell = associate(newcell,['Iont sig'],'',currs_h_values,'');
	newcell = associate(newcell,['Iont p value'],'',currs_p_values,'');
	newcell = associate(newcell,['Iont currents'],'',currlist,'');
    newcell = associate(newcell,['Iont vis blank inds'],'',blankinds,'');
    newcell = associate(newcell,['Iont vis blank'],'',currs_blank_values,'');

	% now restore the old ones
	for i=1:length(savedassoc), newcell = associate(newcell,savedassoc(i)); end;

	if display, 
		iontotpvalue = findassociate(newcell,'Iont OT visual response p','','');
		iontotresp = findassociate(newcell,'Iont OT Response curve','','');
		iontotresp_fit = findassociate(newcell,'Iont OT Carandini 2-peak Fit','','');
		iontcurrents = findassociate(newcell,'Iont currents','','');
		%if recoverytpotpvalue.data<0.05&tpotpvalue.data<0.05,
		figure;
		for i=1:length(iontotresp.data),
			if iontcurrents.data(i)==0, c = 'k';
			elseif iontcurrents.data(i)>0, c = 'b';
			else, c = 'r';
			end;
			resp = iontotresp.data{i};
			fit = iontotresp_fit.data{i};
			hold on;
			errorbar(resp(1,:),resp(2,:),resp(4,:),[c 'o']);
			plot(0:359,fit,c);
        end;
		xlabel('Direction (\circ)')
		ylabel('\Delta F/F');
		title([cellname],'interp','none');
	end % display
end;
