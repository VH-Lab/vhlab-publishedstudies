function [im,scalebaraxes,scalebarimage]=pvcontinuousmapOD(dirname,channel,cells,cellnames,indexassoc,funcstring,steps,plotit, varargin)

%  PVCONTINUOUSMAP - Produces a colored map of responses
%  IM=PVCONTINUOUSMAP(DIRNAME_OR_SIZE,CHANNEL,CELLS,CELLNAMES,INDEXASSOC,...
%                FUNCSTRING,STEPS,PLOTIT, ...);
%
%    Generates a color map of neural responses.
%
%  DIRNAME_OR_SIZE_OR_IMAGE determines the background image.  If the variable
%  is a character string, it is assumed to be the name of a directory, and a
%  preview image based on the first 50 data frames is generated from this
%  data.  If it is a [SIZE_Y SIZE_X], then the background will be black but have
%  size SIZE_Y x SIZE_X.  Or, it can be an image of gray values.
%
%  CHANNEL is the channel to be read.
%
%  CELLS is a cell list of measureddata objects.  CELLNAMES is a cell
%  list of strings with the names of these objects.
%
%  INDEXASSOC is associate type to plot (e.g., 'OT Fit Pref').
%
%  FUNCSTRING can be a string describing a mathematical manipulation
%     of the index value.  In the string, 'x' is the value of the
%     index read from the cell.  For example, 'mod(x,180)' will
%     give the index value modulo 180.  FUNCSTRING can also be
%     [] if no manipulation is desired.
%
%  STEPS are the values to colorize (e.g., 1:1:180 for
%     1 to 180 in steps of 1)
%
%  If PLOTIT is 1 data are plotted in a new window. 
%
%  Extra variables can be added as name / value pairs:
%   (e.g., 'pvalueassoc','OT visual response p')
%
%  PVALUEASSOC is an associate type that contains a P value
%     for deciding whether or not to include a given point.
%     If it is empty
%
%  PVALUE is the cut-off P value (default is 0.05).
%
%  The user has the option of describing the shape of each cell.
%  by passes the SYMBOL argument, which should be a
%  1xLENGTH(CELLS) vector. If SYMBOL(I) is 
%     0     then the cell's shape is filled in 
%     1     a circle of radius SYMBOLSIZE is drawn
%     2     a square with size 2*SYMBOLSIZE is drawn
%  If SYMBOL is not provided, then cell shapes are drawn.
%
%  SYMBOLSIZE must be given if any member of SYMBOL is not 0.
%    It corresponds to the size of each symbol.  It must be
%    NxLENGTH(CELLS).
%
%  COLOR is an optional list of colors to use for the cells.  It is a 
%    LENGTH(CELLS)x3 matrix.  If [-1 -1 -1] is passed, then the cell
%    is colorized according to its index value.  If any other value
%    is passed, then that color is used for the cell.  Color values are
%    RGB with values ranging from 0 to 1.
%
%  ROTATE is an optional argument for rotating the image either 0 or 90
%    degrees.  (Default 90 degrees)
%
%  CTAB is the color table to be used.  Should be the same number of rows
%    as the length of STEPS.  (Default fitzlabclut(length(steps)))
%
%  SCALEBARTICKS - Step index values to be labeled in the scale bar.
%    Default every tenth value.



scalebaraxes = []; scalebarimage = [];

if nargin==0,  % it is the buttondownfcn
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
    
	pt = pt(1,[1 2]); % get 2D proj
	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.pts,1),1)-ud.pts).^2')'),0);
    %keyboard;
	if v<50,
		if ~isempty(ud.cellnames{i}),
			disp(['Closest cell is ' ud.cellnames{i} ' w/ value ' num2str(ud.values(i))...
                'w/' 'pt:' ' [' num2str(pt(1)) ',' num2str(pt(2)) '] and [i,v]:'  ' [' num2str(i) ',' num2str(v) ']' ]);
		else,
			disp(['Closest cell is # ' int2str(i) ' w/ value ' num2str(ud.values(i))...
                 'w/' 'pt:' ' [' num2str(pt(1)) ',' num2str(pt(2)) '] and [i,v]:'  ' [' num2str(i) ',' num2str(v) ']' ]);  
		end;
        ud.indexassoc;
        figure;
        myargs = {};
        plottpresponseOD(ud.cells{i},ud.cellnames{i},ud.indexassoc,1,1,ud.varargin{:});
	end;

	return;
