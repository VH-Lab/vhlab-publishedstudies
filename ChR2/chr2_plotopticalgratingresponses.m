function chr2_plotgratingresults(cell, cellname)
% CHR2_PLOTGRATINGRESULTS - Plot results of optical and visual stimulation
%
%  CHR2_PLOTGRATINGRESULTS(CELL, CELLNAME)
%
%  For optical stimulation: plots brightness, spatial and temporal frequency
%  responses.
%

f = figure;

rows = 3;

bright.tests = {{'PreOPBrWhFld','PreOPBrBlFld'},...
			{'PostOPBrWhFld','PostOPBrBlFld'}, ...
			{'PreOPBrWhGr','PreOPBrBlGr'}, ...
			{'PostOPBrWhGr','PostOPBrBlGr'} };
bright.assoc = {'SP F0 # CT Response curve',...
		'SP F0 # CT Blank Response',...
		'SP F0 # CT NK Fit'};
bright.colors = { {'k','b'}, {'k', 'b'} ,{'k','b'},{'k','b'}};

plotind = 1;

supersubplot(f,rows,4,plotind);
hold off;
brightplotlist = [];
for i=1:length(bright.tests),
	supersubplot(f,rows,4,plotind);
	brightplotlist(end+1) = gca;
	for j=1:length(bright.tests{i}),
		plotgenerictuningcurve(cell,cellname,...
			strrep(bright.assoc{1},'#',bright.tests{i}{j}),...
			strrep(bright.assoc{2},'#',bright.tests{i}{j}),...
			strrep(bright.assoc{3},'#',bright.tests{i}{j}),...
			'Brightness',1,[0 1],[],bright.colors{i}{j},'s');
		axis auto;
		t = findassociate(cell,[bright.tests{i}{j} ' time'],'','');
		title(bright.tests{i}{j});
		xlabel('Brightness');
		if mod(plotind,4)==1,
			ylabel('Hz');
		end;
	end;
	plotind = plotind + 1;
end;

matchaxes(brightplotlist,0,1,0,'close');

tf.tests = {'TFOP1','TFOP1', 'TFOP2','TFOP2'};
if isempty(findassociate(cell,'SP F0 TFOP1 TF High TF','','')) & ...
	~isempty(findassociate(cell,'SP F0 TFOP1 Ach TF High TF','','')),
	for i=1:length(tf.tests),
		tf.tests{i} = cat(2,tf.tests{i},' Ach');
	end;
end;
tf.assoc = {'SP F0 # TF Response curve',...
		'SP F0 # TF Blank Response',...
		'SP F0 # TF NK Fit'}; % will return no fit
tf.colors = { 'k','k', 'k', 'k' };

tfplotlist = [];
for i=1:length(tf.tests),
	supersubplot(f,rows,4,plotind);
	tfplotlist(end+1) = gca;
	tf_ = tf;
	if mod(i,2)==0,
		for j=1:length(tf_.assoc),
			tf_.assoc{j} = strrep(tf_.assoc{j},'F0','F1');
		end;
		title_str = [tf.tests{i} ' F1'];
	else,
		title_str = [tf.tests{i} ' F0'];
	end;
	plotgenerictuningcurve(cell,cellname,...
		strrep(tf_.assoc{1},'#',tf_.tests{i}),...
		strrep(tf_.assoc{2},'#',tf_.tests{i}),...
		strrep(tf_.assoc{3},'#',tf_.tests{i}),...
		'tFrequency',1,[0 12],[],tf_.colors{i},'s');
	axis auto;
	xlabel('tFrequency');
	t = findassociate(cell,[tf.tests{i} ' time'],'','');
	title(title_str);
	if mod(plotind,4)==1,
		ylabel({cellname,'Hz'},'interp','none');
	end;
	plotind = plotind + 1;
end;

matchaxes(tfplotlist,0,12,0,'close');


sf.tests = {'SFOP4Hz1','SFOP4Hz1', 'SFOP4Hz2','SFOP4Hz2'};
if isempty(findassociate(cell,'SP F0 SFOP4Hz1 SF High SP','','')) & ...
	~isempty(findassociate(cell,'SP F0 SFOP4Hz1 Ach SF High SP','','')),
	for i=1:length(sf.tests),
		sf.tests{i} = cat(2,sf.tests{i},' Ach');
	end;
