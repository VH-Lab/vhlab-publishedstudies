function [newcell,outstr,assoc]=lgnctxxcorr(cksds,extcellname1,extcellname2,...
		testlist,draw)

% LGNCTXXCORR Do extracellular/extracellular cross-correlation
%
% [NEWEXTCELL1,OUTSTR,ASSOC]=LGNCTXXCORR(CKSDS,EXTCELL1,EXTCELL2,TESTLIST,[DRAW])
%
%  Analyzes correlations between two extracellularly recorded spike data objects
%  stored in the experiment file of CKSDS with names EXTCELL1 and EXCTCELL2.
%  Only data for the tests in TESTLIST (a cell list of strings) are included
%  in the correlations.  If DRAW is 1, the result is drawn in a new figure.
%
%  See also:  SPIKEDATA, CKSDIRSTRUCT, GETEXPERIMENTFILE

 % constants
T0 = -0.020; T1 = 0.020; % time interval to examine
dt = 1e-3;               % time resolution
xcorrbins = T0:dt:T1;
cell1= load(getexperimentfile(cksds),extcellname1,'-mat');
extcell1= getfield(cell1,extcellname1);
cell2= load(getexperimentfile(cksds),extcellname2,'-mat');
extcell2= getfield(cell2,extcellname2);

xcorr = {}; xcovar={}; xstddev={};expect = {}; Ntrials = [];

for i=1:length(testlist),
	stimtime=getstimscripttimestruct(cksds,testlist{i});
	switch class(get(stimtime.stimscript,1)),
	case 'periodicstim',
		do = getDisplayOrder(stimtime.stimscript);
		stimlist = unique(do);
		for i=1:length(stimlist),
			stimtrigs = []; len = [];
			stiminds = find(do==stimlist(i));
			for j=1:length(stiminds),
				stimtrigs(j)=stimtime.mti{stiminds(j)}.frameTimes(1);
			    mndf = mean(diff(stimtime.mti{stiminds(j)}.frameTimes));
				len(end+1) = stimtime.mti{stiminds(j)}.frameTimes(end)-...
					stimtime.mti{stiminds(j)}.frameTimes(1)+mndf;
			end;
			Ntrials(end+1)=length(stimtrigs);
			[xcorr{end+1},xcovar{end+1},xstddev{end+1},expect{end+1}]=...
				spikecrosscorrelation(extcell1,extcell2,...
				xcorrbins,min(stimtrigs)+T0,max(stimtrigs)+T1,stimtrigs,0,min(len));
		end;
	case 'stochasticgridstim',
		stimtrigs = []; len = [];
		for j=1:length(stimtime.mti),
			for i=1:length(stimtime.mti{j}.frameTimes),
				stimtrigs(end+1)=stimtime.mti{j}.frameTimes(i);
				len(end+1)=mean(diff(stimtime.mti{j}.frameTimes));
			end;
		end;
		Ntrials(end+1)=length(stimtrigs);
		[xcorr{end+1},xcovar{end+1},xstddev{end+1},expect{end+1}]=...
			spikecrosscorrelation(extcell1,extcell2,...
			xcorrbins,min(stimtrigs)+T0,max(stimtrigs)+T1,stimtrigs,0,min(len));
    end;
end;

xcorr_sum=xcorr{1}; xcovar_sum = xcovar{1};
xstddev_val=xstddev{1}*(Ntrials(1)^(1.5))/sum(Ntrials); expect_sum=expect{1};
for i=2:length(xcorr),
	xcorr_sum=xcorr_sum+xcorr{i};
	xcovar_sum=xcovar_sum+xcovar{i};
	xstddev_val=xstddev_val+(Ntrials(i)^(1.5))*xstddev{i}/sum(Ntrials);
	expect_sum=expect_sum+expect{i};
end;

xstddev_val = xstddev_val;

if nargin>4&draw,
	h = figure;
	hold off;
	subplot(2,2,1);
	bar(xcorrbins,xcorr_sum,'b');
	title([extcellname1 ' x ' extcellname2],'interpreter','none');
	xlabel('Time (s)'); ylabel('Spike counts');
	subplot(2,2,2);
	hold off;
	bar(xcorrbins,xcovar_sum);
	hold on;
	plot(xcorrbins,-2*abs(xstddev_val),'b'); plot(xcorrbins,2*abs(xstddev_val),'b');
	title('Covariogram with 2sigma');
	xlabel('Time (s)'); ylabel('Spikes-expected');
	subplot(2,2,3);
	bar(xcorrbins,expect_sum);
	title('Expected correlation/trial');
	xlabel('Time (s)');ylabel('Spikes/trial');
end;

newcell=extcell1;
assoc = [];
outstr.xcorr = xcorr;
outstr.xcovar= xcovar;
outstr.xstddev= xstddev;
outstr.expect= expect;
outstr.xcorrbins = xcorrbins;