end;
numcolors = length(steps);
pvalueassoc='OT visual response p';
pvalue = 0.05;
symbol = zeros(1,length(cells));
cols = -1 * ones(length(cells),3);
rotate = 0;
ctab = fitzlabclut(numcolors);
scalebarticks = 1:10:length(steps);
transparency = 0;
arrow_thickness = 0.15;
arrow_radius = 0.75;
arrow_theta = pi/3;
arrow_length=0.33*cos(30*pi/180);
circle_inner_thickness = 0.12;
circle_outer_thickness = 0.15;
line_thickness = 0.2;
preferred_dir_color = [1 0 0];
opposite_dir_color = [0 1 0];
center_dir_color = [1 1 1];
background_dir_color = [0 0 0];

orthogonal_line_color = [ 0 1 0 ];
direction_line_color = [ 0 1 0 ];

image_background_color = 0;

assign(varargin{:});

if length(symbolsize)==1,
	symbolsize = symbolsize * ones(1,length(cells));
end;

symb = symbol;

%if exist('color','var'), cols = color; end;
if exist('colors','var'), cols = colors; end;

if ischar(dirname),
	%im1 = previewprairieview(dirname,50,1,1);
	%g = load('E:\yli\Copy of 2008-01-25\analysis\scratch\site 1_t00003_SC2','-mat');
    %g = load('E:\yli\2009-12-07\analysis\scratch\Site2_t00010_SC2','-mat');
    g = load('E:\yli\2009-12-28\analysis\scratch\Site 1_t00002_SC2','-mat');
    images = [];
    for  i = 1:length(g.indimages),images(:,:,i) = cell2mat(g.indimages(i));end;
    im1 = images(:,:,4);
    im1 = rescale(im1,[min(min(im1)) max(max(im1))-1000],[0 1]);
elseif length(dirname)==2,   im1 = image_background_color+zeros(dirname(2),dirname(1));
else,
	im1 = dirname;
	im1 = rescale(double(im1),[min(min(im1)) max(max(im1))],[0 1]);
end;
%keyboard
im2 = im1; im3 = im1;

sz = size(im1); im0 = zeros(size(im1));
[blank_x,blank_y] = meshgrid(1:sz(2),1:sz(1));

index = [];

