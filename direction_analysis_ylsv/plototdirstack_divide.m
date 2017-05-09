function im = plototdirstack_divide(ds_or_cells,stackname,divider, varargin)

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

pthreshold=0.05;
colorscale=0;
rotate=0;
imagesize=[512 512];
dirthresh=-100;
dir_assoc='TP Ach OT Carandini Fit Params';
ot_assoc = 'TP Ach OT Fit Pref';
pthreshold_assoc = 'TP Ach OT vec varies p'; 
supressplot=0;
transparency = 0;
dir_pref_assoc = 'TP Ach OT Fit Pref';
fit_assoc = 'TP Ach OT Carandini Fit';
dirind_assoc = 'TP Ach OT Fit Direction index blr';
projection = [ 0 1];
afterscale = [ 0 1];

if isa(ds_or_cells,'dirstruct'),
	ds = ds_or_cells;
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell_tp*','-mat');
else, cells = ds_or_cells;
	if length(cells) == 0,
        cellnames = {};
	else,
        for i=1:length(cells),
            cellnames{i} = '';
        end;
	end;
end;

if nargin>4, assign(varargin{:}); end;

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
for i=1:length(cells),
        f=findassociate(cells{i},dir_assoc,'','');
		dp = findassociate(cells{i},dir_pref_assoc,'','');
		fi=findassociate(cells{i},fit_assoc,'','');

		if ~isempty(f),
			dia=findassociate(cells{i},dirind_assoc,'','');
			di = dia.data;
			symb(i) = 1 + 5*(di>dirthresh) -1;
			%symsize(i,[1 2]) = [12 (di>dirthresh)*12];
			symsize(i,[1 2]) = (di>=0)*8*[1 1] + (di>=0.33)*3*[1 1]+(di>=0.66)*3*[1 1];
			ad = angdiffwrap(dp.data-divider,360);
			if ad < 90, cols(i,:) = rescale(di,projection,afterscale) * [1 1 0];
			else, cols(i,:) = rescale(di,projection,afterscale) * [ 0 1 1];
		end;
	else,
		symb(i) = 0;
		cols(i,:) = [ -1 -1 -1];
		symsize(i,[1 2]) = [12 0];
        end;
end;

if exist('ds')==1,
	[im,scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,...
		'mod(x-45,360)',0:179,~supressplot,...
		'pvalueassoc',pthreshold_assoc,'pvalue',pthreshold,'symbol',symb,'symbolsize',symsize,'colors',cols,...
		'rotate',rotate,'ds',ds,'transparency',transparency);
else,
	[im,scalebarax,scalebarimg]=pvcontinuousmap(imagesize,1,cells,cellnames(mycells),ot_assoc,...
		'mod(x-45,360)',0:179,~supressplot,...
		'pvalueassoc',pthreshold_assoc,'pvalue',pthreshold,'symbol',symb,'symbolsize',symsize,'colors',cols,...
		'rotate',rotate,'transparency',transparency);
end;

if ~colorscale, delete(scalebarax); end;
