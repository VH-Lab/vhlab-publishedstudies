function [finalDSI, maxDSI,finalup,finaldown, initialDSI, changeDSI] = sl_biasfigures


finalDSI = {};
maxDSI = {};
finalup = {};
finaldown = {};
initialDSI = {};
changeDSI = {};

filelist1 = {'ml13i','ml23i','ml33i','ml43i','ml53i'};  % bidirectional training with biases, with inhibition
filelist2 = {'ml1','ml2','ml3','ml4','ml5'};       % bidirectional training with biases, no inhibition
filelist3 = {'ml94i','ml84i','ml74i','ml64i','ml12i','ml22i','ml32i','ml42i','ml52i'};  % unidir training with biases, with inhibition
filelist4 = {'ml94','ml84','ml74','ml64','ml12','ml22','ml32','ml42','ml52'};  % unidir training with biases, with out inhibition

for i=[1 2 3 4],

	eval(['filelist = filelist' int2str(i) ';']);

	for j=1:length(filelist),
		if exist([filelist{j} '.mat'])==2,
			g = load([filelist{j} '.mat']);
			dsi = (g.out.r_up - g.out.r_down)./(g.out.r_up + g.out.r_down);
			finalDSI{i}(j) = dsi(end);
			maxDSI{i}(j) = max(dsi);
			finalup{i}(j) = g.out.r_up(end);
			finaldown{i}(j) = g.out.r_down(end);
			initialDSI{i}(j) = dsi(1);
			changeDSI{i}(j) = finalDSI{i}(j) - initialDSI{i}(j);
		end;
	end;

end;

 % individual plots

files = [2 1 ; 2 5 ; 1 1 ; 1 2; 1 3; 1 4 ; 3 1 ; 3 2];
indiv_titles = {...
	'Unbiased bidirectional w/o inhibition',...
	'Biased bidirectional w/o inhibition',...
	'Unbiased bidirectional w inhibition',...
	'Slight Biased bidirectional w inhibition',...
	'More Biased bidirectional w inhibition',...
	'Very Biased bidirectional w inhibition'...
	'Very Biased opposite unidirectional w inhibition'...
	'less Biased opposite unidirectional w inhibition'...
	 };
	

for i=1:size(files,1),
	filename = eval(['filelist' int2str(files(i,1)) '{' int2str(files(i,2)) '};']);
	g = load(filename);
	figure;
	sl_dsiovertime(g.out, indiv_titles{i});
end;

 % summary data

thetitles = {'BI w/Inhib', 'BI w/o Inhib','UNI w/Inhib','UNI w/o Inhib'};

for i=[1 2],
	figure;
	subplot(3,1,1);
	plot([-4 4],[0 0],'k--');
	hold on;
	plot([-4 -3 -2 -1 0 1 2 3 4],[-1 -1 -1 -1 1 1 1 1 1].*finalDSI{i}([5:-1:2 1:5]),'ko');
	xlabel('Simulation');
	ylabel('Final DSI');
	axis([-5 5 -1 1]);
	box off;
	title(thetitles{i});

	subplot(3,1,2);
	plot([-4 4],[0 0],'k--');
	hold on;
	plot([-4 -3 -2 -1 0 1 2 3 4],[-1 -1 -1 -1 1 1 1 1 1].*changeDSI{i}([5:-1:2 1:5]),'ko');
	xlabel('Simulation');
	ylabel('Change in DSI');
	axis([-5 5 -1 1]);
	box off;
end;

for i=[3 4],
	figure;
	title(thetitles{i});
	subplot(3,1,1);
	plot([-4 -3 -2 -1 0 1 2 3 4],finalDSI{i},'o');
	xlabel('Simulation');
	ylabel('Final DSI');
	box off;

	subplot(3,1,2);
	plot([-4 -3 -2 -1 0 1 2 3 4],changeDSI{i},'o');
	xlabel('Simulation');
	ylabel('Change in DSI');
	box off;
end;


