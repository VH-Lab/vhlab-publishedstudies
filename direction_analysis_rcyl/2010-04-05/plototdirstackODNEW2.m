function im = plototdirstackNEW2(ds_or_cells,stackname,varargin)

% PLOTOTDIRSTACK - Plot a stack of OT and DIR selective cells
%
%  IM=PLOTOTDIRSTACK(MYDIRSTRUCT_OR_CELLLIST, STACKNAME, ...)
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
%  COLORSCALE       0/1     Include color scale? Default 1 (yes).
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
%  OTGRAY         0/1       Should OT cells be gray?  Default 1.
%  OTDIRGREENBLUE 0/1       Should OT cells be green and dir cells blue? Default 0.
%  DIRGREENBLUE   0/1       Should DS cells be green or blue on PREF; Size of symbol on DI? Default 0.
%  DIRGREENBLUECHANGE 0/1   Should DS cells be green or blue on PREF; Size of symbol on ratio of change? Default 0.
%  TRAINDIR (value)         taining angle [0 360] 
%  SHIFT (value)            shift of head angle due to 2photon imaging setup (default 0) 

pthreshold=0.05;colorscale=1;rotate=0;imagesize=[512 512];dirthresh=0.5;dir_assoc='OT Fit Direction index';
ot_assoc = 'OT Fit Pref'; pthreshold_assoc = 'OT visual response p'; otdirgreenblue = 0; dirgreenblue = 1;
supressplot=0;otgray = 0; transparency = 0; traindir = 0; shift = 0;


if isa(ds_or_cells,'dirstruct'),
	ds = ds_or_cells;
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell_tp*','-mat');
	%[cells2,cellnames2]=load2celllist(getexperimentfile(ds),'cell_tp_002*','-mat');
	%[cells3,cellnames3]=load2celllist(getexperimentfile(ds),'cell_tp_005*','-mat');
	%cells = cat(1,cells',cells2',cells3'); cellnames = cat(2,cellnames',cellnames2',cellnames3');
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
	if ~isempty(stackassoc),
		if strcmp(stackassoc.data,stackname),
			mycells(end+1) = i;
		end;
	end;
end;

cells=cells(mycells);

symb = []; cols = []; symsize = [];
traindir,
shift,
pair,
for i=1:length(cells),
        dias=findassociate(cells{i},dir_assoc,'','');
%          dias1=findassociate(cells{i},dir_assoc1,'','');
%          dias2=findassociate(cells{i},dir_assoc2,'','');
        prefas=findassociate(cells{i},ot_assoc,'','');
%          prefas1=findassociate(cells{i},ot_assoc1,'','');
%          prefas2=findassociate(cells{i},ot_assoc2,'','');
        %dias.data,
            if ~isempty(dias),
                symb(i) = 1 + 5*(dias.data>dirthresh);
                symsize(i,[1 2]) = [12 dias.data*12];
            if otgray,
            	if dias.data<dirthresh, cols(i,:)=[0.7 0.7 0.7];
            	else, cols(i,:) = [-1 -1 -1];
            	end;
            elseif otdirgreenblue,
            	if dias.data>dirthresh, cols(i,:) = [ 1 0 0];
            	else, cols(i,:) = [ 0 1 0];
            	end;
            	symb(i) = 4*(dias.data>=dirthresh)+8*(dias.data<dirthresh);
                symsize(i,[1 2]) = [12 12];
            elseif dirgreenblue,
                if ~isempty(dias)& ~isempty(dias),
                    if angdiffwrap(prefas.data-traindir,360)>=90,dias.data = -dias.data; end;
                end;
                if dias.data > 0, cols(i,:) = [1 1 0];%red[1 0 0] green[0 1 0] blue[0 0 1] yellow[1 1 0] cyan[0 1 1]cyan
                else, cols(i,:) = [0 1 1];
            	end;
                symb(i) = 3*(abs(dias.data)>=dirthresh)+7*(abs(dias.data)<dirthresh);
                if abs(dias.data)<=0.3, symsize(i,[1 2]) = [6 6];end;
                if abs(dias.data)>0.3 & abs(dias.data<0.5), symsize(i,[1 2]) = [8 8];end;
                if abs(dias.data)>0.5, symsize(i,[1 2]) = [12 12];end;
            
            elseif dirgreenbluechange,
                if dias.data>0, cols(i,:) = [ 1 0 0];
                else, cols(i,:) = [ 0 1 0];
            	end;
                symb(i) = 4*(abs(dias.data)>=dirthresh)+8*(abs(dias.data)<dirthresh);
                % here decide size of symbol
                if abs(dias.data)<=0.5, symsize(i,[1 2]) = [8 8];sizeref = 8; end; 
                if abs(dias.data)>0.5, symsize(i,[1 2]) = [12 12];sizeref = 12; end; 
                if dir_assoc(4) == 'M',
                    
                    if dias2.data>dias1.data, symsize(i,[1 2]) = [sizeref+2 sizeref+2];end;
                    if dias2.data<dias1.data, symsize(i,[1 2]) = [sizeref-2 sizeref-2];end;
                    if dias2.data==dias1.data, symsize(i,[1 2]) = [sizeref sizeref];end;
                end;
     
            elseif (dias.data>dirthresh), cols(i,:) = [-1 -1 -1];
                else, cols(i,:) = [ 0.7 0.7 0.7];
            end;
        else, symb(i) = 0; cols(i,:) = [ -1 -1 -1]; symsize(i,[1 2]) = [12 0];
        end;
end;
%g = gca;
if exist('ds')==1, varargin = cat(2,varargin, {'ds',ds});end;

%mathstr = 'mod(x-45,360)';
mathstr = 'mod(x-shift,360)';
%'dirname'_OR_imagesize: 
[im,scalebarax,scalebarimg]=pvcontinuousmapOD(imagesize,1,cells,cellnames(mycells),ot_assoc,mathstr,0:179,~supressplot,'pvalueassoc',pthreshold_assoc,'pvalue',pthreshold,'symbol',symb,'symbolsize',symsize,'colors',cols,...
	'rotate',rotate,'transparency',transparency,'traindir',traindir,'pair',pair,varargin{:});

if ~colorscale, delete(scalebarax); end;
