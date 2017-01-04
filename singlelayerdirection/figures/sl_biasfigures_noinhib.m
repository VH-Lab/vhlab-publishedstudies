function [finalDSI, maxDSI,finalup,finaldown, initialDSI, changeDSI] = sl_biasfigures_noinhib(individs, summaries)

if nargin==0,
	individs = 1;
	summaries = 1;
end;


finalDSI = {};
maxDSI = {};
finalup = {};
finaldown = {};
initialDSI = {};
changeDSI = {};

stims_per_sim = [ 20 1; 20 1; 20 1; 20 1; 1 1];

prefixes = {'/Volumes/Data2/singlelayermodel/bias_inhib/', '/Volumes/Data2/singlelayermodel/triplet4/'};
prefix = [ 2 1 2 1 2 2 2 2 2 2 2 2 2 2];

filelist1 = {'mla813','mla812','mla811','mla810','mla87','mla86','mla84','mla85','mla88'};  % bidirectional training with biases, stdp 20 DONE
filelist2 = {'ml1','ml2','ml3','ml4','ml5'};       % bidirectional training with biases stdp 1 DONE
filelist3 = {'mla613','mla612','mla611','mla610','mla67','mla66','mla64','mla65','mla68'};  % unidir training with biases, stdp 20 DONE
filelist4 = {'ml94','ml84','ml74','ml64','ml12','ml22','ml32','ml42','ml52'};  % unidir training with biases stdp1 DONE
filelist5 = {'ml513','ml512','ml511','ml510','ml57','ml56','ml54','ml55','ml58'};  % bidirectional training with biases, triplet 20 DONE
filelist6 = {'ml8813','ml8812','ml8811','ml8810','ml887','ml886','ml884','ml885','ml888'};       % bidirectional training with biases triplet 1 DONE
filelist7 = {'ml613','ml612','ml611','ml610','ml67','ml66','ml64','ml65','ml68'};  % unidir training with biases, triplet 20 DONE
filelist8 = {'ml8613','ml8612','ml8611','ml8610','ml867','ml866','ml864','ml865','ml868'};  % unidir training with biases , triplet 1 DONE
filelist9 = {'ml8813k','ml8812k','ml8811k','ml8810k','ml887k','ml886k','ml884k','ml885k','ml888k'};       % bidirectional training with biases triplet 20 DONE
filelist10 = {'ml8613k','ml8612k','ml8611k','ml8610k','ml867k','ml866k','ml864k','ml865k','ml868k'};  % unidir training with biases , triplet 20 DONE

for i=[1:10],

	eval(['filelist = filelist' int2str(i) ';']);

	for j=1:length(filelist),
		if exist([prefixes{prefix(i)} filelist{j} '.mat'])==2,
			g = load([prefixes{prefix(i)} filelist{j} '.mat']);
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

files = [5 1 ; 5 5 ; 5 6; 5 7; 5 9 ; 6 1; 6 5; 6 9 ; 8 2 ; 8 5; 7 5; 10 2; 9 7; 10 1; 10 9];
indiv_titles = {...  % need renaming
	'Triplet 20, negative bias',...
	'Triplet 20, no bias',...
	'Triplet 20, positive bias',...
	'Triplet 20, positive bias',...
	'Triplet 20, positive bias',...
	'Triplet 1, negative bias',...
	'Triplet 1, no bias',...
	'Triplet 1, positive bias',...
	'Triplet1, less negative bias',...
	'Triplet1, uni no bias', ...
	'Triplet20, uni no bias',...
	'Triplet20, uni less negative bias inhib',...
	'Triplet20, inhib bi positive bias',...
	'Triplet20, inhib neg bias',...
	'Triplet20, inhib pos bias'};
	
if individs,
	for i=1:size(files,1),
		filename = eval(['filelist' int2str(files(i,1)) '{' int2str(files(i,2)) '};']);
		g = load([prefixes{prefix(files(i,1))} filename '.mat']);
		figure;
		sl_dsiovertime(g.out, indiv_titles{i});
	end;
end;

 % summary data

thetitles = {'BIbias STDP20', 'BIbias STDP1','UNIbias STDP20','UNIbias STDP1','BIbias TRIP20', 'BIbias TRIP1','UNIbias TRIP20','UNIbias TRIP1','BIbias inhib TRIP20','Unibias inhib TRIP20'};
full = [1 0 1 1 1 1 1 1 1 1 ];

if summaries,
for i=1:10,
   if ~full(i), % show -1 inverted for negative bias
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
end;

for i=1:10,
   if full(i),
	figure;
	subplot(3,1,1);
	plot([-4 4],[0 0],'k--');
	hold on;
	plot([-4 -3 -2 -1 0 1 2 3 4],finalDSI{i},'ko');
	xlabel('Simulation');
	ylabel('Final DSI');
	box off;
	axis([-5 5 -1 1]);
	title(thetitles{i});

	subplot(3,1,2);
	plot([-4 4],[0 0],'k--');
	hold on;
	plot([-4 -3 -2 -1 0 1 2 3 4],changeDSI{i},'ko');
	xlabel('Simulation');
	ylabel('Change in DSI');
	axis([-5 5 -1 1]);
	box off;
   end;
end;
end;


