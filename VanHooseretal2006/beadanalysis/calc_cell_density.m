function [dens,density,density_pts] = calc_cell_density(cell_pts, roi_pts, scale, inj_size, gridsize, bins, binsize)

% CALC_CELL_DENSITY - Calculate peak cell density
%
%   DENS = CALC_CELL_DENSITY(CELL_PTS, ROI_PTS, SCALE, INJ_SIZE, GRIDSIZE,...
%       BINS,BINSIZE)
%
%  Calculates peak cell density as described by Ruthazer and Stryker
%  JNeurosci 1996 16:7253-7269.
%
%  Computes the peak cell density index over a region of interest drawn tightly
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

roi_pts_ = roi_pts(:,1)+roi_pts(:,2)*sqrt(-1);
cell_pts_ = cell_pts(:,1)+cell_pts(:,2)*sqrt(-1);

 % shift so injection site is 0,0
roi_pts_ = roi_pts_-cell_pts_(1);
cell_pts_ = cell_pts_-cell_pts_(1);

injvec = -1:1/50:1;
injpts_ = inj_size*(sin(2*pi*injvec)+sqrt(-1)*cos(2*pi*injvec))+cell_pts_(1);

cellinds = inside(cell_pts_(2:end),roi_pts_);
cell_pts_ = cell_pts_(cellinds+1);  % exclude pts not in roi & injection site
injpts = inside(cell_pts_,transpose(injpts_));
cell_pts_ = cell_pts_(setdiff(1:length(cell_pts_),injpts));

 %keyboard;  

density_pts = []; density = [];

 % compute density map

i = sqrt(-1);

xpos = 0;
while xpos<max(abs(real(roi_pts_))),
	ypos = 0;
	while ypos<max(abs(imag(roi_pts_))),
		% positive
		b_x = [ xpos-gridsize/2 xpos+gridsize/2];
		b_y = [ ypos-gridsize/2 ypos+gridsize/2]*i;
		inds = find( real(cell_pts_)>b_x(1)&real(cell_pts_)<=b_x(2)&...
			imag(cell_pts_)>b_y(1)&imag(cell_pts_)<b_y(2) );
		density(end+1)=length(inds)/(gridsize*gridsize);
		density_pts(end+1)=xpos+i*ypos;
		if ~((xpos==0)&(ypos==0)),
			b_x = [ -xpos-gridsize/2 -xpos+gridsize/2];
			b_y = [ -ypos-gridsize/2 -ypos+gridsize/2];
			inds = find( real(cell_pts_)>b_x(1)&real(cell_pts_)<=b_x(2)&...
				imag(cell_pts_)>b_y(1)&imag(cell_pts_)<b_y(2) );
			density(end+1)=length(inds)/(gridsize*gridsize);
			density_pts(end+1)=-xpos+i*(-ypos);
			b_x = [ -xpos-gridsize/2 -xpos+gridsize/2];
			b_y = [ ypos-gridsize/2 ypos+gridsize/2];
			inds = find( real(cell_pts_)>b_x(1)&real(cell_pts_)<=b_x(2)&...
				imag(cell_pts_)>b_y(1)&imag(cell_pts_)<b_y(2) );
			density(end+1)=length(inds)/(gridsize*gridsize);
			density_pts(end+1)=-xpos+i*(-ypos);
			b_x = [ xpos-gridsize/2 xpos+gridsize/2];
			b_y = [ -ypos-gridsize/2 -ypos+gridsize/2];
			inds = find( real(cell_pts_)>b_x(1)&real(cell_pts_)<=b_x(2)&...
				imag(cell_pts_)>b_y(1)&imag(cell_pts_)<b_y(2) );
			density(end+1)=length(inds)/(gridsize*gridsize);
			density_pts(end+1)=-xpos+i*(-ypos);
		end;
		ypos = ypos + gridsize;
	end;
	xpos = xpos + gridsize;
end;

% now evaluate density map to get peak densities
dens = [];

for r=1:length(bins),
	k=find( abs(density_pts)>(bins(r)-binsize/2)&abs(density_pts)<(bins(r)+binsize/2));
	if ~isempty(k), dens(end+1) = max(density(k)); else, dens(end+1) = 0; end;
end;

