function mp_plotalllengthfit(cellinfo, cellnames, varargin)
% MP_PLOTALLLENGTHFIT - Plot all of the length fit tuning curves
%
%  MP_PLOTALLLENGTHFIT(CELLINFO, CELLNAMES, ...)
%
%  Loops through all CELLINFO entries and creates a SUPERSUPPLOT
%  with all of the fits
%
%  This function also takes additional name/value pairs that 
%  modify the default behavior:
%  Parameter (default)     | Description
%  -----------------------------------------------------------
%  plotrows (3)            | Number of plot rows to use
%  plotcolumns (3)         | Number of plot columns to use
%  

plotrows = 3;
plotcolumns = 3;

assign(varargin{:});

fig = figure;

plotcount = 1;


 %  screen for responsive cells

max_firing_rate_criterion = 1;  % must be above this amount to be included
r_squared_criterion = -Inf;     % must be above this amount to be included

mygoodcells = []; % only include responsive cells
for i=1:length(cellinfo),
	if ~isempty(cellinfo(i).length_info.vis_resp_p),
		if (cellinfo(i).length_info.vis_resp_p < 0.05) & ( max(cellinfo(i).length_info.length_curve(2,4)) >  max_firing_rate_criterion),
			if cellinfo(i).lengthfit.outputs.r_squared > r_squared_criterion
				mygoodcells(end+1) = i;
			end;
		end;
	end;
end;

for i=1:length(mygoodcells),
	ax=supersubplot(fig,plotrows,plotcolumns,plotcount);

	index = mygoodcells(i);

	usexlabel = 0;
	useylabel = 0;

	col = mod(ceil(plotcount / plotrows), plotcolumns); % 0 will be bottom
	row = mod(plotcount,plotrows); % 0 will be left

	if col==0,
		usexlabel = 1;
	end;

	if row==0,
		useylabel = 1;
	end;

	mp_plotlengthfit(cellinfo(index),cellnames{index},'usexlabel',usexlabel,'useylabel',useylabel);

	plotcount = plotcount + 1;
end;

