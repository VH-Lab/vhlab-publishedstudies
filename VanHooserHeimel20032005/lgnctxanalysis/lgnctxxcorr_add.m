function [newcell,outstr,assoc]=lgnctxxcorr_add(cksds,extcellname1,extcellname2,...
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
T0 = -0.100; T1 = 0.100; % time interval to examine
dt = 1e-3;               % time resolution
xcorrbins = T0:dt:T1;
cell1= load(getexperimentfile(cksds),extcellname1,'-mat');
extcell1= getfield(cell1,extcellname1);
cell2= load(getexperimentfile(cksds),extcellname2,'-mat');
extcell2= getfield(cell2,extcellname2);


stimtriglist = {};
len = []; 
for i=1:length(testlist),
	stimtime=getstimscripttimestruct(cksds,testlist{i});
	switch class(get(stimtime.stimscript,1)),
	case 'periodicstim',
		do = getDisplayOrder(stimtime.stimscript);
		for i=1:numStims(stimtime.stimscript),
			stiminds = find(do==i);
			newln = []; stimtrigs = [];
			for j=1:length(stiminds),
				stimtrigs(end+1)=stimtime.mti{stiminds(j)}.frameTimes(1);
				mndf = mean(diff(stimtime.mti{stiminds(j)}.frameTimes));
				newln(end+1) = stimtime.mti{stiminds(j)}.frameTimes(end)-...
					stimtime.mti{stiminds(j)}.frameTimes(1)+mndf;
			end;
			if min(newln)>0, len = [len newln]; end; % check for bad stims
			stimtriglist{end+1} = stimtrigs;
		end;
	case 'stochasticgridstim',
		if 0, % exclude it, need to update this code
		for j=1:length(stimtime.mti),
			for i=1:length(stimtime.mti{j}.frameTimes),
				stimtrigs(end+1)=stimtime.mti{j}.frameTimes(i);
				len(end+1)=mean(diff(stimtime.mti{j}.frameTimes));
			end;
		end;
		end;
    end;
end;
% now we have the triggers

xcorr = []; xcovar = []; xstddev = []; expect = []; 
 % compute weighted variance for standard deviation

tottrigs = 0;

for i=1:length(stimtriglist),
	tottrigs = tottrigs + length(stimtriglist{i});
	[xcorrt,xcovart,xstddevt,expectt]=spikecrosscorrelation(extcell1,extcell2,...
		xcorrbins,min(stimtriglist{i})+T0,max(stimtriglist{i})+T1,stimtriglist{i},0,min(len));
	if isempty(xcorr),
		xcorr=xcorrt;
		xcovar=xcovart*length(stimtriglist{i});
		if 0,
			xstddev=length(stimtriglist{i})*xstddevt.^2; % add as variance option
		else, xstddev =length(stimtriglist{i})*xstddevt; % just compute avg stddev, this is right
		end;
		expect = expectt*length(stimtriglist{i});
	else,
		xcorr=xcorr+xcorrt; xcovar=xcovar+xcovart*length(stimtriglist{i});
		if 0,
			xstddev=xstddev+length(stimtriglist{i})*xstddevt.^2;
		else,xstddev=xstddev+length(stimtriglist{i})*xstddevt;
		end;
		expect = expect+expectt*length(stimtriglist{i});
	end;
end;

if 0, xstddev = sqrt(xstddev/tottrigs); % convert to standard deviation
else, xstddev = xstddev/tottrigs;
end;
xcovar = xcovar/tottrigs;

if nargin>4&draw,
	h = figure;
	hold off;
	subplot(2,2,1);
	bar(xcorrbins,xcorr,'b');
	title([extcellname1 ' x ' extcellname2],'interpreter','none');
	xlabel('Time (s)'); ylabel('Spike counts');
	subplot(2,2,2);
	hold off;
	bar(xcorrbins,xcovar);
	hold on;
	plot(xcorrbins,-4*abs(xstddev),'b'); plot(xcorrbins,4*abs(xstddev),'b');
	title('Covariogram with 4 sigma');
	xlabel('Time (s)'); ylabel('Spikes-expected');
	subplot(2,2,3);
	bar(xcorrbins,expect);
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