pts = [];  inclpts = []; values = [];
%keyboard;
for i=1:length(cells),
	pva = []; incl = 1;
	inda = findassociate(cells{i},indexassoc,'','');
	if ~isempty(pvalueassoc),
		pva = findassociate(cells{i},pvalueassoc,'','');
		incl = 0;
		if ~isempty(pva),
			incl = pva.data <= pvalue;
		end;
	end;
	pixelindsa = findassociate(cells{i},'pixelinds','','');

	if isempty(pixelindsa),
		warning(['Cell ' int2str(i) ' does not have associate ''pixelinds''.']);
		incl = 0;
	end;
	if incl, 
		x = inda.data;
		if ~isempty(funcstring),
			x=eval(funcstring);
		end;
		values(end+1) = x;  % next line x has new meaning
		[xyz]=tpgetcellposition(cells{i});
		if ischar(dirname),
        x = xyz(1); y=xyz(2); 
        %2009-12-07:t00013: x:-20,y:-20;t00010: x:-20,y:-20       
        %2008-01-25:before: x:-12,y:-17;after: x:-15,y:-18
        else x = xyz(1); y=xyz(2);
        end;
        mycellnumber = str2num(cellnames{i}(13:15));
        if 0,
            if mycellnumber == 269||mycellnumber == 53||mycellnumber == 248||mycellnumber == 317||...
               mycellnumber == 50||mycellnumber == 37||mycellnumber == 36,
                x = xyz(1)-15-15; y=xyz(2)-18;
            end;
            if mycellnumber == 28,
                x = xyz(1)-15+60; y=xyz(2)-18+38;
            end;
            if mycellnumber == 32,
                x = xyz(1)-15+30; y=xyz(2)-18+5;
            end;
            if mycellnumber == 309,
                x = xyz(1)-15+110; y=xyz(2)-18+15;
            end;
            if mycellnumber == 81,
                x = xyz(1)-15-30; y=xyz(2)-18;
            end;
            if mycellnumber == 10,
                x = xyz(1)-15+110; y=xyz(2)-18;
            end;
            if mycellnumber == 9,
                x = xyz(1)-15-40; y=xyz(2)-18;
            end;
        end;
        if rotate==0, pts = [pts ; x y];
		elseif rotate==90, pts = [pts; y 1+sz(1)-x];
		end;
		inclpts(end+1) = i;
		if symb(i)==0,
			inds = pixelindsa.data;
		elseif symb(i)==1,
			xi_ = -symbolsize(i):1:symbolsize(i);
			yi_p= sqrt(symbolsize(i)^2-xi_.^2);
			yi_m=-sqrt(symbolsize(i)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
		elseif symb(i)==2,
			im0_ = im0;
			im0_(round(y-symbolsize(i):y+symbolsize(i)),round(x-symbolsize(i):x+symbolsize(i)))=1;
			inds = find(im0_);
		elseif symb(i)==3|symb(i)==4,
			if symb(i)==3, ang = values(end); else, ang = inda.data; end;
			theta = (90+90-rotate-ang)*pi/180;  % convert to radians 
			th =  arrow_thickness;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first point is in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			theta_ = theta;       % next point is in positive direction
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta - pi/2; % one arrow branch
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi/2; % and now the other branch
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;	     % back to the negative
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center to add nose
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=(1+th)*sin(theta_);yi_(end+1)=(1+th)*cos(theta_);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
		elseif symb(i)==5|symb(i)==6,  % circles w/ arrows
            th =  circle_inner_thickness;  % thickness
			xi_ = -th*symbolsize(i,1):1:th*symbolsize(i,1);
			yi_p= sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			yi_m=-sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
			%if i==1, figure; plot(xi,yi); end;
			inds1_ = find(inpolygon(blank_x,blank_y,xi,yi));
                        th =  circle_outer_thickness;  % thickness
			xi_ = -th*symbolsize(i,1):1:th*symbolsize(i,1);
			yi_p= sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			yi_m=-sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
			%if i==1, hold on; plot(xi,yi,'r'); end;
			inds1__ = find(inpolygon(blank_x,blank_y,xi,yi));
			inds1 = setdiff(inds1_,inds1__);
			% now add arrow
			th=arrow_thickness;
            if symb(i)==5, ang = values(end); else, ang = inda.data; end;
            theta = (90+90-rotate-ang)*pi/180;  % convert to radians
            xi_ = []; yi_ = [];
            theta_ = theta + pi;  % first point is in negative direction
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            theta_ = theta;       % next point is in positive direction
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            theta_ = theta - pi/2; % one arrow branch
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            theta_ = theta;      % and back to center
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            theta_ = theta + pi/2; % and now the other branch
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            theta_ = theta;      % and back to center
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            theta_ = theta + pi;         % back to the negative
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            theta_ = theta;      % and back to center to add nose
            xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1)=(1+th)*sin(theta_);yi_(end+1)=(1+th)*cos(theta_);
            xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
            xi=xi_*symbolsize(i,2)+x; yi=yi_*symbolsize(i,2)+y;
            inds2 = find(inpolygon(blank_x,blank_y,xi,yi));
			inds = union(inds1,inds2);
		elseif symb(i)==7|symb(i)==8,  % lines orthogonal to angle
			if symb(i)==7, ang = values(end); else, ang = inda.data; end;
			theta = (90+90+90-rotate-ang)*pi/180;  % convert to radians 
			th = line_thickness;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first points are in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;       % next points is in positive direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;  % back to original point to complete line
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
        elseif symb(i)==9|symb(i)==10, % direction lines
            % values(end) is assumed to be direction vector
            di = abs(values(end));
            theta = pi-angle(values(end))-rotate*pi/180;
			%theta = (90+90-rotate-ang)*pi/180;  % convert to radians 
			th =  arrow_thickness;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first is negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
   			xi_(end+1)=values(end)*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=values(end)*cos(theta_)-th*cos(theta_+pi/2);
			xi_(end+1)=values(end)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=values(end)*cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
            mycol = values(end)*(opposite_dir_color-background_dir_color);
            im1(inds) = (1-transparency)*mycol(1)+(transparency)*im1(inds);
            im2(inds) = (1-transparency)*mycol(2)+(transparency)*im2(inds);
            im3(inds) = (1-transparency)*mycol(3)+(transparency)*im3(inds);

			xi_ = []; yi_ = [];
  			theta_ = theta;       % next branch is in positive direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
   			xi_(end+1)=-values(end)*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=-values(end)*cos(theta_)-th*cos(theta_+pi/2);
			xi_(end+1)=-values(end)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=-values(end)*cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
            mycol = values(end)*(preferred_dir_color-background_dir_color);
            im1(inds) = (1-transparency)*mycol(1)+(transparency)*im1(inds);
            im2(inds) = (1-transparency)*mycol(2)+(transparency)*im2(inds);
            im3(inds) = (1-transparency)*mycol(3)+(transparency)*im3(inds);
            if symb(i)==10,
                xi_ = []; yi_ = [];
                theta_ = theta;       % center square
                xi_(end+1)=(-values(end)+th)*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=(-values(end)+th)*cos(theta_)-th*cos(theta_+pi/2);
                xi_(end+1)=(-values(end)+th)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=(-values(end)+th)*cos(theta_)+th*cos(theta_+pi/2);
                xi_(end+1)=(-values(end)-th)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=(-values(end)-th)*cos(theta_)+th*cos(theta_+pi/2);
                xi_(end+1)=(-values(end)-th)*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=(-values(end)-th)*cos(theta_)-th*cos(theta_+pi/2);
                xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
                inds = inpolygon(blank_x,blank_y,xi,yi);
                mycol = values(end)*(center_dir_color-background_dir_color);
                im1(inds) = (1-transparency)*mycol(1)+(transparency)*im1(inds);
                im2(inds) = (1-transparency)*mycol(2)+(transparency)*im2(inds);
                im3(inds) = (1-transparency)*mycol(3)+(transparency)*im3(inds);
            end;
        elseif symb(i)==11|symb(i)==12, % direction lines
			if symb(i)==11, ang = values(end); else, ang = inda.data; end;
			theta = (90+90+90-rotate-ang)*pi/180;  % convert to radians 
			th = line_thickness;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first points are in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;       % next points is in positive direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;  % back to original point to complete line
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i,1)+x; yi=yi_*symbolsize(i,1)+y;
			inds1 = find(inpolygon(blank_x,blank_y,xi,yi));  
            
			theta = (90+90-rotate-ang)*pi/180;  % convert to radians 
			th =  arrow_thickness;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first point is in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			theta_ = theta;       % next point is in positive direction
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta - pi/2; % one arrow branch
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi/2; % and now the other branch
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;	     % back to the negative
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center to add nose
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=(1+th)*sin(theta_);yi_(end+1)=(1+th)*cos(theta_);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i,2)+x; yi=yi_*symbolsize(i,2)+y;
			inds2 = find(inpolygon(blank_x,blank_y,xi,yi));
            inds = union(inds1,inds2);
        elseif symb(i)==13|symb(i)==14, % direction lines
			if symb(i)==13, ang = values(end); else, ang = inda.data; end;
			theta = (90+90+90-rotate-ang)*pi/180;  % convert to radians 
			th = line_thickness;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first points are in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;       % next points is in positive direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;  % back to original point to complete line
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i,1)+x; yi=yi_*symbolsize(i,1)+y;
			inds1 = find(inpolygon(blank_x,blank_y,xi,yi));  
            
			theta = (90+90-rotate-ang)*pi/180;  % convert to radians 
			th =  arrow_thickness;  % thickness
            r = arrow_radius;
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first point is in negative direction
			xi_(end+1)=0*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=0*cos(theta_)+th*cos(theta_+pi/2);
			theta_ = theta;       % next point is in positive direction
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta - arrow_theta; % one arrow branch
			xi_(end+1)=r*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=r*cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=r*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=r*cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + arrow_theta; % and now the other branch
			xi_(end+1)=r*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=r*cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=r*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=r*cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;	     % back to the negative
			xi_(end+1)=0*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=0*cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=0*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=0*cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center to add nose
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=(1+th)*sin(theta_);yi_(end+1)=(1+th)*cos(theta_);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i,2)+x; yi=yi_*symbolsize(i,2)+y;
			inds2 = find(inpolygon(blank_x,blank_y,xi,yi));
            inds = union(inds1,inds2);
        elseif symb(i)==15|symb(i)==16,    
			if symb(i)==15, ang = values(end); else, ang = inda.data; end;
            theta = (90+90-rotate-ang)*pi/180;  % convert to radians 
			th =  arrow_thickness;  % thickness
            r = arrow_radius;
            di = symbolsize(i,2);
            Rn = max([1-di 0]);
            Rp = max([1+di 2]);
            al = 2*arrow_length; %0.33*cos(30*pi/180)
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first point is in negative direction
            xi_(end+1) = +th*sin(theta_+pi/2); yi_(end+1)=th*cos(theta_+pi/2);
			xi_(end+1)=max(Rn-th,0)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=max(Rn-th,0)*cos(theta_)+th*cos(theta_+pi/2);
            if Rn>al/2,
                % add arrow head if needed
                xi_(end+1) = xi_(end)+(al-2*th)*sin(theta_+150*pi/180);yi_(end+1)=yi_(end)+(al-2*th)*cos(theta_+150*pi/180);
                xi_(end+1) = xi_(end)+2*th*sin(theta_+(150-90)*pi/180); yi_(end+1)=yi_(end)+2*th*cos(theta_+(150-90)*pi/180);
            end;
            xi_(end+1)=(Rn>0)*(Rn+th)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=(Rn>0)*(Rn+th)*cos(theta_)+th*cos(theta_+pi/2);
            if Rn>al/2,
                % now add nose
                xi_(end+1)=(Rn+2*th)*sin(theta_);yi_(end+1)=(Rn+2*th)*cos(theta_);
            end;
            xi_(end+1)=(Rn>0)*(Rn+th)*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=(Rn>0)*(Rn+th)*cos(theta_)-th*cos(theta_+pi/2);
            xiii=max(Rn-th)*sin(theta_)-th*sin(theta_+pi/2);yiii=max(Rn-th,0)*cos(theta_)-th*cos(theta_+pi/2);
            if Rn>al/2,
                % add second branch
                xi_(end+1) = xiii+(al-2*th)*sin(theta_-150*pi/180)+2*th*sin(theta_-(150-90)*pi/180);
                yi_(end+1)=yiii+(al-2*th)*cos(theta_-150*pi/180)+2*th*cos(theta_-(150-90)*pi/180);
                xi_(end+1) = xiii+(al-2*th)*sin(theta_-150*pi/180);
                yi_(end+1)=yiii+(al-2*th)*cos(theta_-150*pi/180);
            end;
            xi_(end+1) = xiii; yi_(end+1) = yiii;
            xi_(end+1) = -th*sin(theta_+pi/2); yi_(end+1)=-th*cos(theta_+pi/2);
            % now we're parked at 0 on -th y side
			theta_ = theta;       % next point is in positive direction
			xi_(end+1)=max(Rp-th,0)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=max(Rp-th,0)*cos(theta_)+th*cos(theta_+pi/2);
            xi_(end+1) = xi_(end)+(al-2*th)*sin(theta_+150*pi/180);yi_(end+1)=yi_(end)+(al-2*th)*cos(theta_+150*pi/180);
            xi_(end+1) = xi_(end)+2*th*sin(theta_+(150-90)*pi/180); yi_(end+1)=yi_(end)+2*th*cos(theta_+(150-90)*pi/180);                       
			xi_(end+1)=(Rp+th)*sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=(Rp+th)*cos(theta_)+th*cos(theta_+pi/2);
            % nose
			xi_(end+1)=(Rp+2*th)*sin(theta_)+0*th*sin(theta_+pi/2);yi_(end+1)=(Rp+2*th)*cos(theta_)+0*th*cos(theta_+pi/2);
			xi_(end+1)=(Rp+th)*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=(Rp+th)*cos(theta_)-th*cos(theta_+pi/2);
            % second branch
            xiii = (Rp-th)*sin(theta_)-th*sin(theta_+pi/2); yiii = (Rp-th)*cos(theta_)-th*cos(theta_+pi/2);
            xi_(end+1) = xiii+(al-2*th)*sin(theta_-150*pi/180)-2*th*sin(theta_+(30+90)*pi/180);
            yi_(end+1)=yiii+(al-2*th)*cos(theta_-150*pi/180)-2*th*cos(theta_+(30+90)*pi/180);
            xi_(end+1) = xiii+(al-2*th)*sin(theta_-150*pi/180);
            yi_(end+1)=yiii+(al-2*th)*cos(theta_-150*pi/180);
			xi_(end+1)=xiii;yi_(end+1)=yiii;
            % now last point
			xi_(end+1)=0*sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=0*cos(theta_)-th*cos(theta_+pi/2);

			xi=xi_*symbolsize(i,1)+x; yi=yi_*symbolsize(i,1)+y;
			inds = find(inpolygon(blank_x,blank_y,xi,yi));
            mycol = cols(i,:);
            im1(inds) = (1-transparency)*mycol(1)+(transparency)*im1(inds);
            im2(inds) = (1-transparency)*mycol(2)+(transparency)*im2(inds);
            im3(inds) = (1-transparency)*mycol(3)+(transparency)*im3(inds);
            
			xi_ = 3*(-th*symbolsize(i,1):1:th*symbolsize(i,1));
			yi_p= 3*sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			yi_m=-3*sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
            inds = find(inpolygon(blank_x,blank_y,xi,yi));
            mycol = [ 1 1 1 ];
            im1(inds) = (1-transparency)*mycol(1)+(transparency)*im1(inds);
            im2(inds) = (1-transparency)*mycol(2)+(transparency)*im2(inds);
            im3(inds) = (1-transparency)*mycol(3)+(transparency)*im3(inds);

            
        else, error(['Unknown symbol ' int2str(symb(i)) '.']);
		end;
        %keyboard;
        if ~any(symb(i)==[9 10 15 16]),
            if any(cols(i,:)<0),
                mycol = ctab(findclosest(steps,values(end)),:);
            else,
                mycol = cols(i,:);
            end;
            im1(inds) = (1-transparency)*mycol(1)+(transparency)*im1(inds);
            im2(inds) = (1-transparency)*mycol(2)+(transparency)*im2(inds);
            im3(inds) = (1-transparency)*mycol(3)+(transparency)*im3(inds);
        end;
	end;
