function output = neildir_analysis(prefix, expernames)
% NEILDIRANALYSIS - analyzing direction training data for K-L stims
%
%  OUTPUT = NEILDIR_ANALSYS(PREFIX, EXPERNAMES)
%
%  Reads analysis data from series of directories and performs the following analysis
%  1) Identifies all cells that exhibit significant visual responses at the initial
%     recording ('PreDir4Hz') OR the final recording ('PostDir4Hz') (you might want to
%     alter this criteria depending upon the question being asked).
%  2) Plots the before and after tuning curves of all of these cells
%  3) Makes a scatter plot of the direction index value before and after training
%
%  PREFIX should be the directory where all of the experiment directories sit, e.g., 
%     '/Volumes/Data2/myexperiments/'
%  EXPERNAMES should be a cell list of the experiment directories; e.g., 
%     {'2013-10-07','2013-10-10','2013-10-21'}
%  
%  OUTPUT is a structure with the workspace of the function (all of the variables that
%  were created in this function).
%
%  Example:
%    prefix = '/Volumes/Data2/arani_phase_training/electrophys/';
%    expernames = {'2013-09-19'};
%    output = neildir_example(prefix,expernames);
%

 % Step 0) Read in all of the cells

[cells,cellnames,experindex] = readcellsfromexperimentlist(prefix,expernames);

 % Step 1) Identify all cells with significant F0 responses

goodcells = [];
test1 = 'PreDir4Hz';
test2 = 'Dir4Hz3';

for i=1:length(cells),
	goodresp_assoc1 = findassociate(cells{i},...
			['SP F0 ' test1 ' Ach OT visual response p'],'','');
	goodresp_assoc2 = findassociate(cells{i},...
			['SP F0 ' test2 ' Ach OT visual response p'],'','');
	if 0 || (~isempty(goodresp_assoc1) || ~isempty(goodresp_assoc2)),
		if 1 || goodresp_assoc1.data<0.05 || goodresp_assoc2.data<0.05,
			goodcells(end+1) = i; % include this one
		end;
	end;
end;

 % now, restrict to only good cells
cells = cells(goodcells);
cellnames = cellnames(goodcells); 

disp(['Found ' int2str(length(goodcells)) ' cells that meet the criteria.']);

 % Step 2) Plot all tuning curves
fig = figure;
M = 4;
N = 4;

p = 1;

for i=1:length(cells),
	ax1=supersubplot(fig,M,N,p);
	plotdirtuning_testdir(cells{i},cellnames{i},['SP F0 ' test1 ' Ach ']);
	ax2=supersubplot(fig,M,N,p+1);
	plotdirtuning_testdir(cells{i},cellnames{i},['SP F0 ' test2 ' Ach '],'FitPlotColor','b',...
		'PlotColor','b');
	title(['After training']);
	box off;
	% put on same axes
	ylim1 = get(ax1,'ylim');
	ylim2 = get(ax2,'ylim');
	ylim = [min(ylim1(1),ylim2(1)) max(ylim1(2),ylim2(2))];
	set(ax1,'ylim',ylim);
	set(ax2,'ylim',ylim);
	p = p + 2; % move super-subplot up by 2
end;

  
 % Step 3) Make a scatter plot
DI_before = [];
DI_after = [];

for i=1:length(cells),
	DIb_associate = [];
	try,
		DIb_associate.data = neil_dr_ratio(cells{i},test1);
	end;
	if isempty(DIb_associate),
		DI_before(end+1) = NaN;
	else,
		DI_before(end+1) = DIb_associate.data;
	end;
	DIa_associate = [];
	try,
		DIa_associate.data = neil_dr_ratio(cells{i},test2);
	end;
	if isempty(DIa_associate),
		DI_after(end+1) = NaN;
	else,
		DI_after(end+1)  = DIa_associate.data;
	end;
end;

figure;
plot([0 1],[0 1],'k--'); % unity line
hold on;
plot(DI_before,DI_after,'ko');
xlabel(['DI ' test1]);
ylabel(['DI ' test2]);
title(['DI before and after training']);
box off;

output = workspace2struct;
