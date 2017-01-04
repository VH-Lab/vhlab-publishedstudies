function im = plotiontstack(ds_or_cells,stackname,varargin)

% PLOTIONTSTACK - Plot a stack of OT and DIR selective cells
%
%  IM=PLOTIONTSTACK(MYDIRSTRUCT_OR_CELLLIST, STACKNAME, ...)
%
%  MYDIRSTRUCT_OR_CELLLIST can be either the directory structure
%  where the experiment files are stored.
%  Alternatively, 
%  STACKNAME is the name of the stack as described in ANALYZETPSTACK.
%  Might be 'Site 1' or 'Test' or some such name.  If STACKNAME is
%  empty, the user is prompted for the proper name or, if only one
%  stack is present, that stack is used.
%
%  IM is a Matlab image handle.  It is plotted in the current
%  axes.
%
%  Extra arguments can be given in pairs (e.g., 'pthreshold', 1):
%
%  PTHRESHOLD               P threshold for including cells.
%                           Default is 0.05.  If more than one
%                           index is provided, then this can be
%                           an array or the same value will be used.
%  PTHRESHOLD_ASSOC         Associate that holds the P value
%                           (default 'OT visual response p')
%  COLORSCALE       0/1     Include color scale? Default 0 (yes).
%  TRANSPARENCY     0..1    Transparency of symbols drawn in plot
%  ROTATE         (0 or 90) Angle to rotate the image.  Default 0.
%  IMAGESIZE    [X Y]       Size of image to be generated.
%                           Default is [512 512].
%  SUPRESSPLOT   0/1        If 1, plotting of IM is supressed.
%                           Default 0.
%  DIRTHRESH     (value)    Threshold for direction selective cell.
%  DIR_ASSOC    string      'OT Fit Direction index' (default),
%                           'OT Direction index', or 
%                           'OT Direction index 2 Peak'
%  OT_ASSOC    string       'OT Pref', 'OT Fit Pref', or
%                           'OT Fit Pref 2 Peak'
%  DEFAULT_COLOR

rotate=0;
colorscale=0;
imagesize=[512 512];
supressplot=0;
transparency = 0;

default_color  = [ 0 1 0 ];
glut_color = [ 1 0 0 ];
glut_vis_color = [ 1 1 0 ];
gaba_color = [ 0 0 1 ];
gaba_vis_color = [ 0 1 1 ];

gaba_thickness = 0.1;
glut_thickness = 0.2;
default_thickness = 0.5;

titlestr = 'green=cell,red=direct glut,yellow=vis resp w/ glut,blue=direct gaba,mag=vis resp w/ gaba';

iont_pipette = [NaN NaN NaN];

dirthresh=0.5;
dir_assoc='OT Carandini Fit Params';
ot_assoc = 'Iont OT Fit Pref';

 % what to plot ... dots for insig vis responses, bars for ori, arrows for dir

pthreshold_assoc = 'OT visual response p'; 
pthreshold=0.05;

otdirgreenblue = 0;
otgray = 1;

if isa(ds_or_cells,'dirstruct'),
	ds = ds_or_cells;
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell_tp*','-mat');
else, cells = ds_or_cells; for i=1:length(cells), cellnames{i} = ''; end;
end;

if nargin>3, assign(varargin{:}); end;

if isempty(stackname),
	possiblestacks = findallstacks(cells);
	if length(possiblestacks)>1,
		disp(['Following stack names are possible: ' possiblestacks '.']);
		done = 0;
		r = input('Which stack?','s');
		for j=1:length(possiblestacks),
			if strcmp(r,possiblestacks{j}),
				stackname=possiblestacks{j};
				break;
			end;
		end;
		if isempty(stackname), error(['No stackname selected.']); end;
	elseif length(possiblestacks)==1, stackname = possiblestacks{1};
	elseif length(possiblestacks)==0, error(['No stacks found.']);
	end;
end;

mycells = [];

for i=1:length(cells),
	stackassoc = findassociate(cells{i},'analyzetpstack name','','');
    cur = findassociate(cells{i},'Iont currents','','');
	if ~isempty(stackassoc)&~isempty(cur),
		if strcmp(stackassoc.data,stackname),
			mycells(end+1) = i;
		end;
	end;
end;

cells=cells(mycells);

 % use first cell to represent them all
 
 cur = findassociate(cells{i},'Iont currents','','');
  % arbitrarily pick biggest current for glut, gaba
 [maxvalue,gabaind] = max(cur.data);
 [minvalue,glutind] = min(cur.data);
 if maxvalue<=0, gabaind = NaN; end;
 if minvalue>=0, glutind = NaN; end;