end;

if rotate==0,
	im = cat(3,im1,im2,im3);
elseif rotate==90,
	im = cat(3,im1(:,end:-1:1)',im2(:,end:-1:1)',im3(:,end:-1:1)');
end;
%keyboard;
if plotit,
	%figure;
    %ax = axes('position',[0.100    0.15    0.70    0.70]);
	imageh = image(im);

	% scale bar
    %keyboard;    
    %scalebaraxes = axes('position',[0.9 0.11 0.05 0.8150]);
% 	scaleim1 = zeros(10,numcolors);
% 	scaleim2 = scaleim1; scaleim3 = scaleim1;
% 	for i=1:numcolors,
% 		scaleim1(:,i) = ctab(i,1);
% 		scaleim2(:,i) = ctab(i,2);
% 		scaleim3(:,i) = ctab(i,3);
% 	end;
	%scalebarimage=image(cat(3,scaleim1',scaleim2',scaleim3'));
% 	set(gca,'fontsize',14);
% 	set(gca,'xtick',[]);
% 	set(gca,'ytick',scalebarticks);
% 	ytick = get(gca,'ytick');
% 	yticklabs = {};
% 	for i=1:length(ytick),
% 		myind = findclosest(1:length(steps),ytick(i));
% 		yticklabs{i} = num2str(steps(myind),3);
% 	end;
% 	set(gca,'yticklabel',yticklabs);

%	axes(ax);
     if pair>0,
         
         indexassocp = 'TP All Ach OT Fit Pref',
     else indexassocp =indexassoc;
     end;
    axis square;
    
	myud = struct('pts',pts,'inclpts',inclpts,'cells',{cells(inclpts)},'cellnames',{cellnames(inclpts)},'indexassoc',indexassocp,'imagesize',[size(im,1) size(im,2)],...
        'values',values,'traindir',traindir);
    myud.varargin = varargin;
	set(gcf,'userdata',myud);
	set(imageh,'ButtonDownFcn','pvcontinuousmapOD');
	%keyboard;
end;
 
global myimmap

myimmap = im;
