function chr2_plotdirectiongratingresponses(cell, cellname)
% CHR2_PLOTDIRECTIONGGRATINGRESPONSES - Plot results of direction stimulation
%
%  CHR2_PLOTGRATINGRESULTS(CELL, CELLNAME)
%
%  For optical stimulation: plots angle (direction) responses
%  responses.
%

f = figure;

orient(f,'landscape');
set(f,'paperorientation','landscape');

angle.tests = {};

rows = 2;
maxcolumns = 10;

testnamelist = {'Dir4Hz','Dir2Hz','Dir1Hz'};

testname = '';
for t=1:length(testnamelist),
	if ~isempty(findassociate(cell,[testnamelist{t} int2str(1) ' test'],'','')),
		testname = testnamelist{t};
		break;
	end;
end;

columns = 0;
for i=1:maxcolumns,
	if ~isempty(findassociate(cell,[testname int2str(i) ' test'],'','')),
		columns = columns + 1;
		angle.tests = cat(2,angle.tests,[testname int2str(i)]);
	end;
end;

angle.assoc = {'SP F0 # Ach OT Response curve',...
		'SP F0 # Ach OT Blank Response',...
		'SP F0 # Ach OT Carandini Fit',...
		'SP F0 # Ach OT Fit Direction index blr'};
plotind = 1;

supersubplot(f,rows,columns,plotind);
hold off;
angleplotlist = [];
for i=1:length(angle.tests),
	t = findassociate(cell,[angle.tests{i} ' time'],'','');
	if i==1,
		t0 = t.data;
		tnow = 0;
	else,
		tnow = (t.data-t0)/(60*60); % use hours as units
	end;
	for j=1:2,
		angle_ = angle;
		if j==1,
			titlestr = [angle.tests{i} ' F0'];
			p=findassociate(cell,strrep(['SP F0 # Ach OT vec varies p'],'#',angle.tests{i}),'','');
            try,
    			dr = fit_dr_ratio(cell,[angle.tests{i}],'AssociateTestPrefix','SP F0 ');
            catch,
                dr = NaN;
            end;
		end;
		if j==2,
			for z=1:length(angle_.assoc),
				angle_.assoc{z}=strrep(angle_.assoc{z},'F0','F1');
			end;
			titlestr = [angle.tests{i} ' F1'];
			p=findassociate(cell,strrep(['SP F1 # Ach OT vec varies p'],'#',angle.tests{i}),'','');
			try,
                dr = fit_dr_ratio(cell,[angle.tests{i}],'AssociateTestPrefix','SP F1 ');
            catch,
                dr=NaN;
            end;
		end;
		supersubplot(f,rows,columns,plotind+(j-1)*columns);
		angleplotlist(j,i) = gca;
		plotgenerictuningcurve(cell,cellname,...
				strrep(angle_.assoc{1},'#',angle.tests{i}),...
				strrep(angle_.assoc{2},'#',angle.tests{i}),...
				strrep(angle_.assoc{3},'#',angle.tests{i}),...
				'angle',1,[0 360],[],'k','s');
		axis auto;
		di = findassociate(cell,strrep(angle_.assoc{4},'#',angle.tests{i}),'','');
		if ~isempty(di),
			distr = num2str(di.data,2);
		else,
			distr = '';
		end;
		distr = [distr ',' num2str(dr,2)];
		title({[angle.tests{i} ' ' distr],['sig=' num2str(p.data,2) ', t=' num2str(tnow,2)]},'interp','none');
		xlabel('Direction');
		if mod(plotind,columns)==1 & j==1,
			ylabel({cellname, 'Hz'},'interp','none');
		end;
	end;
	plotind = plotind + 1;
end;

matchaxes(angleplotlist(1,:),0,360,0,'close');
matchaxes(angleplotlist(2,:),0,360,0,'close');

ta=findassociate(cell,'Training Angle','','');
if ~isempty(ta),
	tt = findassociate(cell,'Training Type','','');
	if strcmp(lower(tt.data),'unidirectional') | strcmp(lower(tt.data),'bidirectional'),
		for i=1:numel(angleplotlist),
				axes(angleplotlist(i));
			addtrainingangleshade(ta.data);
			if strcmp(lower(tt.data),'bidirectional'),
				addtrainingangleshade(mod(ta.data+180,360));
			end;
		end;
	end;
end;