symb = {}; cols = {}; symsize = [];
for i=1:length(cells),
	cur = findassociate(cells{i},'Iont currents','','');
	dias=findassociate(cells{i},['Iont ' dir_assoc],'','');
   	sigiont = findassociate(cells{i},'Iont p value','','');
	vp = findassociate(cells{i},['Iont ' pthreshold_assoc],'','');

    for k=1:3,
        switch k,
            case 1,
                ind = find(cur.data==0);
                cols{k}(i,[1 2 3]) = default_color;
                dirind = diff(dias.data{ind}([2 5]))./dias.data{ind}(2);
                visresp = vp.data{ind}<=pthreshold;
                present = 1;
                symb{k}(i) = (~visresp)+(4*(dirind>=dirthresh)+7*(dirind<dirthresh))*(visresp);
                if symb{k}(i)==1, symsize{k}(i,[1 2]) = [ 8 8 ]; else, symsize{k}(i,[1 2]) = [12 12]; end;
            case 2,
                if ~isnan(glutind),
                    present = 1;
                    ind = glutind;
                    if sigiont.data(ind,2)<pthreshold,
                        cols{k}(i,[1 2 3]) = glut_color;
                    else, cols{k}(i,[1 2 3]) = [0 0 0];
                    end;
                    dirind = diff(dias.data{ind}([2 5]))./dias.data{ind}(2);
                    visresp = vp.data{ind}<=pthreshold;
                    if visresp&eqlen(cols{k}(i,[1 2 3]),[0 0 0]), cols{k}(i,[1 2 3]) = glut_vis_color; end;
                    symb{k}(i) = (~visresp)+(4*(dirind>=dirthresh)+7*(dirind<dirthresh))*(visresp);
                    if symb{k}(i)==1, symsize{k}(i,[1 2]) = [ 5 5]; else, symsize{k}(i,[1 2]) = [16 16]; end;                
                else, present = 0; cols{k}(i,[1 2 3]) = [ 0 0 0 ];  symb{k}(i) = 1; symsize{k}(i,[1 2]) = [1 1];      
                end;
           case 3,
                if ~isnan(gabaind),
                    present = 1;
                    ind = gabaind;
                    if sigiont.data(ind,2)<pthreshold,
                        cols{k}(i,[1 2 3]) = gaba_color;
                    else, cols{k}(i,[1 2 3]) = [0 0 0];
                    end;
                    dirind = diff(dias.data{ind}([2 5]))./dias.data{ind}(2);
                    visresp = vp.data{ind}<=pthreshold;
                    if visresp&eqlen(cols{k}(i,[1 2 3]),[0 0 0]), cols{k}(i,[1 2 3]) = gaba_vis_color; end;
                    symb{k}(i) = (~visresp)+(4*(dirind>=dirthresh)+7*(dirind<dirthresh))*(visresp);
                    if symb{k}(i)==1, symsize{k}(i,[1 2]) = [ 3 3]; else, symsize{k}(i,[1 2]) = [16 16]; end;                            
                else, present = 0; cols{k}(i,[1 2 3]) = [ 0 0 0 ]; symb{k}(i) = 1; symsize{k}(i,[1 2]) = [1 1];
                end;
        end;
    end;
end;

for k=1:3,
    plotit = ~supressplot;
    if k==1, thickness = default_thickness; elseif k==2, thickness = glut_thickness; elseif k==3, thickness = gaba_thickness; end;
	if exist('ds')==1,
        [im0{k},scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,'mod(x{nocurrentind},180)',0:179,plotit,'pvalueassoc',pthreshold_assoc,'pvalue',1,'symbol',symb{k},'symbolsize',symsize{k},'colors',cols{k},...
            'rotate',rotate,'ds',ds,'transparency',transparency,'nocurrentind',ind,'line_thickness',thickness);
    else,
        [im0{k},scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,'mod(x{nocurrentind},180)',0:179,plotit,'pvalueassoc',pthreshold_assoc,'pvalue',1,'symbol',symb{k},'symbolsize',symsize{k},'colors',cols{k},...
            'rotate',rotate,'transparency',transparency,'nocurrentind',ind,'line_thickness',thickness);
    end;

    if plotit&~colorscale, delete(scalebarax); end;
    if plotit&(k==2|k==3), close(gcf); end;
end;


  % start no stim, overlay GLUT then GABA on top
im = im0{1};
for j=1:3,
    imi{j} = or(or(im0{j}(:,:,1),im0{j}(:,:,2)),im0{j}(:,:,3));
end;

for j=1:3,
    im_ = im(:,:,j);
    im0_ = im0{2}(:,:,j);
    im_(find(imi{2})) = im0_(find(imi{2}));
    im0_ = im0{3}(:,:,j);
    im_(find(imi{3})) = im0_(find(imi{3}));
    im(:,:,j) = im_;    
end;

if plotit,
   cla;
   imh=image(im);
   set(imh,'ButtonDownFcn','pvcontinuousmap');    
   title(titlestr);
end;