function [CI,ncells] = calc_cluster_index(cell_pts, roi_pts, scale, inj_size, windsize, windstep, area_thresh, fract_cells)

% CALC_CLUSTER_INDEX - Calculate cluster index from Ruthazer and Stryker
%
%   CI = CALC_CLUSTER_INDEX(CELL_PTS, ROI_PTS, SCALE, INJ_SIZE, WINDSIZE,
%           WINDSTEP, AREA_THRESH, FRACT_CELLS)
%
%  Calculates the cluster index as described by Ruthazer and Stryker
%  JNeurosci 1996 16:7253-7269.
%
%  Computes the cluster index over a region of interest drawn tightly
%  around the data set excluding the injection site of size INJ_SIZE.  Square
%  windows of side size WINDSIZE are slid over the region of interest in
%  steps of WINDSTEP.  If the overlap of the window and the region of interest
%  is at least AREA_THRESH (a fraction of the total), then the cluster index
%  is computed in that window.
%
%  The cluster index is computed by comparing nearest neighbor differences
%  of all cells in the data set to a random point.  Only FRACT_CELLS are used
%  in the calculation.  See the paper for a more complete description.
%
%  The cells are specified as a list of X-Y pairs.  It is assumed that the first
%  entry in the list is actually the injection location, not a cell.
%  The region of interest is also specified by a list of X-Y pairs that
%  define a polygon around the region of interest.  The points will be scaled
%  by SCALE, which indicates the number of point units per unit.

roi_pts = roi_pts / scale;
cell_pts = cell_pts / scale;

CI = []; ncells = [];

mins = min(roi_pts); xmin=mins(1); ymin=mins(2);
maxs = max(roi_pts); xmax=maxs(1); ymax=maxs(2);

roi_pts_ = roi_pts(:,1)+roi_pts(:,2)*sqrt(-1);
cell_pts_ = cell_pts(:,1)+cell_pts(:,2)*sqrt(-1);

injvec = -1:1/50:1;
injpts_ = inj_size*(sin(2*pi*injvec)+sqrt(-1)*cos(2*pi*injvec))+cell_pts_(1);

cellinds = inside(cell_pts_(2:end),roi_pts_);
cell_pts_ = cell_pts_(cellinds+1);  % exclude pts not in roi & injection site
injpts = inside(cell_pts_,transpose(injpts_));
cell_pts_ = cell_pts_(setdiff(1:length(cell_pts_),injpts));

sqvec = 0:windsize/50:windsize;
[XX,YY] = meshgrid(sqvec,sqvec);
sqpts_ = reshape(XX+sqrt(-1)*YY,1,length(XX)*length(YY));

%  keyboard;  if threshold is lower, Ci goes up for tree shrew

for x=xmin:windstep:xmax-windsize,
	x,
	for y=ymin:windstep:ymax-windsize,
		% test to see if area overlap exceeds threshold for inclusion
		windowpts_ = sqpts_+[x+y*sqrt(-1)];
		k1 = inside(transpose(windowpts_),roi_pts_);
		k2 = inside(transpose(windowpts_),transpose(injpts_));
		%[x y], length(setdiff(k1,k2))/length(sqpts_),
		if length(setdiff(k1,k2))/length(sqpts_)>area_thresh,
			% if exceeds area threshold, we may continue
			%[x y], % print x and y for debugging
			windowbounds_ = [x+y*sqrt(-1) x+windsize+y*sqrt(-1) ...
				x+windsize+(y+windsize)*sqrt(-1) x+(y+windsize)*sqrt(-1)];
			windcellpts = inside(cell_pts_,transpose(windowbounds_));

			ncells(end+1) = length(windcellpts);
			CIavg = [];
			for z=1:10, % must repeat ten times and average
			randptlist_ = []; % make a list of random points in window
			while (length(randptlist_)<round(length(windcellpts)*fract_cells)),
				newrndpt_ = [rand+sqrt(-1)*rand]*windsize+[x+sqrt(-1)*y];
				if isempty(inside(newrndpt_,transpose(injpts_)))&~isempty(inside(newrndpt_,roi_pts_)),
					% point must be in roi and not in injection site
					randptlist_(end+1) = newrndpt_;
				end;
			end;
			% now compute CI using random points
			Xi = []; Wi = [];
			for r=1:length(randptlist_),
				[Xi(end+1),ind]=near_neighbor_dist(randptlist_(r),...
					cell_pts_(windcellpts));
				Wi(end+1)=near_neighbor_dist(cell_pts_(windcellpts(ind(1))),...
					cell_pts_(windcellpts));
			end;
			CIavg(end+1) = log(sum(Xi.*Xi)/sum(Wi.*Wi));
			end;  % 10 repeats over z
			CI(end+1) = nanmean(CIavg);
		end;
	end;
end;

function [d,ind] = near_neighbor_dist(pt, ptlist)
h = find(ptlist~=pt);
[d,mind] = min(abs(ptlist(h)-pt));
ind = h(mind);