end;
if isempty(findassociate(cell,['SP F0 ' sf.tests{1} ' SF High SP'],'','')), % try 2Hz
	sf.tests = {'SFOP2Hz1','SFOP2Hz1', 'SFOP2Hz2','SFOP2Hz2'};
	if isempty(findassociate(cell,'SP F0 SFOP2Hz1 SF High SP','','')) & ...
		~isempty(findassociate(cell,'SP F0 SFOP2Hz1 Ach SF High SP','','')),
		for i=1:length(sf.tests),
			sf.tests{i} = cat(2,sf.tests{i},' Ach');
		end;
	end;
end;

sf.assoc = {'SP F0 # SF Response curve',...
		'SP F0 # SF Blank Response',...
		'SP F0 # SF NK Fit'}; % will return no fit
sf.colors = { 'k','k', 'k', 'k' };

sfplotlist = [];
for i=1:length(sf.tests),
	supersubplot(f,rows,4,plotind);
	sfplotlist(end+1) = gca;
	sf_ = sf;
	if mod(i,2)==0,
		for j=1:length(sf_.assoc),
			sf_.assoc{j} = strrep(sf_.assoc{j},'F0','F1');
		end;
		title_str = [sf.tests{i} ' F1'];
	else,
		title_str = [sf.tests{i} ' F0'];
	end;
	plotgenerictuningcurve(cell,cellname,...
		strrep(sf_.assoc{1},'#',sf_.tests{i}),...
		strrep(sf_.assoc{2},'#',sf_.tests{i}),...
		strrep(sf_.assoc{3},'#',sf_.tests{i}),...
		'sFrequency',1,[0 0.1],[],sf_.colors{i},'s');
	axis auto
	xlabel('sFrequency');
	t = findassociate(cell,[sf.tests{i} ' time'],'','');
	title(title_str);
	if mod(plotind,4)==1,
		ylabel('Hz');
	end;
	plotind = plotind + 1;
end;

matchaxes(sfplotlist,0,0.1,0,'close');

return;

dir.tests = {'SFOP4Hz1','SFOP4Hz1', 'SFOP4Hz2','SFOP4Hz2'};
if isempty(findassociate(cell,'SP F0 SFOP4Hz1 SF High SP','','')) & ...
	~isempty(findassociate(cell,'SP F0 SFOP4Hz1 Ach SF High SP','','')),
	for i=1:length(sf.tests),
		sf.tests{i} = cat(2,sf.tests{i},' Ach');
	end;
end;
sf.assoc = {'SP F0 # SF Response curve',...
		'SP F0 # SF Blank Response',...
		'SP F0 # SF NK Fit'}; % will return no fit
sf.colors = { 'k','k', 'k', 'k' };

sfplotlist = [];
for i=1:length(sf.tests),
	supersubplot(f,rows,4,plotind);
	sfplotlist(end+1) = gca;
	sf_ = sf;
	if mod(i,2)==0,
		for j=1:length(sf_.assoc),
			sf_.assoc{j} = strrep(sf_.assoc{j},'F0','F1');
		end;
		title_str = [sf.tests{i} ' F1'];
	else,
		title_str = [sf.tests{i} ' F0'];
	end;
	plotgenerictuningcurve(cell,cellname,...
		strrep(sf_.assoc{1},'#',sf_.tests{i}),...
		strrep(sf_.assoc{2},'#',sf_.tests{i}),...
		strrep(sf_.assoc{3},'#',sf_.tests{i}),...
		'sFrequency',1,[0 0.1],[],sf_.colors{i},'s');
	axis auto
	xlabel('sFrequency');
	t = findassociate(cell,[sf.tests{i} ' time'],'','');
	title(title_str);
	if mod(plotind,4)==1,
		ylabel('Hz');
	end;
	plotind = plotind + 1;
end;

matchaxes(sfplotlist,0,0.1,0,'close');






